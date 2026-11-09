extends GdUnitTestSuite
## Comprobaciones de la escena del primer reto.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0


func _quiet_scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func test_main_scene_is_beta() -> void:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_str(main_scene).is_equal("res://scenes/beta/beta_zone.tscn")


func test_walls_stay_inside_floor() -> void:
	for footprint: Rect2 in SandboxLayout.WALLS:
		assert_bool(SandboxLayout.FLOOR_RECT.encloses(footprint)).is_true()


func test_keyboard_moves_player_and_walls_block_it() -> void:
	var sandbox: Sandbox = _quiet_scene()
	var wall: Rect2 = SandboxLayout.WALLS[4]
	var player: Player = sandbox.player
	player.global_position = Vector2(wall.get_center().x, wall.end.y + 120.0)
	await await_physics(8)
	var start: Vector2 = player.global_position
	Input.action_press(&"move_up")
	await await_physics(120)
	Input.action_release(&"move_up")
	assert_float(player.global_position.y).is_less(start.y)
	assert_float(player.global_position.y).is_greater_equal(wall.end.y + Player.RADIUS - 2.0)


func test_click_path_reaches_goal_around_walls() -> void:
	var sandbox: Sandbox = _quiet_scene()
	var player: Player = sandbox.player
	var wall: Rect2 = SandboxLayout.WALLS[4]
	player.global_position = Vector2(wall.get_center().x, wall.end.y + 60.0)
	var goal: Vector2 = Vector2(wall.get_center().x, wall.position.y - 60.0)
	await await_physics(4)
	player.set_path(sandbox.nav.find_path(player.global_position, goal))
	for frame: int in range(900):
		if not player.has_path():
			break
		await get_tree().physics_frame
	assert_bool(player.has_path()).is_false()
	assert_float(player.global_position.distance_to(goal)).is_less(20.0)


func test_pause_stops_player_and_allows_selection() -> void:
	var sandbox: Sandbox = _quiet_scene()
	var player: Player = sandbox.player
	await await_physics(4)
	sandbox.pause.set_paused(true)
	var frozen: Vector2 = player.global_position
	Input.action_press(&"move_right")
	await await_physics(20)
	Input.action_release(&"move_right")
	var moved: float = player.global_position.distance_to(frozen)
	sandbox.selection.cycle_next()
	var selected: Selectable = sandbox.selection.current
	sandbox.pause.set_paused(false)
	assert_float(moved).is_zero()
	assert_object(selected).is_not_null()


func test_actors_are_y_sorted() -> void:
	var sandbox: Sandbox = _quiet_scene()
	assert_bool(sandbox.actors.y_sort_enabled).is_true()


func test_interface_texts_are_translated() -> void:
	assert_str(tr("UI_PAUSE")).is_equal("PAUSA TÁCTICA")


func test_running_makes_noise_but_walking_does_not() -> void:
	var sandbox: Sandbox = _quiet_scene()
	var noises: Array[float] = []
	sandbox.noise_bus.noise_emitted.connect(func(_at: Vector2, r: float) -> void: noises.append(r))
	await await_physics(4)
	Input.action_press(&"move_up")
	await await_physics(30)
	var walking_noises: int = noises.size()
	Input.action_press(&"run")
	await await_physics(30)
	Input.action_release(&"run")
	Input.action_release(&"move_up")
	assert_int(walking_noises).is_equal(0)
	assert_int(noises.size()).is_greater(0)


func test_interact_terminal_opens_door_and_route() -> void:
	var sandbox: Sandbox = _quiet_scene()
	sandbox.player.global_position = SandboxLayout.TERMINAL + Vector2(0.0, 60.0)
	await await_physics(4)
	var from: Vector2 = Vector2(980.0, 220.0)
	var to: Vector2 = Vector2(1140.0, 220.0)
	assert_float(_path_length(sandbox.nav.find_path(from, to))).is_greater(500.0)
	await _press(&"interact")
	await await_physics(4)
	assert_bool(sandbox.door.is_open).is_true()
	assert_float(_path_length(sandbox.nav.find_path(from, to))).is_less(200.0)


func test_goal_completes_challenge() -> void:
	var sandbox: Sandbox = _quiet_scene()
	sandbox.player.global_position = SandboxLayout.GOAL.get_center()
	await await_physics(4)
	assert_bool(sandbox.challenge_done).is_true()


func test_save_point_shows_saved_notice() -> void:
	var sandbox: Sandbox = _quiet_scene()
	assert_bool(sandbox.hud.saved_label.visible).is_false()
	await await_physics(4)
	sandbox.player.global_position = SandboxLayout.SAVE_POINTS[1]
	await await_physics(4)
	await await_physics(4)
	assert_bool(sandbox.hud.saved_label.visible).is_true()


func test_all_world_labels_are_translated() -> void:
	for key: String in Interactable.LABELS.values():
		if not key.is_empty():
			assert_str(tr(key)).is_not_equal(key)
	assert_str(tr("ITEM_DOOR")).is_not_equal("ITEM_DOOR")


func _path_length(path: PackedVector2Array) -> float:
	var total: float = 0.0
	for index: int in range(path.size() - 1):
		total += path[index].distance_to(path[index + 1])
	return total


func _press(action: StringName) -> void:
	Input.action_press(action)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(action)


func await_physics(frames: int) -> void:
	for frame: int in range(frames):
		await get_tree().physics_frame
