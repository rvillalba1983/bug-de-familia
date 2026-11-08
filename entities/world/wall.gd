class_name Wall
extends StaticBody2D
## Pared provisional. Su origen es el borde inferior de la huella, para el orden Y.

const FADED_ALPHA: float = 0.45
const COLOR_TOP: Color = Color("#8f8aa8")
const COLOR_FRONT: Color = Color("#55506e")
const COLOR_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.35)
const SHADOW_HEIGHT: float = 14.0

var footprint: Rect2
var front_height: float


func setup(new_footprint: Rect2, new_front_height: float) -> void:
	footprint = new_footprint
	front_height = new_front_height
	position = Vector2(footprint.position.x, footprint.end.y)
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = footprint.size
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(footprint.size.x * 0.5, -footprint.size.y * 0.5)
	add_child(collider)


func _draw() -> void:
	var width: float = footprint.size.x
	draw_rect(Rect2(0.0, 0.0, width, SHADOW_HEIGHT), COLOR_SHADOW)
	draw_rect(Rect2(0.0, -front_height, width, front_height), COLOR_FRONT)
	var top_height: float = footprint.size.y
	draw_rect(Rect2(0.0, -front_height - top_height, width, top_height), COLOR_TOP)


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
	var torso: Vector2 = feet - Vector2(0.0, height * 0.5)
	return feet.y < base_y and visible_area.has_point(torso)
