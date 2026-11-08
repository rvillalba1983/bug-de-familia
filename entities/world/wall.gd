class_name Wall
extends StaticBody2D
## Pared, cobertura baja o puerta provisional.
## Su origen es el borde inferior de la huella, para el orden Y.

const FADED_ALPHA: float = 0.45
const COLOR_TOP: Color = Color("#8f8aa8")
const COLOR_FRONT: Color = Color("#55506e")
const COLOR_LOW_TOP: Color = Color("#a08b62")
const COLOR_LOW_FRONT: Color = Color("#6b5b3e")
const COLOR_DOOR_TOP: Color = Color("#b0505a")
const COLOR_DOOR_FRONT: Color = Color("#7c343e")
const COLOR_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.35)
const SHADOW_HEIGHT: float = 14.0
const CHARACTER_WIDTH: float = 36.0

enum Kind { SOLID, LOW, DOOR }

var footprint: Rect2
var front_height: float
var kind: Kind = Kind.SOLID
var is_open: bool = false
var label_key: String = ""

var _collider: CollisionShape2D


func setup(new_footprint: Rect2, new_front_height: float, new_kind: Kind = Kind.SOLID) -> void:
	footprint = new_footprint
	front_height = new_front_height
	kind = new_kind
	position = Vector2(footprint.position.x, footprint.end.y)
	collision_layer = PhysicsLayers.LOW_COVER if kind == Kind.LOW else PhysicsLayers.WALLS
	collision_mask = 0
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = footprint.size
	_collider = CollisionShape2D.new()
	_collider.shape = shape
	_collider.position = Vector2(footprint.size.x * 0.5, -footprint.size.y * 0.5)
	add_child(_collider)


func _draw() -> void:
	if is_open:
		return
	var width: float = footprint.size.x
	var top_color: Color = COLOR_TOP
	var front_color: Color = COLOR_FRONT
	if kind == Kind.LOW:
		top_color = COLOR_LOW_TOP
		front_color = COLOR_LOW_FRONT
	elif kind == Kind.DOOR:
		top_color = COLOR_DOOR_TOP
		front_color = COLOR_DOOR_FRONT
	draw_rect(Rect2(0.0, 0.0, width, SHADOW_HEIGHT), COLOR_SHADOW)
	draw_rect(Rect2(0.0, -front_height, width, front_height), front_color)
	var top_height: float = footprint.size.y
	draw_rect(Rect2(0.0, -front_height - top_height, width, top_height), top_color)
	if not label_key.is_empty():
		WorldLabel.draw_on(self, tr(label_key), Vector2(width * 0.5, -front_height - top_height - 6.0))


func set_open(value: bool) -> void:
	is_open = value
	_collider.set_deferred(&"disabled", value)
	queue_redraw()


## Rectángulo visible: huella elevada más frente.
func visual_rect() -> Rect2:
	return footprint.grow_side(SIDE_TOP, front_height)


## Atenúa la pared si tapa a alguien que está detrás de ella.
func update_occlusion(character_feet: Vector2, character_height: float) -> void:
	var base_y: float = footprint.end.y
	var fade: bool = hides_character(visual_rect(), base_y, character_feet, character_height)
	modulate.a = FADED_ALPHA if fade else 1.0


static func hides_character(
	visible_area: Rect2, base_y: float, feet: Vector2, height: float
) -> bool:
	var width: float = CHARACTER_WIDTH
	var character: Rect2 = Rect2(feet.x - width * 0.5, feet.y - height, width, height)
	return feet.y < base_y and visible_area.intersects(character)
