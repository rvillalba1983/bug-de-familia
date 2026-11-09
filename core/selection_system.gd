class_name SelectionSystem
extends Node2D
## Selección de objetivos con clic izquierdo o Tab. Funciona también en pausa.

signal selection_changed(target: Selectable)

const GROUP: StringName = &"selectable"
const TIE_MARGIN: float = 6.0

var current: Selectable = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"select"):
		select_at(get_global_mouse_position())
	elif event.is_action_pressed(&"target_next"):
		cycle_next()


func select_at(point: Vector2) -> void:
	_set_current(pick(point))


## Quien está bajo el puntero: el más cercano, y a igualdad el ya seleccionado.
func pick(point: Vector2) -> Selectable:
	if current != null and current.contains_point(point) and is_closest_body(current, point):
		return current
	var best: Selectable = null
	var best_distance: float = INF
	for node: Node in get_tree().get_nodes_in_group(GROUP):
		var target: Selectable = node as Selectable
		if target != null and target.contains_point(point) and target.click_distance(point) < best_distance:
			best = target
			best_distance = target.click_distance(point)
	return best


func is_closest_body(target: Selectable, point: Vector2) -> bool:
	for node: Node in get_tree().get_nodes_in_group(GROUP):
		var other: Selectable = node as Selectable
		if other != null and other.click_distance(point) + TIE_MARGIN < target.click_distance(point):
			return false
	return true


func select_exactly(owner_node: Node2D) -> void:
	for child: Node in owner_node.get_children():
		if child is Selectable:
			_set_current(child as Selectable)
			return


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
