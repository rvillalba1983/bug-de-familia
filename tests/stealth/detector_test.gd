extends GdUnitTestSuite

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func test_cone_geometry() -> void:
	var half: float = deg_to_rad(30.0)
	assert_bool(Detector.in_cone(Vector2.ZERO, 0.0, half, 100.0, Vector2(50.0, 0.0))).is_true()
	assert_bool(Detector.in_cone(Vector2.ZERO, 0.0, half, 100.0, Vector2(150.0, 0.0))).is_false()
	assert_bool(Detector.in_cone(Vector2.ZERO, 0.0, half, 100.0, Vector2(0.0, 50.0))).is_false()


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _visible_from(sandbox: Sandbox, origin: Vector2, detector: Detector) -> bool:
	detector.facing_angle = origin.angle_to_point(sandbox.player.global_position)
	return detector.can_see(origin, sandbox.get_world_2d(), sandbox.player)


func test_walls_block_sight() -> void:
	var sandbox: Sandbox = _scene()
	var wall: Rect2 = SandboxLayout.WALLS[4]
	sandbox.player.global_position = Vector2(wall.get_center().x, wall.end.y + 60.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var origin: Vector2 = Vector2(wall.get_center().x, wall.position.y - 100.0)
	assert_bool(_visible_from(sandbox, origin, sandbox.guard.detector)).is_false()


func test_low_cover_hides_only_when_crouching() -> void:
	var sandbox: Sandbox = _scene()
	var cover: Rect2 = SandboxLayout.LOW_COVERS[0]
	sandbox.player.global_position = Vector2(cover.get_center().x, cover.end.y + 40.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var origin: Vector2 = Vector2(cover.get_center().x, cover.position.y - 60.0)
	assert_bool(_visible_from(sandbox, origin, sandbox.guard.detector)).is_true()
	sandbox.player.set_crouching(true)
	assert_bool(_visible_from(sandbox, origin, sandbox.guard.detector)).is_false()
	assert_bool(_visible_from(sandbox, origin, sandbox.drone.detector)).is_true()


func test_meter_fills_and_fires_once() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.player.global_position = Vector2(300.0, 900.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var detector: Detector = Detector.new(300.0, 40.0, true)
	var fired: Array[Vector2] = []
	detector.detected.connect(func(at: Vector2) -> void: fired.append(at))
	var origin: Vector2 = Vector2(300.0, 800.0)
	detector.facing_angle = PI * 0.5
	for frame: int in range(240):
		detector.update(origin, sandbox.get_world_2d(), sandbox.player, 1.0 / 60.0)
	assert_float(detector.meter).is_equal(1.0)
	assert_int(fired.size()).is_equal(1)


func test_guard_investigates_noise_without_starting_fight() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.guard.global_position = Vector2(880.0, 600.0)
	await get_tree().physics_frame
	sandbox.noise_bus.emit_noise(Vector2(700.0, 600.0), 400.0)
	assert_int(sandbox.guard.state).is_equal(Guard.State.INVESTIGATE)
	assert_int(sandbox.fight.phase).is_equal(FightDirector.Phase.CALM)


func test_camera_alarm_sends_guard() -> void:
	var sandbox: Sandbox = _scene()
	await get_tree().physics_frame
	sandbox.security_camera.alarm_raised.emit(Vector2(500.0, 250.0))
	assert_int(sandbox.guard.state).is_equal(Guard.State.INVESTIGATE)


func test_guard_hit_damages_a_piece() -> void:
	var sandbox: Sandbox = _scene()
	var total_before: float = _total_durability(sandbox.player.body)
	sandbox.player.body.damage_random(float(WeaponCatalog.enemy(WeaponCatalog.ENEMY_MELEE)["damage"]), sandbox.rng)
	assert_float(_total_durability(sandbox.player.body)).is_less(total_before)


func _total_durability(body: ModularBody) -> float:
	var total: float = 0.0
	for slot: int in ModularBody.Slot.values():
		total += body.equipped(slot as ModularBody.Slot).durability
	return total
