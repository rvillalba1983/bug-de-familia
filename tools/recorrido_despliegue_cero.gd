extends SceneTree
## Recorrido real del despliegue cero. RUTA: sigilo, palabra, fuerza, mision o fiesta.
## SEMILLA fija la partida.

const SPEED: float = 3.0


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
	change_scene_to_file("res://scenes/despliegue_cero/despliegue_cero_zone.tscn")
	await create_timer(1.0).timeout
	var zone: DespliegueCeroZone = current_scene as DespliegueCeroZone
	var walker: DespliegueCeroWalker = DespliegueCeroWalker.new(self, zone)
	Engine.time_scale = SPEED
	await walker.run(OS.get_environment("RUTA"))
	for line: String in walker.log_lines:
		print("  ", line)
	print("RESULTADO ruta=%s retos=%s muerto=%s caidos=%d cambios_pelea=%d desgaste=%.0f pos=%s" % [
		OS.get_environment("RUTA"), walker.completed_challenges(), zone.player.body.is_dead,
		zone.fallen_ids.size(), walker.fights, walker.total_wear(), zone.player.global_position
	])
	Engine.time_scale = 1.0
	SaveSystem.delete_all()
	quit()
