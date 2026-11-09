extends GdUnitTestSuite
## Flujos de partida desde las acciones de entrada reales, no desde llamadas a sistemas.

const PATH: String = "res://scenes/beta/beta_zone.tscn"
const SAFE_SPOT: Vector2 = Vector2(600.0, 1300.0)
const ARM: ModularBody.Slot = ModularBody.Slot.ARM_EXTRA_LEFT

var runner: GdUnitSceneRunner
var zone: BetaZone


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	await _open()


func after_test() -> void:
	for action: StringName in [&"move_right", &"throw"]:
		Input.action_release(action)
	BetaZone.forced_hour = -1
	get_tree().paused = false
	Engine.time_scale = 1.0


func _open() -> void:
	runner = scene_runner(PATH)
	zone = runner.scene()
	await await_idle_frame()
	zone.set_enemies_active(false)
	zone.player.global_position = SAFE_SPOT


func _press(action: StringName) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	get_tree().root.push_input(event)
	await await_idle_frame()


func _controls() -> ControlsPanel:
	return zone.get_children().filter(func(n: Node) -> bool: return n is ControlsPanel)[0]


func _click_world(at: Vector2) -> void:
	runner.set_mouse_position(zone.get_viewport().get_canvas_transform() * at)
	runner.simulate_mouse_button_press(MOUSE_BUTTON_RIGHT)
	await await_idle_frame()
	runner.simulate_mouse_button_release(MOUSE_BUTTON_RIGHT)
	await await_idle_frame()


func test_space_pauses_and_resumes_the_world() -> void:
	await _press(&"tactical_pause")
	assert_bool(get_tree().paused).is_true()
	await _press(&"tactical_pause")
	assert_bool(get_tree().paused).is_false()


func test_c_opens_pieces_and_only_esc_closes_them() -> void:
	await _press(&"character")
	assert_bool(zone.panel.is_open).is_true()
	await _press(&"character")
	assert_bool(zone.panel.is_open).is_true()
	await _press(&"close_panel")
	assert_bool(zone.panel.is_open).is_false()


func test_f1_opens_help_and_only_esc_closes_it() -> void:
	await _press(&"help")
	assert_bool(_controls().is_open).is_true()
	await _press(&"help")
	assert_bool(_controls().is_open).is_true()
	await _press(&"close_panel")
	assert_bool(_controls().is_open).is_false()


func test_space_does_not_resume_while_a_window_is_open() -> void:
	await _press(&"help")
	var paused_before: bool = get_tree().paused
	await _press(&"tactical_pause")
	assert_bool(get_tree().paused).is_equal(paused_before)
	await _press(&"close_panel")


func test_keyboard_moves_and_x_crouches() -> void:
	var from: Vector2 = zone.player.global_position
	Input.action_press(&"move_right")
	await await_millis(300)
	Input.action_release(&"move_right")
	assert_float(zone.player.global_position.x).is_greater(from.x)
	await _press(&"crouch")
	assert_bool(zone.player.is_crouching).is_true()
	await _press(&"crouch")
	assert_bool(zone.player.is_crouching).is_false()


func test_right_click_on_the_ground_walks_there() -> void:
	await await_millis(100)
	var goal: Vector2 = zone.player.global_position + Vector2(80.0, 0.0)
	await _click_world(goal)
	await await_millis(800)
	assert_float(zone.player.global_position.distance_to(goal)).is_less(30.0)


func test_right_click_on_an_object_walks_and_uses_it() -> void:
	zone.player.global_position = BetaLayout.generator + Vector2(-150.0, 0.0)
	await await_millis(100)
	await _click_world(BetaLayout.generator)
	await await_millis(1500)
	assert_bool((zone.items[BetaZone.ID_GENERATOR] as Interactable).used).is_true()


func test_q_converts_with_answer_keys_and_esc_accepts() -> void:
	var crate: Interactable = zone.items[Sandbox.ID_CRATE]
	zone.player.global_position = crate.global_position + Vector2(40.0, 40.0)
	await await_millis(100)
	await _press(&"convert")
	var director: ConversionDirector = zone.conversion
	assert_int(director.step).is_equal(ConversionDirector.Step.OBJECTIVE)
	assert_bool(get_tree().paused).is_true()
	director.choose_objective("senuelo")
	director.choose_slot(ARM)
	for _round: int in range(ConversionSession.QUESTION_COUNT):
		assert_int(director.step).is_equal(ConversionDirector.Step.QUESTION)
		await _press(&"action_1")
		director.tick(ConversionDirector.FEEDBACK_TIME + 0.1)
	assert_int(director.step).is_equal(ConversionDirector.Step.RESULT)
	await _press(&"close_panel")
	await await_idle_frame()
	assert_bool(get_tree().paused).is_false()
	assert_int(zone.player.body.spares(ARM).size()).is_equal(1)
	assert_bool(zone.items.has(Sandbox.ID_CRATE)).is_false()


func test_f_throws_scrap_and_a_nearby_guard_goes_to_check() -> void:
	var enemy: Guard = zone.guard
	enemy.process_mode = Node.PROCESS_MODE_INHERIT
	zone.player.global_position = enemy.global_position + Vector2(0.0, 100.0)
	await await_idle_frame()
	Input.action_press(&"throw")
	await await_millis(120)
	Input.action_release(&"throw")
	assert_int(enemy.state).is_equal(Guard.State.INVESTIGATE)


func test_save_point_saves_and_reopening_continues_there() -> void:
	zone.player.global_position = BetaLayout.save_points[1]
	await await_millis(200)
	var saved: Dictionary = SaveSystem.read()["data"]
	assert_float(float(saved["player"]["x"])).is_equal_approx(BetaLayout.save_points[1].x, 40.0)
	Sandbox.session_started = false
	await _open()
	assert_object(zone.overlay).is_not_null()
	assert_int(zone.overlay.options.size()).is_equal(2)
	zone.overlay.options[0].pressed.emit()
	await await_idle_frame()
	assert_object(zone.overlay).is_null()
	assert_bool(get_tree().paused).is_false()


func test_death_leaves_only_new_game_and_space_does_not_resume() -> void:
	var body: ModularBody = zone.player.body
	body.discard_spare(ModularBody.Slot.HEAD, 0)
	body.damage(ModularBody.Slot.HEAD, BodyPiece.MAX_DURABILITY)
	assert_bool(SaveSystem.read()["data"]["dead"]).is_true()
	assert_int(zone.overlay.options.size()).is_equal(1)
	await _press(&"tactical_pause")
	assert_bool(get_tree().paused).is_true()
