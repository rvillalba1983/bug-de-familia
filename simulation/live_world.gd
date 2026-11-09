class_name LiveWorld
extends Node
## Une la simulación lógica con la escena: pone a cada habitante en el mapa y le da órdenes.

const DIRECT_INTERVAL: float = 1.0
const HEAR_RANGE: float = 620.0
const BUBBLE_TIME: float = 3.2
const WANDER_CHANCE: float = 0.08
const SEE_RANGE: float = 700.0
const BUBBLE_SPACING: float = 260.0
const CALL_RANGE: float = 320.0
const CALL_INTERVAL: float = 25.0
const FEST_NOISE: float = 700.0
const FEST_RANGE: float = 320.0
const FEST_REACH: float = 170.0
const FEST_LINE_CHANCE: float = 0.05
const ID_TRACE: String = "rastro_"
const ID_LOST: String = "perdido_"

## Veces que el jugador ha malmetido entre razas desde la última batalla provocada.
var provocations: int = 0
var level: BetaZone
var sim: WorldSim = WorldSim.new()
var dialogue: LiveDialogue
var citizens: Dictionary = {}
var started: bool = false
## El golpe que cae ahora viene de una batalla, no del jugador.
var battle_casualty: bool = false

var _talk_items: Dictionary = {}
var _bubbles: Dictionary = {}
var _direct_time: float = 0.0
var _call_time: float = 0.0
var _decor: FestivalDecor
var _mission_items: Dictionary = {}


func _ready() -> void:
	dialogue = LiveDialogue.new()
	dialogue.world = self
	add_child(dialogue)


func start(data: Dictionary) -> void:
	var zone: ZoneDefinition = BetaLayout.zone
	for species: String in zone.species():
		var home: Dictionary = zone.data["homes"][species]
		sim.spawn_areas[species] = zone.rect(str(home["area"]))
		sim.gates[species] = zone.point(str(home["gate"]))
	sim.open_spots = BetaLayout.open_spots
	sim.start(level.rng.seed, data)
	var added_traces: Array = sim.festivals.collect_traces(sim, sim.last_seen_day)
	sim.last_seen_day = WorldCalendar.today()
	sim.festivals.update(sim)
	for id: String in sim.npc_ids:
		if (sim.npcs[id] as NpcState).alive:
			_show_citizen(sim.npcs[id])
	sim.npc_added.connect(_show_citizen)
	sim.npc_died.connect(_on_npc_died)
	sim.rumor_told.connect(_on_rumor_told)
	sim.event_happened.connect(_on_event_happened)
	sim.event_staged.connect(_on_event_staged)
	sim.mission_changed.connect(_on_mission_changed)
	level.noise_bus.noise_emitted.connect(_on_noise)
	_build_festival_view(added_traces)
	for mission: Dictionary in sim.missions.open_missions():
		_show_mission_item(mission)
	started = true


func _physics_process(delta: float) -> void:
	if not started or get_tree().paused:
		return
	sim.tick(delta)
	_direct_time -= delta
	if _direct_time <= 0.0:
		_direct_time = DIRECT_INTERVAL
		_direct_all()
		_check_player_missions()
		_call_player(delta)


func to_dict() -> Dictionary:
	_sync_positions()
	if OS.is_debug_build():
		for problem: String in ConsistencyChecker.check(sim):
			push_error("Mundo incoherente: %s" % problem)
	return sim.to_dict()


func bubble_of(id: String) -> SpeechBubble:
	return _bubbles[id]


func handles_item(item: Interactable) -> bool:
	if item.item_id.begins_with(ID_TRACE):
		_read_trace(item)
		return true
	if item.item_id.begins_with(ID_LOST):
		sim.missions.item_taken(sim, item.item_id.trim_prefix(ID_LOST).to_int())
		_remove_mission_item(item.item_id)
		return true
	if not sim.npcs.has(item.item_id):
		return false
	var npc: NpcState = sim.npcs[item.item_id]
	if npc.alive and not dialogue.is_open():
		dialogue.open(npc)
	return true


