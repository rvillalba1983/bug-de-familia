extends Node
## Mide la zona beta real en el juego exportado o en el editor. Se arranca como escena principal
## (ver docs/adr/0016 y docs/adr/0017). CASO: ciudad, noche, caminando, pelea, pausa o batalla.
## EXTRA añade personajes. RONDA etiqueta la pasada y CAPTURA guarda una imagen al terminar.
## QUITAR apaga una parte para ver lo que cuesta: filtro, mundo, actores, interfaz, ambiente,
## particulas, protagonista, personajes, paredes, objetos, fachadas, conos o 720p.

const SETTLE: float = 3.0
const SAMPLES: int = 150
const SPOT: Vector2 = Vector2(1500.0, 620.0)
const ZONE_PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"
const WALK_ROUTE: PackedVector2Array = [Vector2(1300.0, 1320.0), Vector2(2800.0, 1320.0)]
const FIGHTERS: int = 6
const FIGHT_RING: float = 70.0

var _walked: float = 0.0
var _last_position: Vector2 = SPOT
var _fighters: Array[Guard] = []
var _panel_opened: bool = false


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var mode: String = OS.get_environment("CASO")
	SaveSystem.path = "user://medir_exportado.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 77
	BattleDirector.auto_start = false
	if OS.has_environment("ESCALA"):
		CharacterScale.value = float(OS.get_environment("ESCALA"))
	DespliegueCeroZone.forced_hour = 23 if mode == "noche" else 12
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var started: int = Time.get_ticks_usec()
	var zone: DespliegueCeroZone = (load(ZONE_PATH) as PackedScene).instantiate()
	get_tree().root.add_child(zone)
	await get_tree().process_frame
	var load_ms: float = (Time.get_ticks_usec() - started) / 1000.0
	_prepare(zone)
	await _start_case(zone, mode)
	var removed: String = OS.get_environment("QUITAR")
	_remove_part(zone, removed)
	await _settle(zone, mode)
	_walked = 0.0
	var frames: Array[float] = []
	var physics: Array[float] = []
	var process: Array[float] = []
	var last: int = Time.get_ticks_usec()
	for _index: int in range(SAMPLES):
		await get_tree().process_frame
		_keep_case_running(zone, mode)
		var now: int = Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
		process.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	var line: String = "RESULTADO %s quitar=%s ronda=%s ventana=%s personajes=%d carga_ms=%.0f fotograma_media=%.2f fotograma_mediana=%.2f fotograma_p99=%.2f fisica_media=%.2f proceso_medio=%.2f memoria_mb=%.0f draw_calls=%.0f recorrido_px=%.0f en_alerta=%d panel_interrumpe=%s driver=%s lista_angle=%d api=%s grafica=%s" % [
		mode, removed, OS.get_environment("RONDA"), get_window().size, zone.guards().size(), load_ms,
		_mean(frames), _median(frames), _p99(frames), _mean(physics), _mean(process),
		Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		_walked, _alert_count(), _panel_opened, RenderingServer.get_current_rendering_driver_name(),
		(ProjectSettings.get_setting("rendering/gl_compatibility/force_angle_on_devices") as Array).size(),
		RenderingServer.get_video_adapter_api_version(), RenderingServer.get_video_adapter_name(),
	]
	print(line)
	_append_to_report(line)
	_save_capture()
	SaveSystem.delete_all()
	get_tree().quit()


func _remove_part(zone: DespliegueCeroZone, part: String) -> void:
	match part:
		"filtro":
			zone.screen_filter.visible = false
		"mundo":
			zone.visible = false
		"actores":
			zone.actors.visible = false
		"interfaz":
			for child: Node in zone.get_children():
				if child is CanvasLayer and (child as CanvasLayer).layer == 2:
					(child as CanvasLayer).visible = false
		"ambiente":
			for node: Node in zone.find_children("*", "DespliegueCeroAmbient", true, false):
				(node as CanvasItem).visible = false
		"particulas":
			for node: Node in zone.atmosphere.find_children("*", "GPUParticles2D", true, false):
				(node as CanvasItem).visible = false
		"protagonista":
			zone.player.visible = false
		"personajes":
			for guard: Guard in zone.guards():
				guard.visible = false
		"paredes":
			for node: Node in zone.actors.get_children():
				if node is Wall:
					(node as Wall).visible = false
		"objetos":
			for node: Node in zone.actors.get_children():
				if node is Interactable or node is PetanqueMine or node is WorldProp:
					(node as CanvasItem).visible = false
		"fachadas":
			for node: Node in zone.actors.get_children():
				if node is BuildingFacade:
					(node as CanvasItem).visible = false
		"conos":
			zone.ground.visible = false
		"720p":
			get_window().size = Vector2i(1280, 720)


