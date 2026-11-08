class_name SelectionSystem
extends Node2D
## Selección de objetivos con clic izquierdo o Tab. Funciona también en pausa.

signal selection_changed(target: Selectable)

const GROUP: StringName = &"selectable"

var current: Selectable = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"select"):
		select_at(get_global_mouse_position())
	elif event.is_action_pressed(&"target_next"):
		cycle_next()


func select_at(point: Vector2) -> void:
	for node: Node in get_tree().get_nodes_in_group(GROUP):
		var target: Selectable = node as Selectable
		if target != null and target.contains_point(point):
			_set_current(target)
			return
	_set_current(null)


func cycle_next() -> void:
	var targets: Array[Node] = get_tree().get_nodes_in_group(GROUP)
	if targets.is_empty():
		return
	var next_index: int = (targets.find(current) + 1) % targets.size()
	_set_current(targets[next_index] as Selectable)


func _set_current(target: Selectable) -> void:
	if current == target:
		return
	if current != null:
		current.set_selected(false)
	current = target
	if current != null:
		current.set_selected(true)
	selection_changed.emit(current)
