extends GdUnitTestSuite

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"
const ARM: ModularBody.Slot = ModularBody.Slot.ARM_EXTRA_LEFT
const OPEN: Vector2 = Vector2(1300.0, 620.0)


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _frames(count: int) -> void:
	for frame: int in range(count):
		await get_tree().physics_frame


func _wear(sandbox: Sandbox, id: String) -> void:
	var piece: BodyPiece = BodyPiece.new(BodyPiece.Kind.ARM)
	piece.actions.append({"id": id, "name": id, "active": false})
	var body: ModularBody = sandbox.player.body
	body.add_spare(ARM, piece)
	body.swap(ARM, 0)


func _alert(enemy: Guard) -> void:
	enemy.state = Guard.State.ALERT


## Alerta sin la pausa previa a la pelea, mirando y persiguiendo al jugador.
func _alert_towards_player(sandbox: Sandbox, enemy: Guard) -> void:
	_alert(enemy)
	enemy._last_known = sandbox.player.global_position
	enemy.detector.facing_angle = enemy.global_position.angle_to_point(
		sandbox.player.global_position
	)


func _place(sandbox: Sandbox, enemy: Guard, offset: Vector2) -> void:
	sandbox.player.global_position = OPEN
	enemy.global_position = OPEN + offset


func test_strike_hurts_and_makes_noise() -> void:
	var sandbox: Sandbox = _scene()
	var noises: Array[float] = []
	sandbox.noise_bus.noise_emitted.connect(func(_at: Vector2, r: float) -> void: noises.append(r))
	_alert(sandbox.guard)
	assert_bool(sandbox.combat.strike(sandbox.guard)).is_true()
	assert_float(sandbox.guard.health).is_equal(Guard.MAX_HEALTH - CombatSystem.BASE_DAMAGE)
	assert_int(noises.size()).is_equal(1)


func test_strike_respects_interval() -> void:
	var sandbox: Sandbox = _scene()
	_alert(sandbox.guard)
	sandbox.combat.strike(sandbox.guard)
	assert_bool(sandbox.combat.strike(sandbox.guard)).is_false()


func test_sneak_attack_does_more_damage_and_silent_blade_is_quiet() -> void:
	var sandbox: Sandbox = _scene()
	assert_float(sandbox.combat.attack_damage(sandbox.guard)).is_equal(
		CombatSystem.BASE_DAMAGE * CombatSystem.SNEAK_FACTOR
	)
	_wear(sandbox, "a002")
	var noises: Array[float] = []
	sandbox.noise_bus.noise_emitted.connect(func(_at: Vector2, r: float) -> void: noises.append(r))
	sandbox.combat.strike(sandbox.guard)
	assert_int(noises.size()).is_equal(0)


func test_fewer_arms_slow_attacks_and_none_cannot_attack() -> void:
	var sandbox: Sandbox = _scene()
	var body: ModularBody = sandbox.player.body
	var normal: float = sandbox.combat.attack_interval()
	body.damage(ARM, BodyPiece.MAX_DURABILITY)
	sandbox.panel.close()
	assert_float(sandbox.combat.attack_interval()).is_greater(normal)
	for slot: ModularBody.Slot in [
		ModularBody.Slot.ARM_EXTRA_RIGHT,
		ModularBody.Slot.ARM_MAIN_LEFT,
		ModularBody.Slot.ARM_MAIN_RIGHT,
	]:
		body.damage(slot, BodyPiece.MAX_DURABILITY)
		sandbox.panel.close()
	_alert(sandbox.guard)
	assert_bool(sandbox.combat.strike(sandbox.guard)).is_false()


func test_engage_walks_up_and_fights() -> void:
	var sandbox: Sandbox = _scene()
	var guard: Guard = sandbox.guard
	_place(sandbox, guard, Vector2(200.0, 0.0))
	_alert(guard)
	await _frames(4)
	sandbox.combat.engage(guard)
	await _frames(150)
	assert_float(guard.health).is_less(Guard.MAX_HEALTH)


func test_keyboard_interrupts_attack() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.combat.engage(sandbox.guard)
	await _frames(2)
	Input.action_press(&"move_up")
	await _frames(3)
	Input.action_release(&"move_up")
	assert_object(sandbox.combat.target).is_null()


func test_melee_windup_can_be_dodged() -> void:
	var sandbox: Sandbox = _scene()
	var guard: Guard = sandbox.guard
	guard.process_mode = Node.PROCESS_MODE_INHERIT
	_place(sandbox, guard, Vector2(30.0, 0.0))
	await _frames(2)
	_alert_towards_player(sandbox, guard)
	var body: ModularBody = sandbox.player.body
	var before: float = _total(body)
	await _frames(8)
	sandbox.player.global_position = OPEN + Vector2(0.0, 300.0)
	await _frames(40)
	assert_float(_total(body)).is_equal_approx(before, 1.0)


