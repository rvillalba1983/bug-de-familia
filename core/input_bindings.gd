class_name InputBindings
extends RefCounted
## Registra las acciones de entrada del juego. Ver docs/controles.md.

const KEY_ACTIONS: Dictionary = {
	&"move_up": [KEY_W],
	&"move_down": [KEY_S],
	&"move_left": [KEY_A],
	&"move_right": [KEY_D],
	&"run": [KEY_SHIFT],
	&"toggle_run": [KEY_CAPSLOCK],
	&"autorun": [KEY_NUMLOCK],
	&"tactical_pause": [KEY_SPACE],
	&"target_next": [KEY_TAB],
	&"crouch": [KEY_X],
	&"interact": [KEY_E],
	&"character": [KEY_C],
	&"convert": [KEY_Q],
	&"help": [KEY_F1],
	&"close_panel": [KEY_ESCAPE],
	&"map": [KEY_M],
	&"throw": [KEY_F],
	&"action_1": [KEY_1],
	&"action_2": [KEY_2],
	&"action_3": [KEY_3],
	&"action_4": [KEY_4],
	&"action_5": [KEY_5],
	&"action_6": [KEY_6],
}
const MOUSE_ACTIONS: Dictionary = {
	&"select": MOUSE_BUTTON_LEFT,
	&"move_to": MOUSE_BUTTON_RIGHT,
	&"zoom_in": MOUSE_BUTTON_WHEEL_UP,
	&"zoom_out": MOUSE_BUTTON_WHEEL_DOWN,
}


## Se puede llamar varias veces: las acciones existentes no se duplican.
static func install() -> void:
	for action: StringName in KEY_ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			for key: Key in KEY_ACTIONS[action]:
				var event: InputEventKey = InputEventKey.new()
				event.physical_keycode = key
				InputMap.action_add_event(action, event)
	for action: StringName in MOUSE_ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event: InputEventMouseButton = InputEventMouseButton.new()
			event.button_index = MOUSE_ACTIONS[action]
			InputMap.action_add_event(action, event)
