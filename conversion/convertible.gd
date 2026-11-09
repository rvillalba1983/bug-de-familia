class_name Convertible
extends Node2D
## Marca una entidad como convertible en pieza.

const GROUP: StringName = &"convertible"
const RADIUS: float = 44.0
const RANGE: float = 150.0
const COLOR_HIGHLIGHT: Color = Color("#c060ff")

var entity_id: String = ""
var material_id: String = ""
var highlighted: bool = false


func setup(new_id: String, new_material: String) -> void:
	entity_id = new_id
	material_id = new_material


func _ready() -> void:
	add_to_group(GROUP)


func _draw() -> void:
	if highlighted:
		draw_arc(Vector2(0.0, -20.0), RADIUS, 0.0, TAU, 32, COLOR_HIGHLIGHT, 3.0)
		KeyHint.draw_key(self, Vector2(RADIUS + 10.0, -20.0), "Q")


func set_highlight(active: bool) -> void:
	highlighted = active
	queue_redraw()
