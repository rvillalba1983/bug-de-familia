class_name TacticalPause
extends Node
## Detiene el mundo para observar y planear.

signal paused_changed(is_paused: bool)

var _modal_count: int = 0
var _paused_before_modal: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if _modal_count > 0:
		return
	if event.is_action_pressed(&"tactical_pause") and not event.is_echo():
		set_paused(not get_tree().paused)
	elif get_tree().paused and event.is_action_pressed(&"close_panel") and not event.is_echo():
		set_paused(false)
		get_viewport().set_input_as_handled()


func set_paused(value: bool) -> void:
	if get_tree().paused == value:
		return
	get_tree().paused = value
	paused_changed.emit(value)


## Detiene el juego para una ventana; Espacio no la reanuda hasta cerrarla.
func begin_modal() -> void:
	if _modal_count == 0:
		_paused_before_modal = get_tree().paused
	_modal_count += 1
	get_tree().paused = true


func end_modal() -> void:
	_modal_count = maxi(_modal_count - 1, 0)
	if _modal_count == 0:
		get_tree().paused = _paused_before_modal
