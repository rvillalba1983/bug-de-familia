class_name SelectableDummy
extends Node2D
## Objetivo provisional para probar la selección.

const RADIUS: float = 26.0
const COLOR_BODY: Color = Color("#7a5ca8")
const COLOR_RING: Color = Color("#ffd24a")

var selected: bool = false


func _ready() -> void:
	add_to_group(SelectionSystem.GROUP)


func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO, RADIUS + 6.0, 0.0, TAU, 40, COLOR_RING, 3.0)
	draw_circle(Vector2(0.0, -RADIUS * 0.6), RADIUS * 0.8, COLOR_BODY)


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func contains_point(point: Vector2) -> bool:
	return global_position.distance_to(point) <= RADIUS * 1.5
