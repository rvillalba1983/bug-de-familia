extends SceneTree
## Ejecuta la zona beta real y guarda capturas: x,y,segundos,nombre separados por espacios en
## la variable CAPTURAS. Usa una partida aparte. FECHA fija la hora local (segundos desde 1970).

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://captura_partida.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = int(OS.get_environment("SEMILLA")) if OS.has_environment("SEMILLA") else 77
	if OS.has_environment("FECHA"):
		WorldCalendar.forced_local_unix = int(OS.get_environment("FECHA"))
	var out: String = OS.get_environment("SALIDA")
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.5).timeout
	var zone: BetaZone = current_scene as BetaZone
	for shot: String in OS.get_environment("CAPTURAS").split(" ", false):
		var part: PackedStringArray = shot.split(",")
		zone.player.global_position = Vector2(part[0].to_float(), part[1].to_float())
		await create_timer(part[2].to_float(), true, false, true).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("%s/%s.png" % [out, part[3]])
		print("captura ", part[3])
	SaveSystem.delete_all()
	quit()
