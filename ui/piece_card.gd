class_name PieceCard
extends Control
## Una pieza dibujada entera. Marco: nivel. Estrella: especial. Barra: desgaste.
## Clic izquierdo la pone; clic derecho la descarta.

signal equip_requested
signal discard_requested

const SIZE: Vector2 = Vector2(92.0, 122.0)
const LEVEL_COLORS: Array[Color] = [
	Color("#9aa3b2"), Color("#6fe04a"), Color("#3fa8ff"), Color("#c060ff"), Color("#ff9a3c"),
]
const COLOR_BACK: Color = Color("#1b1228")
const COLOR_STAR: Color = Color("#ffe14a")

var piece: BodyPiece
var slot: ModularBody.Slot
var is_worn: bool = false
var can_equip: bool = true


func _ready() -> void:
	custom_minimum_size = SIZE
	size = SIZE
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "%s\n%s" % [piece.label, piece.description]


func _gui_input(event: InputEvent) -> void:
	if is_worn or not event is InputEventMouseButton or not event.is_pressed():
		return
	var button: InputEventMouseButton = event
	if button.button_index == MOUSE_BUTTON_LEFT and can_equip:
		equip_requested.emit()
	elif button.button_index == MOUSE_BUTTON_RIGHT:
		discard_requested.emit()


static func level_color(level: int) -> Color:
	return LEVEL_COLORS[clampi(level, 1, LEVEL_COLORS.size()) - 1]


func _draw() -> void:
	var frame: Color = level_color(piece.level)
	var area: Rect2 = Rect2(Vector2.ZERO, SIZE)
	draw_rect(area, COLOR_BACK)
	ProtagonistArt.draw_piece(self, Rect2(8.0, 8.0, SIZE.x - 16.0, SIZE.y - 40.0), slot, piece)
	draw_rect(area, frame, false, 8.0 if is_worn else 4.0)
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(9.0, SIZE.y - 18.0), "Nv %d" % piece.level, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, frame)
	if piece.is_special():
		_draw_star(Vector2(SIZE.x - 17.0, 18.0), 12.0)
	var ratio: float = piece.durability / BodyPiece.MAX_DURABILITY
	draw_rect(Rect2(8.0, SIZE.y - 12.0, SIZE.x - 16.0, 6.0), Color.BLACK)
	draw_rect(Rect2(8.0, SIZE.y - 12.0, (SIZE.x - 16.0) * ratio, 6.0), ProtagonistArt.wear_color(ratio))
	if not is_worn and not can_equip:
		draw_rect(area, Color(0.0, 0.0, 0.0, 0.55))


func _draw_star(center: Vector2, radius: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(10):
		var reach: float = radius if index % 2 == 0 else radius * 0.45
		var angle: float = -PI * 0.5 + float(index) * PI / 5.0
		points.append(center + Vector2(cos(angle), sin(angle)) * reach)
	draw_colored_polygon(points, COLOR_STAR)