## En Windows no hay consola: el resultado queda en medicion.txt, junto al ejecutable.
func _append_to_report(line: String) -> void:
	var path: String = OS.get_executable_path().get_base_dir().path_join("medicion.txt")
	var file: FileAccess = FileAccess.open(path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("%s: no se puede escribir" % path)
		return
	file.seek_end()
	file.store_line(line)


func _prepare(zone: DespliegueCeroZone) -> void:
	var extra: int = int(OS.get_environment("EXTRA")) if OS.has_environment("EXTRA") else 0
	for index: int in range(extra):
		var species: String = "jubilado" if index % 2 == 0 else "mohocrata"
		zone.live_world.sim.spawn(species, SPOT + Vector2(float(index) * 25.0, 200.0), "nacido")
	zone.player.process_mode = Node.PROCESS_MODE_DISABLED
	zone.player.global_position = SPOT
	for guard: Guard in zone.guards():
		guard.set_passive(true)


func _start_case(zone: DespliegueCeroZone, mode: String) -> void:
	if mode == "pausa":
		zone.pause.set_paused(true)
	elif mode == "caminando":
		zone.player.global_position = WALK_ROUTE[0]
		_last_position = WALK_ROUTE[0]
		zone.player.process_mode = Node.PROCESS_MODE_INHERIT
	elif mode == "pelea":
		await _start_fight(zone)
	elif mode == "batalla":
		zone.battles.begin()
		await get_tree().create_timer(0.3, true, false, true).timeout
		zone.battles.choose(2)


## Espera a que el caso se asiente, manteniéndolo en marcha.
func _settle(zone: DespliegueCeroZone, mode: String) -> void:
	var finish: int = Time.get_ticks_msec() + int(SETTLE * 1000.0)
	while Time.get_ticks_msec() < finish:
		await get_tree().process_frame
		_keep_case_running(zone, mode)


func _keep_case_running(zone: DespliegueCeroZone, mode: String) -> void:
	if mode == "caminando":
		_keep_walking(zone)
	elif mode == "pelea":
		_keep_fighting(zone)
	_walked += zone.player.global_position.distance_to(_last_position)
	_last_position = zone.player.global_position


func _keep_walking(zone: DespliegueCeroZone) -> void:
	var player: Player = zone.player
	_heal(player)
	if player.has_path():
		return
	var at_end: bool = player.global_position.distance_to(WALK_ROUTE[1]) < FIGHT_RING
	var target: Vector2 = WALK_ROUTE[0] if at_end else WALK_ROUTE[1]
	player.set_path(zone.nav.find_path(player.global_position, target))


## Pelea real con varios habitantes alrededor. Nadie muere, para que dure toda la medición.
func _start_fight(zone: DespliegueCeroZone) -> void:
	zone.player.process_mode = Node.PROCESS_MODE_INHERIT
	var people: Array = zone.live_world.citizens.values()
	for index: int in range(mini(FIGHTERS, people.size())):
		var person: Guard = people[index]
		var angle: float = TAU * float(index) / float(FIGHTERS)
		person.global_position = SPOT + Vector2.from_angle(angle) * FIGHT_RING
		person.set_passive(false)
		_fighters.append(person)
	_heal(zone.player)
	await get_tree().physics_frame
	_fighters[0].take_damage(1.0)
	await get_tree().process_frame
	zone.panel.close()
	zone.fight.confirm_pre_fight()
	zone.combat.engage(_fighters[0])


func _keep_fighting(zone: DespliegueCeroZone) -> void:
	_heal(zone.player)
	if zone.panel.is_open:
		_panel_opened = true
		zone.panel.close()
	for person: Guard in _fighters:
		person.health = Guard.MAX_HEALTH
		if not person.is_alert():
			person.join_fight()
	if zone.combat.target == null:
		zone.combat.engage(_fighters[0])


## El sobrante evita que varios golpes en un mismo fotograma lento rompan una pieza.
func _heal(player: Player) -> void:
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = player.body.equipped(slot as ModularBody.Slot)
		if piece != null:
			piece.durability = BodyPiece.MAX_DURABILITY * 10.0


func _alert_count() -> int:
	var count: int = 0
	for person: Guard in _fighters:
		if person.is_alert():
			count += 1
	return count


func _save_capture() -> void:
	var path: String = OS.get_environment("CAPTURA")
	if path != "":
		get_viewport().get_texture().get_image().save_png(path)


func _mean(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / float(values.size())


func _median(values: Array[float]) -> float:
	var sorted: Array[float] = values.duplicate()
	sorted.sort()
	return sorted[values.size() / 2]


func _p99(values: Array[float]) -> float:
	var sorted: Array[float] = values.duplicate()
	sorted.sort()
	return sorted[int(values.size() * 0.99)]