## Opciones que añaden otros sistemas, como las misiones.
func extra_options(npc: NpcState) -> Array:
	var entries: Array = []
	for option: Array in sim.missions.options_for(npc):
		entries.append([option[0], _do_mission.bind(option[1], option[2])])
	if sim.festivals.is_running() and not sim.festivals.joined and not sim.festivals.ruined:
		entries.append([tr("LIVE_JOIN_FEST"), _join_festival])
	if not sim.festivals.traces.is_empty():
		entries.append([tr("LIVE_ASK_FEST"), _ask_trace])
	return entries


## Un habitante ha caído o se ha convertido por lo que sea.
func on_citizen_gone(id: String) -> void:
	if not sim.npcs.has(id) or not (sim.npcs[id] as NpcState).alive:
		return
	var npc: NpcState = sim.npcs[id]
	if is_instance_valid(citizens.get(id)):
		npc.pos = (citizens[id] as Guard).global_position
	sim.kill(id)
	if battle_casualty:
		return
	sim.events.report(sim, "el_sobrante_mata", WorldSim.PLAYER_ID, id, npc.pos)


func say_from(npc: NpcState, text: String) -> void:
	_speak(npc, text)


func home_of(species: String) -> Rect2:
	return sim.spawn_areas[species]


func _sync_positions() -> void:
	for id: String in citizens:
		if is_instance_valid(citizens[id]):
			(sim.npcs[id] as NpcState).pos = (citizens[id] as Guard).global_position


func _show_citizen(npc: NpcState) -> void:
	var guard: Guard = level.add_citizen(npc.id, npc.species, npc.pos, home_of(npc.species))
	citizens[npc.id] = guard
	var item: Interactable = Interactable.new()
	item.setup(npc.id, Interactable.Kind.NPC, Vector2.ZERO)
	item.custom_label = npc.name
	item.body_hidden = true
	item.reusable = true
	item.activated.connect(level.on_item_activated)
	guard.add_child(item)
	_talk_items[npc.id] = item
	var bubble: SpeechBubble = SpeechBubble.new()
	bubble.position = Vector2(0.0, -120.0)
	bubble.visible = false
	guard.add_child(bubble)
	_bubbles[npc.id] = bubble
	guard.tree_exiting.connect(_forget_citizen.bind(npc.id))


func _forget_citizen(id: String) -> void:
	citizens.erase(id)
	_talk_items.erase(id)
	_bubbles.erase(id)


func _direct_all() -> void:
	_sync_positions()
	var festival: bool = _festival_running()
	for id: String in citizens:
		if not is_instance_valid(citizens[id]) or not (sim.npcs[id] as NpcState).alive:
			continue
		var npc: NpcState = sim.npcs[id]
		var guard: Guard = citizens[id]
		if level.battles.is_fighter(id):
			continue
		if guard.state in [Guard.State.PATROL, Guard.State.WAIT, Guard.State.LOOK_AROUND]:
			_direct(npc, guard, Motivation.choose(sim, npc, festival))


func _festival_running() -> bool:
	return sim.festivals.is_running() and not sim.festivals.ruined


func _direct(npc: NpcState, guard: Guard, activity: String) -> void:
	npc.activity = activity
	match activity:
		"cotillear":
			var target: NpcState = _nearest_unaware(npc)
			if target != null:
				guard.investigate(target.pos)
		"fiesta":
			if npc.pos.distance_to(sim.festivals.spot) > FEST_REACH:
				guard.investigate(sim.festivals.spot + _spread(npc))
			elif sim.rng.randf() < FEST_LINE_CHANCE:
				var said: Array = sim.festivals.current["lines"]
				_speak(npc, said[sim.rng.randi_range(0, said.size() - 1)])
		"huir":
			guard.investigate(_home_point(npc.species))
		"rarezas":
			var lines: Array = sim.species_data[npc.species]["weird"]
			_speak(npc, lines[sim.rng.randi_range(0, lines.size() - 1)])
		"trabajar":
			var away: bool = not home_of(npc.species).has_point(npc.pos)
			if away or sim.rng.randf() < WANDER_CHANCE:
				guard.investigate(_home_point(npc.species))


