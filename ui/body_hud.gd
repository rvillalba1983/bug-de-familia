class_name BodyHud
extends Control
## Indicador discreto del estado de cada pieza.

const BAR_SIZE: Vector2 = Vector2(46.0, 8.0)
const COLOR_OK: Color = Color("#7fe07f")
const COLOR_LOW: Color = Color("#e05050")
const COLOR_EMPTY: Color = Color(1.0, 1.0, 1.0, 0.15)

var body: ModularBody


func _ready() -> void:
	position = Vector2(1840.0, 930.0)
	body.changed.connect(queue_redraw)


func _draw() -> void:
	for slot: int in ModularBody.Slot.values():
		var at: Vector2 = Vector2(0.0, 13.0 * slot)
		draw_rect(Rect2(at, BAR_SIZE), COLOR_EMPTY)
		var piece: BodyPiece = body.equipped(slot as ModularBody.Slot)
		if piece != null:
			var ratio: float = piece.durability / BodyPiece.MAX_DURABILITY
			var fill: Rect2 = Rect2(at, Vector2(BAR_SIZE.x * ratio, BAR_SIZE.y))
			draw_rect(fill, COLOR_LOW.lerp(COLOR_OK, ratio))
