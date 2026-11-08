class_name TacticalPause
extends Node
## Detiene el mundo para observar y planear.

signal paused_changed(is_paused: bool)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"tactical_pause") and not event.is_echo():
		set_paused(not get_tree().paused)


func set_paused(value: bool) -> void:
	if get_tree().paused == value:
		return
	get_tree().paused = value
	paused_changed.emit(value)