func _home_point(species: String) -> Vector2:
	var area: Rect2 = home_of(species)
	return Vector2(
		sim.rng.randf_range(area.position.x, area.end.x),
		sim.rng.randf_range(area.position.y, area.end.y)
	)


func _nearest_unaware(npc: NpcState) -> NpcState:
	var news: int = sim.rumors.fresh_news(sim, npc)
	var best: NpcState = null
	for id: String in sim.npc_ids:
		var other: NpcState = sim.npcs[id]
		if other == npc or not other.alive or other.beliefs.has(str(news)):
			continue
		if best == null or npc.pos.distance_to(other.pos) < npc.pos.distance_to(best.pos):
			best = other
	return best


func _spread(npc: NpcState) -> Vector2:
	var seed_value: int = absi(npc.id.hash())
	return Vector2(float(seed_value % 240) - 120.0, float(seed_value % 170) - 85.0)


## Nunca dos bocadillos encima: si alguien cerca ya habla, este se calla.
func _crowded(npc: NpcState) -> bool:
	for id: String in _bubbles:
		var other: NpcState = sim.npcs[id]
		if other != npc and other.pos.distance_to(npc.pos) < BUBBLE_SPACING:
			if (_bubbles[id] as SpeechBubble).is_busy():
				return true
	return false


func _speak(npc: NpcState, text: String) -> void:
	if not _bubbles.has(npc.id) or dialogue.npc == npc or _crowded(npc):
		return
	if npc.pos.distance_to(level.player.global_position) <= HEAR_RANGE:
		(_bubbles[npc.id] as SpeechBubble).say(text, Color.BLACK, BUBBLE_TIME)


func _on_npc_died(npc: NpcState) -> void:
	var guard: Variant = citizens.get(npc.id)
	if is_instance_valid(guard):
		(guard as Guard).die_quietly()


func _on_rumor_told(teller: String, hearer: String, event_id: int) -> void:
	var said: Dictionary = (sim.npcs[hearer] as NpcState).beliefs[str(event_id)]
	_speak(sim.npcs[teller], sim.rumors.phrase(sim, said))


func _on_event_staged(entry: Dictionary) -> void:
	var place: Vector2 = Vector2(float(entry["x"]), float(entry["y"]))
	for id: String in entry["actors"]:
		var guard: Variant = citizens.get(id)
		if is_instance_valid(guard) and not (guard as Guard).is_alert():
			(guard as Guard).investigate(place)


## Las IAs dicen lo que ven, sin explicar la causa. Si nadie mira, se descubrirá después.
func _on_event_happened(record: Dictionary) -> void:
	var at: Vector2 = Vector2(float(record["px"]), float(record["py"]))
	var observe: String = sim.events.catalog[record["type"]]["observe"]
	var seen: bool = level.player.global_position.distance_to(at) <= SEE_RANGE
	if seen and not observe.is_empty():
		level.ai.say_custom(observe)
	if sim.npcs.has(record["actors"][0]):
		_speak(sim.npcs[record["actors"][0]], sim.events.text_for(record["type"], record))


func _build_festival_view(added: Array) -> void:
	_decor = FestivalDecor.new()
	level.actors.add_child(_decor)
	_refresh_decor()
	for trace: Dictionary in sim.festivals.traces:
		var item: Interactable = Interactable.new()
		item.setup(ID_TRACE + str(trace["id"]), Interactable.Kind.EVIDENCE, Vector2(float(trace["x"]), float(trace["y"])))
		item.custom_label = tr("LIVE_TRACE_LABEL")
		item.custom_color = FestivalDecor.COLOR_RUIN
		item.reusable = true
		item.activated.connect(level.on_item_activated)
		level.actors.add_child(item)
	if not added.is_empty():
		level.ai.say_custom("%s: %s" % [added[-1]["name"], added[-1]["text"]])
	if sim.festivals.is_running():
		level.ai.say_custom(tr("LIVE_TODAY_FEST") % sim.festivals.current["name"])


func _refresh_decor() -> void:
	var festivals: FestivalSystem = sim.festivals
	_decor.visible = festivals.is_running()
	if festivals.is_running():
		_decor.show_at(festivals.spot, festivals.current["name"], festivals.ruined)


