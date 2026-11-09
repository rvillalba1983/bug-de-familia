class_name Selectable
extends Node2D
## Componente que hace seleccionable a su entidad.

const RADIUS: float = 36.0
const HINT_GAP: float = 14.0
const HINT_WIDTH: float = 320.0
const HINT_SIZE: int = 20
const HINT_OUTLINE: int = 6
## Por encima de copas de árbol y halos, por debajo de la lluvia.
const LAYER: int = 8
const COLOR_RING: Color = Color("#ffd24a")

var selected: bool = false
## Altura del cuerpo sobre los pies: la cabeza también cuenta al hacer clic.
var reach_up: float = 0.0
## Aviso sobre la cabeza mientras está seleccionado.
var hint_key: String = ""


func _ready() -> void:
	add_to_group(SelectionSystem.GROUP)
	z_index = LAYER
	z_as_relative = false


func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 40, COLOR_RING, 3.0)
		if hint_key != "":
			_draw_hint()


func _draw_hint() -> void:
	var font: Font = ThemeDB.fallback_font
	var at: Vector2 = Vector2(-HINT_WIDTH * 0.5, -reach_up - HINT_GAP)
	draw_string_outline(font, at, tr(hint_key), HORIZONTAL_ALIGNMENT_CENTER, HINT_WIDTH, HINT_SIZE, HINT_OUTLINE, Color.BLACK)
	draw_string(font, at, tr(hint_key), HORIZONTAL_ALIGNMENT_CENTER, HINT_WIDTH, HINT_SIZE, COLOR_RING)


func set_selected(value: bool) -> void:
	selected = value
	queue_redraw()


func contains_point(point: Vector2) -> bool:
	return click_distance(point) <= RADIUS * 1.3


## Distancia del clic al cuerpo, de los pies a la cabeza.
func click_distance(point: Vector2) -> float:
	var head: Vector2 = global_position - Vector2(0.0, reach_up)
	return point.distance_to(Geometry2D.get_closest_point_to_segment(point, global_position, head))
