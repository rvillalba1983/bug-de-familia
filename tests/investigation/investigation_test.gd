extends GdUnitTestSuite

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _texts(director: InvestigationDirector, node: String) -> Array:
	return director.available_options(node).map(
		func(option: Dictionary) -> String: return option["text"]
	)


func _choose_text(director: InvestigationDirector, start: String, part: String) -> void:
	var options: Array = director.available_options(start)
	director.current_node = start
	for index: int in range(options.size()):
		if (options[index]["text"] as String).contains(part):
			director.choose(index)
			return
	fail("No existe la opción: %s" % part)


func test_case_data_is_valid() -> void:
	assert_array(_scene().investigation.validate()).is_empty()


func test_truth_needs_evidence() -> void:
	var director: InvestigationDirector = _scene().investigation
	assert_array(_texts(director, "paca_start")).not_contains(
		["He encontrado a Manolo. Está apagado y su reloj marca las 21:00."]
	)
	director.examine("e_manolo")
	assert_array(_texts(director, "paca_start")).contains(
		["He encontrado a Manolo. Está apagado y su reloj marca las 21:00."]
	)


func test_conversation_stops_time_and_ends() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.investigation.open_dialogue("anselmo")
	assert_bool(get_tree().paused).is_true()
	sandbox.investigation.choose(0)
	assert_bool(get_tree().paused).is_false()
	assert_str(sandbox.investigation.current_node).is_empty()


func test_peace_through_deduction() -> void:
	var sandbox: Sandbox = _scene()
	var director: InvestigationDirector = sandbox.investigation
	director.examine("e_manolo")
	director.examine("e_acta")
	director.open_dialogue("paca")
	_choose_text(director, "paca_start", "He encontrado")
	_choose_text(director, "paca_truth", "acta")
	director.choose(0)
	director.open_dialogue("seta")
	_choose_text(director, "seta_start", "Manolo se apagó")
	assert_bool(director.has_flag("paz")).is_true()


func test_negotiation_gives_truce() -> void:
	var director: InvestigationDirector = _scene().investigation
	director.examine("e_sombrero")
	director.open_dialogue("seta")
	_choose_text(director, "seta_start", "sombrero")
	director.choose(0)
	director.open_dialogue("paca")
	_choose_text(director, "paca_start", "fertilizante")
	assert_bool(director.has_flag("tregua")).is_true()


func test_lie_starts_war() -> void:
	var director: InvestigationDirector = _scene().investigation
	director.open_dialogue("paca")
	_choose_text(director, "paca_start", "Qué le pasó")
	director.choose(0)
	director.open_dialogue("paca")
	_choose_text(director, "paca_start", "lo vi")
	assert_bool(director.has_flag("guerra")).is_true()


func test_staying_out_lets_conflict_break() -> void:
	var director: InvestigationDirector = _scene().investigation
	director.advance_neglect(InvestigationDirector.NEGLECT_LIMIT + 1.0)
	assert_bool(director.has_flag("guerra")).is_true()


func test_consequences_persist_after_reload() -> void:
	var sandbox: Sandbox = _scene()
	sandbox.investigation.flags["paz"] = true
	sandbox.investigation.flags["e_manolo"] = true
	sandbox.autosave()
	var second: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var restored: Sandbox = second.scene()
	assert_bool(restored.investigation.has_flag("paz")).is_true()
	assert_bool(restored.investigation.has_flag("e_manolo")).is_true()


func test_ambient_only_heard_nearby() -> void:
	var sandbox: Sandbox = _scene()
	var director: InvestigationDirector = sandbox.investigation
	director.tick_ambient(10.0)
	assert_bool(director.bubbles["seta"].is_busy()).is_false()
	sandbox.player.global_position = Vector2(1250.0, 820.0)
	director.tick_ambient(10.0)
	var heard: bool = director.bubbles["seta"].is_busy() or director.bubbles["anselmo"].is_busy()
	assert_bool(heard).is_true()
