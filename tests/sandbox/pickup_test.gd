extends GdUnitTestSuite

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"
const LEG_LEFT: ModularBody.Slot = ModularBody.Slot.LEG_LEFT
const LEG_RIGHT: ModularBody.Slot = ModularBody.Slot.LEG_RIGHT


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _spares(sandbox: Sandbox) -> int:
	return sandbox.player.body.spares(LEG_LEFT).size() + sandbox.player.body.spares(LEG_RIGHT).size()


func _step_on(sandbox: Sandbox, id: String) -> Interactable:
	var item: Interactable = sandbox.items[id]
	sandbox.player.global_position = item.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	return item


func test_walking_over_picks_up() -> void:
	var sandbox: Sandbox = _scene()
	var before: int = _spares(sandbox)
	var item: Interactable = await _step_on(sandbox, Sandbox.ID_PICKUP_LEG)
	assert_bool(item.used).is_true()
	assert_int(_spares(sandbox)).is_equal(before + 1)


func test_broken_crate_leaves_rubble_that_can_be_converted() -> void:
	var sandbox: Sandbox = _scene()
	var crate: Interactable = sandbox.items[Sandbox.ID_CRATE]
	crate.activate()
	assert_bool(crate.is_rubble()).is_true()
	assert_bool(sandbox.entities.has(Sandbox.ID_CRATE)).is_true()


func test_full_spares_leave_the_item_on_the_ground() -> void:
	var sandbox: Sandbox = _scene()
	var body: ModularBody = sandbox.player.body
	for slot: ModularBody.Slot in [LEG_LEFT, LEG_RIGHT]:
		while body.add_spare(slot, BodyPiece.new(BodyPiece.Kind.LEG)):
			pass
	var item: Interactable = await _step_on(sandbox, Sandbox.ID_PICKUP_LEG)
	assert_bool(item.used).is_false()
