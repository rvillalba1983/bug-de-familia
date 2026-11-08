extends GdUnitTestSuite

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"
const ARM: ModularBody.Slot = ModularBody.Slot.ARM_EXTRA_LEFT


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _wear(sandbox: Sandbox, id: String, active: bool, effects: Dictionary = {}) -> void:
	var piece: BodyPiece = BodyPiece.new(BodyPiece.Kind.ARM)
	piece.actions.append({"id": id, "name": id, "active": active})
	piece.effects = effects
	var body: ModularBody = sandbox.player.body
	body.add_spare(ARM, piece)
	body.swap(ARM, 0)


func test_lure_makes_noise_and_wears_piece() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a062", true)
	var noises: Array[float] = []
	sandbox.noise_bus.noise_emitted.connect(func(_at: Vector2, r: float) -> void: noises.append(r))
	assert_bool(sandbox.actions.trigger(0)).is_true()
	assert_int(noises.size()).is_equal(1)
	assert_float(sandbox.player.body.equipped(ARM).durability).is_less(BodyPiece.MAX_DURABILITY)


func test_cooldown_blocks_repeat() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a062", true)
	sandbox.actions.trigger(0)
	assert_bool(sandbox.actions.trigger(0)).is_false()


func test_stun_needs_melee_range_and_stops_guard() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a003", true)
	assert_bool(sandbox.actions.trigger(0)).is_false()
	sandbox.player.global_position = sandbox.guard.global_position + Vector2(50.0, 0.0)
	assert_bool(sandbox.actions.trigger(0)).is_true()
	assert_int(sandbox.guard.state).is_equal(Guard.State.STUNNED)


func test_hack_opens_door_when_near() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a054", true)
	assert_bool(sandbox.actions.trigger(0)).is_false()
	sandbox.player.global_position = Vector2(900.0, 220.0)
	assert_bool(sandbox.actions.trigger(0)).is_true()
	await get_tree().physics_frame
	assert_bool(sandbox.door.is_open).is_true()


func test_boost_increases_speed() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a009", true)
	var normal: float = sandbox.player.current_speed()
	sandbox.actions.trigger(0)
	assert_float(sandbox.player.current_speed()).is_greater(normal)


func test_silent_steps_remove_running_noise() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a023", false)
	var noises: Array[float] = []
	sandbox.noise_bus.noise_emitted.connect(func(_at: Vector2, r: float) -> void: noises.append(r))
	await get_tree().physics_frame
	Input.action_press(&"move_up")
	Input.action_press(&"run")
	for frame: int in range(30):
		await get_tree().physics_frame
	Input.action_release(&"run")
	Input.action_release(&"move_up")
	assert_int(noises.size()).is_equal(0)


func test_bubble_absorbs_one_hit() -> void:
	var sandbox: Sandbox = _scene()
	_wear(sandbox, "a044", false)
	var body: ModularBody = sandbox.player.body
	var before: float = _total(body)
	sandbox.player.receive_hit(34.0, sandbox.rng, null)
	assert_float(_total(body)).is_equal(before)
	sandbox.player.receive_hit(34.0, sandbox.rng, null)
	assert_float(_total(body)).is_less(before)


func test_effects_change_stats() -> void:
	var sandbox: Sandbox = _scene()
	var normal: float = sandbox.player.current_speed()
	_wear(sandbox, "a015", false, {"speed": 1.1, "self_repair": 1.0})
	assert_float(sandbox.player.current_speed()).is_greater(normal)
	var piece: BodyPiece = sandbox.player.body.equipped(ARM)
	piece.durability = 50.0
	sandbox.player.body.tick(1.0)
	assert_float(piece.durability).is_equal(51.0)


func _total(body: ModularBody) -> float:
	var total: float = 0.0
	for slot: int in ModularBody.Slot.values():
		total += body.equipped(slot as ModularBody.Slot).durability
	return total
