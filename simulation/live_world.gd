class_name LiveWorld
extends Node
## Une la simulación lógica con la escena: pone a cada habitante en el mapa y le da órdenes.

const DIRECT_INTERVAL: float = 1.0
const HEAR_RANGE: float = 620.0
const LABEL_RANGE: float = 170.0
const BUBBLE_TIME: float = 3.2
const WANDER_CHANCE: float = 0.08

var level: BetaZone
var sim: WorldSim = WorldSim.new()
var dialogue: LiveDialogue
var citizens: Dictionary = {}
var started: bool = false

var _talk_items: Dictionary = {}
var _bubbles: Dictionary = {}
var _direct_time: float = 0.0


func _ready() -> void:
	dialogue = LiveDialogue.new()
	dialogue.world = self
	add_child(dialogue)


func start(data: Dictionary) -> void:
	sim.spawn_areas = {"jubilado": BetaLayout.JUB_HOME, "mohocrata": BetaLayout.MOHO_HOME}
	sim.open_spots = BetaLayout.OPEN_SPOTS
	sim.start(level.rng.seed, data)
	for id: String in sim.npc_ids:
		if (sim.npcs[id] as NpcState).alive:
			_show_citizen(sim.npcs[id])
	sim.npc_added.connect(_show_citizen)
	sim.npc_died.connect(_on_npc_died)
	sim.rumor_told.connect(_on_rumor_told)
	sim.event_happened.connect(_on_event_happened)
	started = true


func _physics_process(delta: float) -> void:
	if not started or get_tree().paused:
		return
	sim.tick(delta)
	_direct_time -= delta
	if _direct_time <= 0.0:
		_direct_time = DIRECT_INTERVAL
		_direct_all()


func to_dict() -> Dictionary:
	_sync_positions()
	return sim.to_dict()


func bubble_of(id: String) -> SpeechBubble:
	return _bubbles[id]


func handles_item(item: Interactable) -> bool:
	if not sim.npcs.has(item.item_id):
		return false
	var npc: NpcState = sim.npcs[item.item_id]
	if npc.alive and not dialogue.is_open():
		dialogue.open(npc)
	return true


## Opciones que añaden otros sistemas, como las misiones.
func extra_options(_npc: NpcState) -> Array:
	return []


## Un habitante ha caído o se ha convertido por lo que sea.
func on_citizen_gone(id: String) -> void:
	if sim.npcs.has(id):
		sim.kill(id)


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
	item.show_label = false
	item.reusable = true
	item.activated.connect(level._on_item_activated)
	guard.add_child(item)
	_talk_items[npc.id] = item
	var bubble: SpeechBubble = SpeechBubble.new()
	bubble.position = Vector2(0.0, -120.0)
	bubble.visible = false
	guard.add_child(bubble)
	_bubbles[npc.id] = bubble


func _direct_all() -> void:
	_sync_positions()
	var feet: Vector2 = level.player.global_position
	var festival: bool = _festival_running()
	for id: String in citizens:
		if not is_instance_valid(citizens[id]) or not (sim.npcs[id] as NpcState).alive:
			continue
		var npc: NpcState = sim.npcs[id]
		var guard: Guard = citizens[id]
		_update_label(id, npc.pos.distance_to(feet))
		if guard.state in [Guard.State.PATROL, Guard.State.WAIT, Guard.State.LOOK_AROUND]:
			_direct(npc, guard, Motivation.choose(sim, npc, festival))


func _festival_running() -> bool:
	return false


func _update_label(id: String, distance: float) -> void:
	var item: Interactable = _talk_items[id]
	var near: bool = distance <= LABEL_RANGE
	if item.show_label != near:
		item.show_label = near
		item.queue_redraw()


func _direct(npc: NpcState, guard: Guard, activity: String) -> void:
	npc.activity = activity
	match activity:
		"cotillear":
			var target: NpcState = _nearest_unaware(npc)
			if target != null:
				guard.investigate(target.pos)
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


func _speak(npc: NpcState, text: String) -> void:
	if not _bubbles.has(npc.id) or dialogue.npc == npc:
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


func _on_event_happened(_record: Dictionary) -> void:
	pass
