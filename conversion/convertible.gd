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
## Objetos únicos: su pieza trae siempre esta propiedad.
var fixed_property: String = ""


func setup(new_id: String, new_material: String) -> void:
	entity_id = new_id
	material_id = new_material


## Lo que queda de una caja rota ya no es madera: son restos.
func effective_material() -> String:
	var source: Node = get_parent()
	return "restos" if source is Interactable and (source as Interactable).is_rubble() else material_id


func can_be_converted() -> bool:
	var source: Guard = get_parent() as Guard
	return source == null or source.can_be_converted()


func _ready() -> void:
	add_to_group(GROUP)


func _draw() -> void:
	if highlighted:
		draw_arc(Vector2(0.0, -20.0), RADIUS, 0.0, TAU, 32, COLOR_HIGHLIGHT, 3.0)
		KeyHint.draw_key(self, Vector2(RADIUS + 10.0, -20.0), "Q")


func set_highlight(active: bool) -> void:
	highlighted = active
	queue_redraw()
