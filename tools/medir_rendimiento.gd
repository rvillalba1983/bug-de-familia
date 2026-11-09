extends SceneTree
## Mide tiempos en la zona beta real. Uso: godot --headless --path . -s tools/medir_rendimiento.gd
## CASO: normal, pausa o batalla. Los valores son de CPU; sin gráfica real no miden el dibujo.

const SAMPLES: int = 300


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://medir.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 77
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.5).timeout
	var zone: BetaZone = current_scene as BetaZone
	var mode: String = OS.get_environment("CASO")
	var extra: int = int(OS.get_environment("EXTRA")) if OS.has_environment("EXTRA") else 0
	for index: int in range(extra):
		var species: String = "jubilado" if index % 2 == 0 else "mohocrata"
		zone.live_world.sim.spawn(species, Vector2(1500.0 + float(index) * 25.0, 1320.0), "nacido")
	if mode == "pausa":
		zone.pause.set_paused(true)
	elif mode == "batalla":
		zone.battles.begin()
		await create_timer(0.3, true, false, true).timeout
		zone.battles.choose(2)
	await create_timer(3.0, true, false, true).timeout
	var physics: Array[float] = []
	var process: Array[float] = []
	for _index: int in range(SAMPLES):
		await process_frame
		physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
		process.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
	physics.sort()
	process.sort()
	print("RESULTADO %s personajes=%d fisica_media=%.2f fisica_p99=%.2f proceso_medio=%.2f proceso_p99=%.2f" % [
		mode, zone.guards().size(), _mean(physics), physics[int(SAMPLES * 0.99)],
		_mean(process), process[int(SAMPLES * 0.99)],
	])
	SaveSystem.delete_all()
	quit()


func _mean(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / float(values.size())
