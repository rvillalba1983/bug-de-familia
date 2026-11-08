class_name Convertible
extends Node2D
## Marca una entidad como convertible en pieza.

const GROUP: StringName = &"convertible"
const RADIUS: float = 44.0
const RANGE: float = 150.0
const COLOR_IN_RANGE: Color = Color("#c060ff")
const COLOR_FAR: Color = Color(0.75, 0.4, 1.0, 0.3)

var entity_id: String = ""
var material_id: String = ""
var highlighted: bool = false
var in_range: bool = false


func setup(new_id: String, new_material: String) -> void:
	entity_id = new_id
	material_id = new_material


func _ready() -> void:
	add_to_group(GROUP)


func _draw() -> void:
	if highlighted:
		var color: Color = COLOR_IN_RANGE if in_range else COLOR_FAR
		draw_arc(Vector2(0.0, -20.0), RADIUS, 0.0, TAU, 32, color, 3.0)


func set_highlight(active: bool, reachable: bool) -> void:
	highlighted = active
	in_range = reachable
	queue_redraw()


func contains_point(point: Vector2) -> bool:
	return global_position.distance_to(point) <= RADIUS * 1.6
