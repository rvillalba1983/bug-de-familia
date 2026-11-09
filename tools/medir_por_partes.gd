extends SceneTree
## Mide en la zona beta real cuánto cuesta cada parte, apagándolas de una en una.
## Con ventana (mide también el dibujo): xvfb-run ... godot --rendering-driver opengl3 --path . -s tools/medir_por_partes.gd
## Variables: NOCHE=1 fuerza la noche y EXTRA añade personajes. Con gráfica software solo valen las proporciones.

const SETTLE: float = 1.0
const SAMPLES: int = 60
const CASES: Array[String] = ["todo", "sin_filtro", "sin_conos", "sin_anim", "sin_dibujo_personajes", "sin_ambiente", "nada"]
const SPOT: Vector2 = Vector2(1500.0, 620.0)

var zone: BetaZone
var _rigs: Array[Node] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://medir_partes.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 77
	BattleDirector.auto_start = false
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.5).timeout
	zone = current_scene as BetaZone
	var extra: int = int(OS.get_environment("EXTRA")) if OS.has_environment("EXTRA") else 0
	for index: int in range(extra):
		zone.live_world.sim.spawn("jubilado" if index % 2 == 0 else "mohocrata", SPOT + Vector2(float(index) * 25.0, 200.0), "nacido")
	zone.set_enemies_active(true)
	zone.player.process_mode = Node.PROCESS_MODE_DISABLED
	zone.player.global_position = SPOT
	for guard: Guard in zone.guards():
		if guard.detector.detected.is_connected(guard._on_detected):
			guard.detector.detected.disconnect(guard._on_detected)
	for node: Node in zone.find_children("*", "BetaAtmosphere", true, false):
		var atmosphere: BetaAtmosphere = node
		atmosphere.hour_source = func() -> int: return 23 if OS.has_environment("NOCHE") else 12
		atmosphere._apply_hour()
	await create_timer(2.0).timeout
	print("MEDIDA personajes=%d noche=%s pausa=%s" % [zone.guards().size(), OS.has_environment("NOCHE"), paused])
	var base: float = 0.0
	for name: String in CASES:
		_apply(name)
		await create_timer(SETTLE).timeout
		var result: Array[float] = await _sample()
		if name == "todo":
			base = result[0]
		print("MEDIDA %-22s fotograma=%7.2f ms (%+7.2f) fisica=%5.2f proceso=%5.2f draw_calls=%4d objetos=%5d" % [name, result[0], result[0] - base, result[1], result[2], int(result[3]), int(result[4])])
	_apply("todo")
	if OS.has_environment("CAPAS"):
		await _layers()
	SaveSystem.delete_all()
	quit()


## Oculta cada hijo directo de la escena para ver de dónde salen las llamadas de dibujo.
func _layers() -> void:
	for child: Node in zone.get_children():
		var item: Variant = child
		if not (child is CanvasItem or child is CanvasLayer) or not item.visible or child.get_child_count() == 0:
			continue
		item.visible = false
		await process_frame
		var result: Array[float] = await _sample()
		print("CAPA %-26s %-14s hijos=%4d fotograma=%7.2f draw_calls=%4d objetos=%5d" % [child.name, child.get_class(), child.get_child_count(), result[0], int(result[3]), int(result[4])])
		item.visible = true


func _apply(name: String) -> void:
	_set_filter(name != "sin_filtro" and name != "nada")
	VisionConeView.measuring_off = name == "sin_conos" or name == "nada"
	_set_anim(name != "sin_anim" and name != "nada")
	_set_chars_drawn(name != "sin_dibujo_personajes" and name != "nada")
	_set_ambient(name != "sin_ambiente" and name != "nada")


func _set_filter(on: bool) -> void:
	for node: Node in zone.find_children("*", "ScreenFilter", true, false):
		(node as ScreenFilter).visible = on


func _set_anim(on: bool) -> void:
	for guard: Guard in zone.guards():
		if guard.visual.rig != null:
			for child: Node in guard.visual.rig.get_parent().get_children():
				(child as EnemyRig).player.active = on


func _set_chars_drawn(on: bool) -> void:
	for guard: Guard in zone.guards():
		if guard.visual.rig != null:
			guard.visual.rig.get_parent().visible = on


func _set_ambient(on: bool) -> void:
	for node: Node in zone.find_children("*", "BetaAmbient", true, false):
		(node as CanvasItem).visible = on
		node.set_process(on)
	for node: Node in zone.find_children("*", "BetaAtmosphere", true, false):
		for child: Node in node.get_children():
			if child is Light2D:
				(child as Light2D).visible = on
			elif child is GPUParticles2D:
				(child as GPUParticles2D).visible = on


func _sample() -> Array[float]:
	var physics: float = 0.0
	var process: float = 0.0
	var calls: float = 0.0
	var objects: float = 0.0
	await process_frame
	var start: int = Time.get_ticks_usec()
	for _index: int in range(SAMPLES):
		await process_frame
		physics += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0
		process += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		calls += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
		objects += Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var count: float = float(SAMPLES)
	return [float(Time.get_ticks_usec() - start) / 1000.0 / count, physics / count, process / count, calls / count, objects / count]
