extends GdUnitTestSuite
## Un bot resuelve el reto de tres formas sin que empiece ninguna pelea.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"
const MAX_FRAMES: int = 3600

var sandbox: Sandbox
var alerts: int = 0


func before_test() -> void:
	TestSupport.reset_session()
	Engine.time_scale = 6.0
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	sandbox = runner.scene()
	alerts = 0
	sandbox.guard.alert_started.connect(func() -> void: alerts += 1)


func after_test() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false


func test_route_low_cover() -> void:
	sandbox.player.set_crouching(true)
	await _walk_path([Vector2(700.0, 850.0), Vector2(930.0, 820.0)])
	await _until(_guard_going_north_past.bind(620.0))
	sandbox.player.set_crouching(false)
	await _walk_path([Vector2(990.0, 640.0), Vector2(1090.0, 550.0)])
	await _walk_path([SandboxLayout.GOAL.get_center()])
	_assert_solved()


func test_route_noise_lure() -> void:
	sandbox.player.set_crouching(true)
	await _walk_path([Vector2(410.0, 850.0)])
	await _until(func() -> bool: return sandbox.guard.global_position.y > 650.0)
	await _press(&"interact")
	assert_int(sandbox.guard.state).is_equal(Guard.State.INVESTIGATE)
	await _walk_path([Vector2(420.0, 950.0), Vector2(780.0, 950.0)])
	await _until(func() -> bool: return sandbox.guard.global_position.x < 640.0)
	sandbox.player.set_crouching(false)
	await _walk_path([Vector2(770.0, 715.0), Vector2(1000.0, 640.0), Vector2(1090.0, 550.0)])
	await _walk_path([SandboxLayout.GOAL.get_center()])
	_assert_solved()


func test_route_service_door() -> void:
	await _walk_path([Vector2(215.0, 300.0), Vector2(380.0, 290.0)])
	await _until(_camera_pointing_north)
	await _walk_path([Vector2(530.0, 275.0)])
	await _press(&"interact")
	await await_physics(4)
	assert_bool(sandbox.door.is_open).is_true()
	await _walk_path([Vector2(980.0, 230.0), Vector2(1140.0, 220.0)])
	await _walk_path([SandboxLayout.GOAL.get_center()])
	_assert_solved()


func _assert_solved() -> void:
	assert_bool(sandbox.challenge_done).is_true()
	assert_int(alerts).is_equal(0)
	assert_bool(sandbox.player.body.is_dead).is_false()


func _guard_going_north_past(limit_y: float) -> bool:
	var going_north: bool = sandbox.guard.velocity.y < 0.0
	return going_north and sandbox.guard.global_position.y < limit_y


func _camera_pointing_north() -> bool:
	var offset: float = rad_to_deg(sandbox.security_camera.detector.facing_angle)
	return offset < -5.0


func _walk_path(points: Array[Vector2]) -> void:
	for point: Vector2 in points:
		sandbox.player.set_path(sandbox.nav.find_path(sandbox.player.global_position, point))
		for frame: int in range(MAX_FRAMES):
			if not sandbox.player.has_path():
				break
			await get_tree().physics_frame


func _until(condition: Callable) -> void:
	for frame: int in range(MAX_FRAMES):
		if condition.call():
			return
		await get_tree().physics_frame
	fail("La condición de espera no se ha cumplido")


func _press(action: StringName) -> void:
	Input.action_press(action)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release(action)


func await_physics(frames: int) -> void:
	for frame: int in range(frames):
		await get_tree().physics_frame
