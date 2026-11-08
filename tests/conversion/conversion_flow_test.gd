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


func _target(sandbox: Sandbox, id: String) -> Convertible:
	for node: Node in get_tree().get_nodes_in_group(Convertible.GROUP):
		if (node as Convertible).entity_id == id:
			return node
	return null


func _finish_with_answers(director: ConversionDirector, option: int) -> void:
	for round_index: int in range(ConversionSession.QUESTION_COUNT):
		director.answer_current(option)
		director.tick(ConversionDirector.FEEDBACK_TIME + 0.1)


func test_full_flow_stops_time_and_creates_piece() -> void:
	var sandbox: Sandbox = _scene()
	var director: ConversionDirector = sandbox.conversion
	director.begin_on(_target(sandbox, Sandbox.ID_CRATE))
	assert_bool(get_tree().paused).is_true()
	director.choose_objective("senuelo")
	director.choose_slot(ARM)
	assert_int(director.step).is_equal(ConversionDirector.Step.QUESTION)
	_finish_with_answers(director, 0)
	assert_int(director.step).is_equal(ConversionDirector.Step.RESULT)
	director.confirm_result()
	await get_tree().process_frame
	assert_bool(get_tree().paused).is_false()
	assert_int(sandbox.player.body.spares(ARM).size()).is_equal(1)
	assert_bool(sandbox.player.body.spares(ARM)[0].has_action("a062")).is_true()
	assert_bool(sandbox.items.has(Sandbox.ID_CRATE)).is_false()


func test_never_fails_even_if_time_runs_out() -> void:
	var sandbox: Sandbox = _scene()
	var director: ConversionDirector = sandbox.conversion
	director.begin_on(_target(sandbox, Sandbox.ID_CRATE))
	director.choose_objective("velocidad")
	director.choose_slot(ARM)
	for round_index: int in range(ConversionSession.QUESTION_COUNT):
		director.tick(ConversionSession.TIME_LIMIT + 0.1)
		director.tick(ConversionDirector.FEEDBACK_TIME + 0.1)
	assert_int(director.step).is_equal(ConversionDirector.Step.RESULT)
	director.confirm_result()
	assert_int(sandbox.player.body.spares(ARM).size()).is_equal(1)


func test_can_convert_an_enemy() -> void:
	var sandbox: Sandbox = _scene()
	var director: ConversionDirector = sandbox.conversion
	director.begin_on(_target(sandbox, Sandbox.ID_GUARD))
	director.choose_objective("defensa")
	director.choose_slot(ARM)
	_finish_with_answers(director, 0)
	director.confirm_result()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_bool(is_instance_valid(sandbox.guard)).is_false()
	sandbox.autosave()
	var second: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var restored: Sandbox = second.scene()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_bool(restored.entities.has(Sandbox.ID_GUARD)).is_false()
	assert_int(restored.player.body.spares(ARM).size()).is_equal(1)


func test_out_of_range_cannot_be_selected() -> void:
	var sandbox: Sandbox = _scene()
	var far: Convertible = _target(sandbox, Sandbox.ID_TERMINAL)
	sandbox.conversion.try_target(far.global_position)
	assert_int(sandbox.conversion.step).is_equal(ConversionDirector.Step.IDLE)
