extends SceneTree
## Reproduce con clics reales cómo se empieza una pelea con habitantes, solos y en grupo.
## Uso con ventana: xvfb-run ... godot --rendering-driver opengl3 --path . -s tools/probar_pelea.gd

var zone: DespliegueCeroZone


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	SaveSystem.path = "user://probar_pelea.json"
	SaveSystem.delete_all()
	Sandbox.session_started = true
	Sandbox.forced_seed = 77
	BattleDirector.auto_start = false
	change_scene_to_file("res://scenes/despliegue_cero/despliegue_cero_zone.tscn")
	await create_timer(1.5).timeout
	zone = current_scene as DespliegueCeroZone
	zone.set_enemies_active(false)
	var near: Vector2 = zone.player.global_position
	var people: Array = zone.live_world.citizens.values()
	await _case("solo, clic en los pies", [people[0]], near + Vector2(60.0, 0.0), 0.0, 0)
	await _case("solo, clic en el pecho", [people[1]], near + Vector2(60.0, 0.0), 35.0, 0)
	await _case("solo, clic en la cabeza", [people[2]], near + Vector2(60.0, 0.0), 68.0, 0)
	for aim: int in range(3):
		await _case("grupo de 3, apuntando al %d" % aim, [people[3], people[4], people[5]], near + Vector2(60.0, 0.0), 35.0, aim)
	await _reaction([people[6], people[7], people[8]], near + Vector2(60.0, 0.0))
	SaveSystem.delete_all()
	quit()


func _case(title: String, group: Array, at: Vector2, height: float, aim: int) -> void:
	zone.selection._set_current(null)
	zone.combat.disengage()
	for index: int in range(group.size()):
		var person: Guard = group[index]
		person.set_physics_process(false)
		person.global_position = at + Vector2(float(index) * 26.0, float(index % 2) * 8.0)
	await process_frame
	var victim: Guard = group[aim]
	var point: Vector2 = victim.global_position - Vector2(0.0, height)
	var screen: Vector2 = zone.get_viewport().get_canvas_transform() * point
	await _click(MOUSE_BUTTON_LEFT, screen)
	var current: Selectable = zone.selection.current
	var chosen: String = "nadie" if current == null else "persona %d" % group.find(current.get_parent())
	await _click(MOUSE_BUTTON_RIGHT, screen)
	await create_timer(0.25).timeout
	var attacked: int = group.find(zone.combat.target)
	var talking: bool = zone.live_world.dialogue.is_open()
	print("CASO %s: izquierdo selecciona a %s; derecho -> %s" % [title, chosen, "ataca a persona %d" % attacked if attacked >= 0 else ("abre conversación" if talking else "solo camina")])
	if talking:
		zone.live_world.dialogue.close()
	zone.combat.disengage()
	if zone.panel.is_open:
		zone.panel.close()
	for person: Guard in group:
		person.global_position = Vector2(200.0, 200.0)
	zone.player.set_path(PackedVector2Array())
	await create_timer(0.1).timeout


## Pega a uno de un grupo con los demás activos: ¿reacciona alguien más?
func _reaction(group: Array, at: Vector2) -> void:
	zone.selection._set_current(null)
	for index: int in range(group.size()):
		(group[index] as Guard).global_position = at + Vector2(float(index) * 60.0, 0.0)
	await process_frame
	var victim: Guard = group[0]
	victim.take_damage(10.0)
	await create_timer(1.5, true, false, true).timeout
	var alerts: Array = group.map(func(person: Guard) -> bool: return person.is_alert())
	print("CASO reacción del grupo tras golpear al 0: alerta=%s fase=%d" % [alerts, zone.fight.phase])


func _click(button: MouseButton, screen: Vector2) -> void:
	Input.warp_mouse(screen)
	await process_frame
	await process_frame
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.position = screen
	event.global_position = screen
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	await process_frame
	var up: InputEventMouseButton = event.duplicate()
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame
