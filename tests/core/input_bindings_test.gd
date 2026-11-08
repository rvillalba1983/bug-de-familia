extends GdUnitTestSuite


func before() -> void:
	InputBindings.install()


func _key(code: Key) -> InputEventKey:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	return event


func test_wow_style_keys() -> void:
	assert_bool(InputMap.event_is_action(_key(KEY_W), &"move_up")).is_true()
	assert_bool(InputMap.event_is_action(_key(KEY_A), &"move_left")).is_true()
	assert_bool(InputMap.event_is_action(_key(KEY_TAB), &"target_next")).is_true()
	assert_bool(InputMap.event_is_action(_key(KEY_NUMLOCK), &"autorun")).is_true()


func test_space_is_tactical_pause() -> void:
	assert_bool(InputMap.event_is_action(_key(KEY_SPACE), &"tactical_pause")).is_true()


func test_install_twice_does_not_duplicate() -> void:
	var before_count: int = InputMap.action_get_events(&"move_up").size()
	InputBindings.install()
	assert_int(InputMap.action_get_events(&"move_up").size()).is_equal(before_count)
