extends GdUnitTestSuite
## Comprobaciones de la escena de prueba.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func test_main_scene_is_sandbox() -> void:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_str(main_scene).is_equal(SANDBOX_PATH)


func test_walls_and_their_fronts_stay_inside_floor() -> void:
	for footprint: Rect2 in Sandbox.WALL_FOOTPRINTS:
		var visible_area: Rect2 = footprint.grow_side(SIDE_TOP, Sandbox.WALL_FRONT_HEIGHT)
		assert_bool(Sandbox.FLOOR_RECT.encloses(visible_area)).is_true()


func test_player_start_is_on_floor_and_clear_of_walls() -> void:
	assert_bool(Sandbox.FLOOR_RECT.has_point(Sandbox.PLAYER_START)).is_true()
	for footprint: Rect2 in Sandbox.WALL_FOOTPRINTS:
		assert_bool(footprint.has_point(Sandbox.PLAYER_START)).is_false()


func test_keyboard_moves_player_and_walls_block_it() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	var wall: Rect2 = Sandbox.WALL_FOOTPRINTS[2]
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
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	var player: Player = sandbox.player
	var wall: Rect2 = Sandbox.WALL_FOOTPRINTS[2]
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
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	var player: Player = sandbox.player
	await await_physics(4)
	sandbox.pause.set_paused(true)
	var frozen: Vector2 = player.global_position
	Input.action_press(&"move_right")
	await await_physics(20)
	Input.action_release(&"move_right")
	var moved: float = player.global_position.distance_to(frozen)
	sandbox.selection.cycle_next()
	var selected: SelectableDummy = sandbox.selection.current
	sandbox.pause.set_paused(false)
	assert_float(moved).is_zero()
	assert_object(selected).is_not_null()


func test_actors_are_y_sorted() -> void:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	assert_bool(sandbox.actors.y_sort_enabled).is_true()


func test_interface_texts_are_translated() -> void:
	assert_str(tr("UI_PAUSE")).is_equal("PAUSA TÁCTICA")


func await_physics(frames: int) -> void:
	for frame: int in range(frames):
		await get_tree().physics_frame
