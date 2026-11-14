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
	director.choose_approach("convencer")
	director.choose_objective("senuelo")
	director.choose_slot(ARM)
	assert_int(director.step).is_equal(ConversionDirector.Step.QUESTION)
	_finish_with_answers(director, 0)
	assert_int(director.step).is_equal(ConversionDirector.Step.RESULT)
	director.confirm_result()
	await get_tree().process_frame
	assert_bool(get_tree().paused).is_false()
	assert_int(sandbox.player.body.spares(ARM).size()).is_equal(1)
	var allowed: Array = sandbox.catalog.objectives["senuelo"]["actions"]
	assert_array(allowed).contains([sandbox.player.body.spares(ARM)[0].actions[0]["id"]])
	assert_bool(sandbox.items.has(Sandbox.ID_CRATE)).is_false()


func test_never_fails_even_if_time_runs_out() -> void:
	var sandbox: Sandbox = _scene()
	var director: ConversionDirector = sandbox.conversion
	director.begin_on(_target(sandbox, Sandbox.ID_CRATE))
	director.choose_approach("enganar")
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
	director.choose_approach("convencer")
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


func test_nothing_in_range_cannot_be_converted() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.player.global_position = Vector2(-5000.0, -5000.0)
	assert_bool(sandbox.conversion.convert_nearest()).is_false()
	assert_int(sandbox.conversion.step).is_equal(ConversionDirector.Step.IDLE)
	assert_bool(sandbox.conversion.hint.visible).is_true()


func test_key_converts_the_nearest_and_marks_it() -> void:
	var sandbox: Sandbox = _scene()
	var crate: Convertible = _target(sandbox, Sandbox.ID_CRATE)
	sandbox.player.global_position = crate.global_position + Vector2(20.0, 0.0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_bool(crate.highlighted).is_true()
	assert_bool(sandbox.conversion.convert_nearest()).is_true()
	assert_int(sandbox.conversion.step).is_equal(ConversionDirector.Step.APPROACH)
	assert_bool(crate.highlighted).is_false()


func test_screen_stops_on_target_and_counts_down() -> void:
	var sandbox: Sandbox = _scene()
	var screen: ConversionScreen = sandbox.conversion.screen
	screen.begin(Vector2(960.0, 540.0))
	screen.show_choices("Pregunta", [["1", func() -> void: pass]], true)
	screen.set_time_fraction(0.2)
	assert_str(screen._count.text).is_equal("1,0")
	assert_float(screen._bar.scale.x).is_equal_approx(0.2, 0.001)
	assert_object(screen._backdrop.material).is_not_null()
	screen.close()


func test_taunt_comes_from_a_speaking_ai_and_keeps_the_seed() -> void:
	var sandbox: Sandbox = _scene()
	var state_before: int = sandbox.rng.state
	var taunt: Dictionary = sandbox.ai.question_taunt({"text": "¿Quién?"})
	assert_str(str(taunt["text"])).is_not_empty()
	assert_int(sandbox.rng.state).is_equal(state_before)