func test_melee_lands_if_you_stay() -> void:
	var sandbox: Sandbox = _scene()
	var guard: Guard = sandbox.guard
	guard.process_mode = Node.PROCESS_MODE_INHERIT
	_place(sandbox, guard, Vector2(30.0, 0.0))
	await _frames(2)
	_alert_towards_player(sandbox, guard)
	var before: float = _total(sandbox.player.body)
	await _frames(45)
	assert_float(_total(sandbox.player.body)).is_less(before)


func test_wall_blocks_shot() -> void:
	var sandbox: Sandbox = _scene()
	var shooter: Guard = sandbox.shooter
	var wall: Rect2 = SandboxLayout.WALLS[5]
	sandbox.player.global_position = Vector2(wall.get_center().x, wall.end.y + 60.0)
	shooter.global_position = Vector2(wall.get_center().x, wall.position.y - 60.0)
	await _frames(3)
	var before: float = _total(sandbox.player.body)
	shooter._aim_point = sandbox.player.global_position
	shooter._fire()
	assert_float(_total(sandbox.player.body)).is_equal(before)


func test_low_cover_blocks_shot_only_crouching() -> void:
	var sandbox: Sandbox = _scene()
	var shooter: Guard = sandbox.shooter
	var cover: Rect2 = SandboxLayout.LOW_COVERS[0]
	sandbox.player.global_position = Vector2(cover.get_center().x, cover.end.y + 40.0)
	shooter.global_position = Vector2(cover.get_center().x, cover.position.y - 60.0)
	await _frames(3)
	var before: float = _total(sandbox.player.body)
	sandbox.player.set_crouching(true)
	shooter._aim_point = sandbox.player.global_position
	shooter._fire()
	assert_float(_total(sandbox.player.body)).is_equal(before)
	sandbox.player.set_crouching(false)
	shooter._hit_timer = 0.0
	shooter._fire()
	assert_float(_total(sandbox.player.body)).is_less(before)


func test_moving_away_dodges_shot() -> void:
	var sandbox: Sandbox = _scene()
	var shooter: Guard = sandbox.shooter
	_place(sandbox, shooter, Vector2(200.0, 0.0))
	await _frames(3)
	shooter._aim_point = sandbox.player.global_position
	sandbox.player.global_position += Vector2(0.0, 120.0)
	var before: float = _total(sandbox.player.body)
	shooter._fire()
	assert_float(_total(sandbox.player.body)).is_equal(before)


func test_throw_hits_and_is_stopped_by_walls() -> void:
	var sandbox: Sandbox = _scene()
	var guard: Guard = sandbox.guard
	_place(sandbox, guard, Vector2(200.0, 0.0))
	await _frames(3)
	sandbox.combat.throw_at(guard.global_position)
	assert_float(guard.health).is_less(Guard.MAX_HEALTH)
	var wall: Rect2 = SandboxLayout.WALLS[5]
	var hurt: float = guard.health
	sandbox.player.global_position = Vector2(wall.get_center().x, wall.end.y + 40.0)
	guard.global_position = Vector2(wall.get_center().x, wall.position.y - 40.0)
	await _frames(70)
	sandbox.combat.throw_at(guard.global_position)
	assert_float(guard.health).is_equal(hurt)


func test_fallen_enemy_can_be_converted_and_stays_gone() -> void:
	var sandbox: Sandbox = _scene()
	var guard: Guard = sandbox.guard
	guard.take_damage(Guard.MAX_HEALTH)
	assert_bool(guard.is_down()).is_true()
	assert_bool(sandbox.entities.has(Sandbox.ID_GUARD)).is_true()
	sandbox.autosave()
	var second: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var restored: Sandbox = second.scene()
	assert_bool(restored.entities.has(Sandbox.ID_GUARD)).is_false()


func test_stun_affects_shooter_too() -> void:
	var sandbox: Sandbox = _scene()
	var piece: BodyPiece = BodyPiece.new(BodyPiece.Kind.ARM)
	piece.actions.append({"id": "a003", "name": "x", "active": true})
	sandbox.player.body.add_spare(ARM, piece)
	sandbox.player.body.swap(ARM, 0)
	_place(sandbox, sandbox.shooter, Vector2(50.0, 0.0))
	sandbox.guard.global_position = Vector2(300.0, 900.0)
	assert_bool(sandbox.actions.trigger(0)).is_true()
	assert_int(sandbox.shooter.state).is_equal(Guard.State.STUNNED)


func test_forged_pieces_explain_themselves() -> void:
	var sandbox: Sandbox = _scene()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var piece: BodyPiece = PieceForge.forge(
		sandbox.catalog, "nanoacero", "arma", BodyPiece.Kind.ARM, 1.0, rng
	)
	assert_bool(piece.description.is_empty()).is_false()


func _total(body: ModularBody) -> float:
	var total: float = 0.0
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = body.equipped(slot as ModularBody.Slot)
		if piece != null:
			total += piece.durability
	return total
