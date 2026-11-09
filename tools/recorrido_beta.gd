extends SceneTree
## Juega la beta de verdad, sin atajos de posición ni enemigos apagados, sin pegar a nadie.
## RUTA: sigilo, palabra o fuerza. SEMILLA fija la partida. Imprime lo que ha ido pasando.

const SPEED: float = 3.0
const WALK_LIMIT: float = 120.0

var zone: BetaZone
var fights: int = 0
var log_lines: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://recorrido.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = int(OS.get_environment("SEMILLA")) if OS.has_environment("SEMILLA") else 7
	BattleDirector.auto_start = false
	if OS.has_environment("FECHA"):
		WorldCalendar.forced_local_unix = int(OS.get_environment("FECHA"))
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.0).timeout
	zone = current_scene as BetaZone
	zone.fight.pre_fight_started.connect(_on_fight_phase.bind(1))
	Engine.time_scale = SPEED
	zone.player.set_crouching(true)
	match OS.get_environment("RUTA"):
		"palabra":
			await _ruta_palabra()
		"fuerza":
			await _ruta_fuerza()
		"mision":
			await _ruta_mision()
		"fiesta":
			await _ruta_fiesta()
		_:
			await _ruta_sigilo()
	_report()
	Engine.time_scale = 1.0
	SaveSystem.delete_all()
	quit()


func _ruta_sigilo() -> void:
	await _find_ramon()
	await _go(Vector2(2580.0, 590.0))
	await _go(Vector2(2580.0, 730.0))
	await _go(Vector2(2580.0, 590.0))
	await _go_and_use(BetaZone.ID_REEL)
	await _leave_depot()
	await _go(BetaLayout.CROSSING_GOAL.get_center())


func _ruta_palabra() -> void:
	await _go_near(zone.investigation.npc_nodes["panel"])
	_case().open_dialogue("panel")
	_say("21:00")
	await _go(BetaLayout.CENTRAL_INSIDE.get_center())
	for id: String in ["e_etiqueta", "e_acta"]:
		await _go(_evidence_at(id), 90.0)
		_case().examine(id)
	await _go_near(zone.investigation.npc_nodes["seta"])
	_case().open_dialogue("seta")
	_say("es correo")
	_say("Gracias")
	await _go_near(zone.investigation.npc_nodes["paca"])
	_case().open_dialogue("paca")
	_say("cruzar la tierra")
	_say("repuesto")
	_say("Gracias")
	await _go(BetaLayout.CROSSING_GOAL.get_center())
	await _go_near(zone.investigation.npc_nodes["eusebio"])
	await _find_ramon()


func _ruta_fuerza() -> void:
	await _go_and_use(BetaZone.ID_MINE)
	await _go_and_use(BetaZone.ID_CRACK)
	await _go(BetaLayout.CENTRAL_INSIDE.get_center())
	await _go_and_use(BetaZone.ID_GENERATOR)
	await _wait(6.0)
	await _find_ramon()
	await _go_and_use(BetaZone.ID_REEL)
	await _leave_depot()
	await _go(BetaLayout.CROSSING_GOAL.get_center())


func _ruta_mision() -> void:
	var sim: WorldSim = zone.live_world.sim
	var teller: NpcState = sim.alive_of("jubilado")[0]
	var near: Vector2 = zone.player.global_position + Vector2(120.0, 0.0)
	sim.events.report(sim, "sombrero_perdido", teller.id, "", near + Vector2(200.0, 40.0))
	var open: Array = sim.missions.open_missions()
	log_lines.append("misiones abiertas: %d" % open.size())
	var mission: Dictionary = open[0]
	await _go_near_node(zone.live_world.citizens[mission["teller"]])
	zone.live_world.dialogue.open(sim.npcs[mission["teller"]])
	await _choose_live("qué te pasa")
	zone.live_world.dialogue.close()
	var item: Interactable = zone.live_world._mission_items.values()[0]
	await _go_near_node(item)
	item.activate()
	await _go_near_node(zone.live_world.citizens[mission["teller"]])
	var before: int = _pickups()
	zone.live_world.dialogue.open(sim.npcs[mission["teller"]])
	await _choose_live("toma, lo tuyo")
	zone.live_world.dialogue.close()
	await _tick(0.5)
	log_lines.append("misión: %s, resultado %s, recompensas nuevas %d" % [
		mission["state"], mission.get("result", "?"), _pickups() - before
	])


