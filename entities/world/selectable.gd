class_name Selectable
extends Node2D
## Componente que hace seleccionable a su entidad.

const RADIUS: float = 36.0
const COLOR_RING: Color = Color("#ffd24a")

var selected: bool = false


func _ready() -> void:
	add_to_group(SelectionSystem.GROUP)


func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 40, COLOR_RING, 3.0)


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func contains_point(point: Vector2) -> bool:
	return global_position.distance_to(point) <= RADIUS * 1.3
