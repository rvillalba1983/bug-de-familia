extends GdUnitTestSuite


func test_esc_sale_de_la_pausa_tactica() -> void:
	var pause: TacticalPause = auto_free(TacticalPause.new())
	add_child(pause)
	pause.set_paused(true)
	var event: InputEventAction = InputEventAction.new()
	event.action = &"close_panel"
	event.pressed = true
	pause._unhandled_input(event)
	assert_bool(get_tree().paused).is_false()


func test_un_guardia_solo_se_convierte_si_esta_inmovilizado_o_caido() -> void:
	var guard: Guard = auto_free(Guard.new())
	assert_bool(guard.can_be_converted()).is_false()
	guard.state = Guard.State.STUNNED
	assert_bool(guard.can_be_converted()).is_true()
	guard.state = Guard.State.DOWN
	assert_bool(guard.can_be_converted()).is_true()
