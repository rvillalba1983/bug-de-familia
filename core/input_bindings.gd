class_name InputBindings
extends RefCounted
## Registra las acciones de entrada del juego. Ver docs/controles.md.

const KEY_ACTIONS: Dictionary = {
	&"move_up": [KEY_W, KEY_UP],
	&"move_down": [KEY_S, KEY_DOWN],
	&"move_left": [KEY_A, KEY_LEFT],
	&"move_right": [KEY_D, KEY_RIGHT],
	&"run": [KEY_SHIFT],
	&"toggle_run": [KEY_KP_DIVIDE],
	&"autorun": [KEY_NUMLOCK],
	&"tactical_pause": [KEY_SPACE],
	&"target_next": [KEY_TAB],
	&"crouch": [KEY_X],
	&"interact": [KEY_E],
	&"character": [KEY_C],
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
