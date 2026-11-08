extends GdUnitTestSuite

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"
const QUESTION: Dictionary = {"options": ["a", "b", "c", "d"], "answer": 2}


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _force_active(sandbox: Sandbox, ids: Array) -> void:
	sandbox.ai.team.active = ids
	sandbox.ai.team.muted.clear()


func test_idle_chain_uses_three_different_ais() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["panico", "mama", "arbitro"])
	sandbox.ai.say_chain(["idle_advice", "idle_insult", "idle_reproach"])
	var speakers: Dictionary = {}
	for entry: Dictionary in sandbox.ai.pending():
		speakers[entry["id"]] = true
	assert_int(speakers.size()).is_equal(3)


func test_speaking_colors_tail_and_spends_tokens() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["panico", "mama", "arbitro"])
	var before: float = sandbox.ai.team.tokens["mama"]
	sandbox.ai.say_chain(["low_piece"])
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_bool(sandbox.player.tail_speaking).is_true()
	assert_float(sandbox.ai.team.tokens["mama"]).is_less(before)
	assert_that(sandbox.player.tail_color).is_equal(Color("#ff90c0"))


func test_abuela_discards_a_wrong_option() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["abuela", "panico", "mama"])
	var advice: Dictionary = sandbox.ai.question_advice(QUESTION)
	assert_int(advice["disabled"]).is_not_equal(2)
	assert_int(advice["disabled"]).is_greater_equal(0)


func test_troll_always_points_to_a_wrong_answer() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["troll", "panico", "mama"])
	for attempt: int in range(30):
		var advice: Dictionary = sandbox.ai.question_advice(QUESTION)
		assert_str(advice["text"]).not_contains("Es la 3")


func test_arbitro_cancels_troll_sabotage() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["troll", "arbitro", "mama"])
	assert_dict(sandbox.ai.question_advice(QUESTION)).is_empty()


func test_desprecio_improves_stun() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["dr_desprecio", "panico", "mama"])
	assert_float(sandbox.ai.stun_bonus()).is_greater(1.0)


func test_failing_both_questions_offends_an_ai() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["panico", "mama", "arbitro"])
	sandbox.ai.on_all_wrong()
	assert_int(sandbox.ai.team.offenses.size()).is_equal(1)


func test_discarding_a_piece_recharges_a_sleeping_ai() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["panico", "mama", "arbitro"])
	sandbox.ai.team.tokens["troll"] = 0.0
	sandbox.ai.team.tokens["abuela"] = 50.0
	sandbox.ai.team.tokens["dr_desprecio"] = 50.0
	sandbox.panel.open(BodyPanel.Mode.NORMAL)
	sandbox.panel.discard_spare(ModularBody.Slot.LEG_LEFT, 0)
	sandbox.panel.close()
	assert_float(sandbox.ai.team.tokens["troll"]).is_equal(AiTeam.DISCARD_RECHARGE)
