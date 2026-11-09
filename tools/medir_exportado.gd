extends Node
## Mide la zona beta real en el juego exportado o en el editor. Se arranca como escena principal
## (ver docs/adr/0016). CASO: ciudad, noche, pausa o batalla. EXTRA añade personajes.
## QUITAR apaga una parte para ver lo que cuesta: filtro, mundo, actores, interfaz, ambiente o 720p.

const SETTLE: float = 3.0
const SAMPLES: int = 150
const SPOT: Vector2 = Vector2(1500.0, 620.0)
const ZONE_PATH: String = "res://scenes/beta/beta_zone.tscn"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var mode: String = OS.get_environment("CASO")
	SaveSystem.path = "user://medir_exportado.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 77
	BattleDirector.auto_start = false
	BetaZone.forced_hour = 23 if mode == "noche" else 12
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var started: int = Time.get_ticks_usec()
	var zone: BetaZone = (load(ZONE_PATH) as PackedScene).instantiate()
	get_tree().root.add_child(zone)
	await get_tree().process_frame
	var load_ms: float = (Time.get_ticks_usec() - started) / 1000.0
	_prepare(zone)
	await _start_case(zone, mode)
	var removed: String = OS.get_environment("QUITAR")
	_remove_part(zone, removed)
	await get_tree().create_timer(SETTLE, true, false, true).timeout
	var frames: Array[float] = []
	var physics: Array[float] = []
	var process: Array[float] = []
	var last: int = Time.get_ticks_usec()
	for _index: int in range(SAMPLES):
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
		physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
		process.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	var line: String = "RESULTADO %s quitar=%s ventana=%s personajes=%d carga_ms=%.0f fotograma_media=%.2f fotograma_p99=%.2f fisica_media=%.2f proceso_medio=%.2f memoria_mb=%.0f draw_calls=%.0f grafica=%s" % [
		mode, removed, get_window().size, zone.guards().size(), load_ms, _mean(frames), _p99(frames), _mean(physics), _mean(process),
		Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_video_adapter_name(),
	]
	print(line)
	_append_to_report(line)
	SaveSystem.delete_all()
	get_tree().quit()


func _remove_part(zone: BetaZone, part: String) -> void:
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
			for node: Node in zone.find_children("*", "BetaAmbient", true, false):
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


func _prepare(zone: BetaZone) -> void:
	var extra: int = int(OS.get_environment("EXTRA")) if OS.has_environment("EXTRA") else 0
	for index: int in range(extra):
		var species: String = "jubilado" if index % 2 == 0 else "mohocrata"
		zone.live_world.sim.spawn(species, SPOT + Vector2(float(index) * 25.0, 200.0), "nacido")
	zone.player.process_mode = Node.PROCESS_MODE_DISABLED
	zone.player.global_position = SPOT
	for guard: Guard in zone.guards():
		guard.set_passive(true)


func _start_case(zone: BetaZone, mode: String) -> void:
	if mode == "pausa":
		zone.pause.set_paused(true)
	elif mode == "batalla":
		zone.battles.begin()
		await get_tree().create_timer(0.3, true, false, true).timeout
		zone.battles.choose(2)


func _mean(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / float(values.size())


func _p99(values: Array[float]) -> float:
	var sorted: Array[float] = values.duplicate()
	sorted.sort()
	return sorted[int(values.size() * 0.99)]