func _ruta_fiesta() -> void:
	var sim: WorldSim = zone.live_world.sim
	log_lines.append("fiesta en marcha: %s" % sim.festivals.is_running())
	await _go(sim.festivals.spot + Vector2(-200.0, 120.0))
	zone.noise_bus.emit_noise(sim.festivals.spot, 800.0)
	await _wait(1.0)
	log_lines.append("fiesta reventada: %s, días arruinados %s, tensión con ella %s" % [
		sim.festivals.ruined, sim.festivals.ruined_days, sim.player_standing
	])


func _find_ramon() -> void:
	var limit: float = WALK_LIMIT
	while limit > 0.0 and not _case().has_flag(BetaChallenges.FIND) and not zone.player.body.is_dead:
		if is_instance_valid(zone.ramon):
			zone.player.set_path(zone.nav.find_path(zone.player.global_position, zone.ramon.global_position))
		await _tick(1.0)
		limit -= 1.0


func _leave_depot() -> void:
	await _go(BetaLayout.DEPOT.position + Vector2(-60.0, -60.0))


func _go_and_use(id: String) -> void:
	await _go_near_node(zone.items[id])
	(zone.items[id] as Interactable).activate()
	await _tick(0.3)
	log_lines.append("usado: %s" % id)


func _go_near(node: Variant) -> void:
	await _go_near_node(node as Node2D)


func _go_near_node(node: Node2D) -> void:
	await _go(node.global_position + Vector2(0.0, 60.0), 90.0)


func _go(point: Vector2, tolerance: float = 30.0) -> void:
	var limit: float = WALK_LIMIT
	zone.player.set_path(zone.nav.find_path(zone.player.global_position, point))
	while limit > 0.0 and zone.player.global_position.distance_to(point) > tolerance and not zone.player.body.is_dead:
		if not zone.player.has_path():
			zone.player.set_path(zone.nav.find_path(zone.player.global_position, point))
		await _tick(0.25)
		limit -= 0.25
	if limit <= 0.0:
		log_lines.append("NO LLEGA a %s; se queda en %s" % [point, zone.player.global_position])


func _wait(seconds: float) -> void:
	await _tick(seconds)


## Atiende lo que interrumpe: panel previo a la pelea, encuentros y ofertas de batalla.
func _tick(seconds: float) -> void:
	await create_timer(seconds, true, false, true).timeout
	if zone.panel.is_open:
		zone.panel.close()
	if not _case().current_node.is_empty() and _case().answer_time_left > 0.0:
		_case().choose(0)


func _choose_live(word: String) -> void:
	await process_frame
	var dialogue: LiveDialogue = zone.live_world.dialogue
	for option: Array in dialogue._options:
		if (option[0] as String).to_lower().contains(word):
			(option[1] as Callable).call()
			return
	log_lines.append("sin opción «%s» entre %s" % [word, dialogue._options.map(func(o: Array) -> String: return o[0])])


func _say(text: String) -> void:
	var options: Array = _case().available_options(_case().current_node)
	for index: int in range(options.size()):
		if (options[index]["text"] as String).contains(text):
			_case().choose(index)
			return
	log_lines.append("sin opción: %s" % text)


func _evidence_at(id: String) -> Vector2:
	for entry: Dictionary in _case().case_data["evidence"]:
		if entry["id"] == id:
			return Vector2(float(entry["pos"][0]), float(entry["pos"][1]))
	return zone.player.global_position


func _case() -> InvestigationDirector:
	return zone.investigation


func _pickups() -> int:
	return zone.player.body.spare_count()


func _on_fight_phase(_phase: int) -> void:
	fights += 1


func _report() -> void:
	var done: Array[String] = []
	for id: String in BetaChallenges.ALL_CHALLENGES:
		if _case().has_flag(id):
			done.append(id)
	for line: String in log_lines:
		print("  ", line)
	var worn: float = 0.0
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = zone.player.body.equipped(slot as ModularBody.Slot)
		worn += 100.0 if piece == null else 100.0 - piece.durability
	print("RESULTADO ruta=%s retos=%s muerto=%s caidos=%d cambios_pelea=%d desgaste=%.0f pos=%s" % [
		OS.get_environment("RUTA"), done, zone.player.body.is_dead, zone.fallen_ids.size(), fights, worn, zone.player.global_position
	])