func _read_trace(item: Interactable) -> void:
	for trace: Dictionary in sim.festivals.traces:
		if ID_TRACE + str(trace["id"]) == item.item_id:
			trace["read"] = true
			level.ai.bubble.say("%s: %s" % [trace["name"], trace["text"]], Color.WHITE, 6.0)


func _ask_trace() -> void:
	var trace: Dictionary = sim.festivals.traces[-1]
	dialogue.reply("Eso fue %s. Tú no estabas, claro." % trace["name"])


func _join_festival() -> void:
	sim.festivals.join(sim)
	dialogue.reply(tr("LIVE_JOINED"))


func _do_mission(id: int, action: String) -> void:
	var was: Dictionary = sim.missions._by_id(id)
	var text: String = sim.missions.perform(sim, id, action)
	if action == "entregar":
		level.reward_piece()
	if was["state"] == "cerrada":
		_remove_mission_item(ID_LOST + str(id))
	if action == "bronca" and _is_between_species(was):
		provoke_battle(text)
		return
	dialogue.reply(text)


func _is_between_species(mission: Dictionary) -> bool:
	var teller: NpcState = sim.npcs[mission["teller"]]
	var target: NpcState = sim.npcs[mission["target"]]
	return teller.species != target.species


## Malmeter entre razas acaba a golpes: estalla la batalla entre los dos bandos.
func provoke_battle(text: String) -> void:
	var speaker: NpcState = dialogue.npc
	dialogue.close()
	say_from(speaker, text)
	level.battles.begin()


func _on_mission_changed(mission: Dictionary) -> void:
	if mission["stage"] == "sin_contar" and mission["state"] == "abierta":
		_show_mission_item(mission)
		var teller: NpcState = sim.npcs[mission["teller"]]
		if teller.pos.distance_to(level.player.global_position) <= SEE_RANGE:
			level.ai.say_custom(sim.missions.hint(mission))
	if mission["state"] == "cerrada":
		_remove_mission_item(ID_LOST + str(int(mission["id"])))


func _show_mission_item(mission: Dictionary) -> void:
	if mission["template"] != "pertenencia" or mission["stage"] == "recogido":
		return
	var id: String = ID_LOST + str(int(mission["id"]))
	if _mission_items.has(id):
		return
	var item: Interactable = Interactable.new()
	item.setup(id, Interactable.Kind.EVIDENCE, Vector2(float(mission["x"]), float(mission["y"])))
	item.custom_label = sim.missions.templates["pertenencia"]["item"]
	item.custom_color = FestivalDecor.COLOR_LOST
	item.activated.connect(level.on_item_activated)
	level.actors.add_child(item)
	_mission_items[id] = item


func _remove_mission_item(id: String) -> void:
	if _mission_items.has(id):
		(_mission_items[id] as Interactable).queue_free()
		_mission_items.erase(id)


func _check_player_missions() -> void:
	var feet: Vector2 = level.player.global_position
	var mission: Dictionary = sim.missions.player_at(sim, feet)
	if not mission.is_empty():
		level.ai.say_custom(sim.missions.done_text(mission))
		var species: Array = sim.species_data[(sim.npcs[mission["teller"]] as NpcState).species]["lore"]
		level.ai.say_custom(str((species[0] as Dictionary)["text"]))


## Quien tiene un problema te llama si pasas cerca. No hay marcadores.
func _call_player(delta: float) -> void:
	_call_time -= DIRECT_INTERVAL
	if _call_time > 0.0:
		return
	var _unused: float = delta
	for mission: Dictionary in sim.missions.open_missions():
		var teller: NpcState = sim.npcs[mission["teller"]]
		if mission["stage"] == "sin_contar" and teller.pos.distance_to(level.player.global_position) <= CALL_RANGE:
			_speak(teller, "¡Eh, tú, el de los brazos!")
			_call_time = CALL_INTERVAL
			return


func _on_noise(origin: Vector2, radius: float) -> void:
	if _festival_running() and radius >= FEST_NOISE and origin.distance_to(sim.festivals.spot) <= FEST_RANGE:
		sim.festivals.ruin(sim)
		_refresh_decor()
