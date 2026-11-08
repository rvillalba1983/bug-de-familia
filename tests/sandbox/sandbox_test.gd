extends GdUnitTestSuite
## Comprobaciones de la escena de prueba de la fase 0.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func test_main_scene_is_sandbox() -> void:
	assert_str(ProjectSettings.get_setting("application/run/main_scene") as String).is_equal(SANDBOX_PATH)


func test_sandbox_instantiates() -> void:
	var scene: PackedScene = load(SANDBOX_PATH) as PackedScene
	assert_object(scene).is_not_null()
	var sandbox: Node = auto_free(scene.instantiate())
	assert_object(sandbox).is_instanceof(Sandbox)


func test_walls_and_their_fronts_stay_inside_floor() -> void:
	for wall: Rect2 in Sandbox.WALLS:
		var with_front: Rect2 = wall.grow_side(SIDE_BOTTOM, Sandbox.WALL_FRONT_HEIGHT)
		assert_bool(Sandbox.FLOOR_RECT.encloses(with_front)).is_true()


func test_player_start_is_on_floor_and_clear_of_walls() -> void:
	assert_bool(Sandbox.FLOOR_RECT.has_point(Sandbox.PLAYER_START)).is_true()
	for wall: Rect2 in Sandbox.WALLS:
		assert_bool(wall.has_point(Sandbox.PLAYER_START)).is_false()
