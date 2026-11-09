extends SceneTree
## Reproduce el encuentro con un grupo y la respuesta que lo manda a otra zona. GRUPO: cuadrilla_moho o patrulla_jub.

const FRAMES: Array[float] = [0.2, 1.0, 2.0, 4.0, 7.0]

var zone: BetaZone
var out: String = ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://desvio.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 7
	BetaZone.forced_hour = 12
	BattleDirector.auto_start = false
	out = OS.get_environment("SALIDA")
	var id: String = OS.get_environment("GRUPO") if OS.has_environment("GRUPO") else "cuadrilla_moho"
	change_scene_to_file("res://scenes/beta/beta_zone.tscn")
	await create_timer(1.5).timeout
	zone = current_scene as BetaZone
	zone.set_enemies_active(false)
	var item: Interactable = zone.investigation.npc_nodes[id]
	zone.player.global_position = item.global_position + Vector2(-110.0, 60.0)
	var waited: float = 0.0
	while zone.investigation.current_node.is_empty() and waited < 5.0:
		await create_timer(0.1, true, false, true).timeout
		waited += 0.1
	print("ENCUENTRO nodo=%s en %s" % [zone.investigation.current_node, item.global_position])
	await _shot(id + "_0_pregunta")
	zone.investigation.choose(1)
	print("RESPUESTA elegida: desviada=%s" % zone.challenges.flag(("moho" if id == "cuadrilla_moho" else "jub") + "_desviada"))
	var last: float = 0.0
	for at: float in FRAMES:
		await create_timer(at - last, true, false, true).timeout
		last = at
		print("+%.1f s posicion=%s visible=%s usado=%s" % [at, item.global_position, item.visible, item.used])
		await _shot("%s_%s" % [id, str(at).replace(".", "_")])
	SaveSystem.delete_all()
	quit()


func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/%s.png" % [out, label])
