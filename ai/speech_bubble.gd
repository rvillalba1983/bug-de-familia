class_name SpeechBubble
extends Node2D
## Bocadillo de dibujos animados: trazo gordo, sombra de color y entrada con rebote.
## Sigue contando en pausa, durante las conversaciones. Mantiene su tamaño con cualquier zoom.

const FONT_SIZE: int = 19
const WIDTH: float = 330.0
const MIN_WIDTH: float = 130.0
const PADDING: float = 16.0
const CORNER: float = 24.0
const WOBBLE: float = 2.6
const OUTLINE: float = 5.0
const SHADOW: Vector2 = Vector2(8.0, 9.0)
const POP_TIME: float = 0.28
const COLOR_BACK: Color = Color("#FFF8E0")
const ACCENTS: Array[Color] = [
	Color("#FF1F8F"), Color("#00E5FF"), Color("#FFD400"), Color("#C6FF00"), Color("#FF6A00"),
]

static var _font: FontVariation

var text: String = ""
var border: Color = Color.BLACK

var _time_left: float = 0.0
var _pop: float = 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 50


func say(new_text: String, color: Color, duration: float) -> void:
	text = new_text
	border = color
	_time_left = duration
	_pop = 0.0
	visible = true
	set_process(true)
	queue_redraw()


func is_busy() -> bool:
	return _time_left > 0.0


func clear() -> void:
	_time_left = 0.0
	visible = false


func _process(delta: float) -> void:
	if _time_left > 0.0:
		_time_left -= delta
		if _time_left <= 0.0:
			visible = false
	if not visible:
		set_process(false)
		return
	_pop = minf(_pop + delta / POP_TIME, 1.0)
	var eased: float = 1.0 + 2.7 * pow(_pop - 1.0, 3.0) + 1.7 * pow(_pop - 1.0, 2.0)
	var zoom: float = get_canvas_transform().get_scale().x
	scale = Vector2.ONE * eased / maxf(zoom, 0.01)


func _draw() -> void:
	var font: Font = _bold()
	var inner: float = _text_width(font)
	var height: float = font.get_multiline_string_size(
		text, HORIZONTAL_ALIGNMENT_CENTER, inner, FONT_SIZE
	).y + PADDING * 2.0
	var box: Rect2 = Rect2(-inner * 0.5 - PADDING, -height, inner + PADDING * 2.0, height)
	var shape: PackedVector2Array = _blob(box)
	var accent: Color = _accent()
	draw_colored_polygon(_moved(shape, SHADOW), accent)
	draw_colored_polygon(shape, COLOR_BACK)
	_draw_outline(shape)
	_draw_tail()
	var start: Vector2 = Vector2(-inner * 0.5, -height + PADDING + font.get_ascent(FONT_SIZE))
	draw_multiline_string(
		font, start, text, HORIZONTAL_ALIGNMENT_CENTER, inner, FONT_SIZE, -1, Palette.INK
	)


func _bold() -> Font:
	if _font == null:
		_font = FontVariation.new()
		_font.base_font = ThemeDB.fallback_font
		_font.variation_embolden = 0.7
	return _font


func _text_width(font: Font) -> float:
	var one_line: float = font.get_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE
	).x + 6.0
	return clampf(one_line, MIN_WIDTH, WIDTH)


func _accent() -> Color:
	if border != Color.BLACK and border != Color.WHITE:
		return border
	return ACCENTS[absi(text.hash()) % ACCENTS.size()]


## Rectángulo redondeado con el borde algo tembloroso, como dibujado a mano.
func _blob(box: Rect2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var corners: Array[Vector2] = [
		box.position + Vector2(CORNER, CORNER),
		Vector2(box.end.x - CORNER, box.position.y + CORNER),
		box.end - Vector2(CORNER, CORNER),
		Vector2(box.position.x + CORNER, box.end.y - CORNER),
	]
	var phase: float = float(absi(text.hash()) % 100)
	for index: int in range(4):
		for step: int in range(9):
			var angle: float = PI + float(index) * PI * 0.5 + float(step) / 8.0 * PI * 0.5
			var wobble: float = sin(angle * 5.0 + phase) * WOBBLE
			points.append(corners[index] + Vector2.from_angle(angle) * (CORNER + wobble))
	return points


func _moved(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		result.append(point + offset)
	return result


func _draw_outline(shape: PackedVector2Array) -> void:
	var closed: PackedVector2Array = shape.duplicate()
	closed.append(shape[0])
	draw_polyline(closed, Palette.INK, OUTLINE, true)


## El pico tapa el trozo de borde donde nace, para que parezca una sola forma.
func _draw_tail() -> void:
	var left: Vector2 = Vector2(-20.0, -3.0)
	var right: Vector2 = Vector2(14.0, -3.0)
	var tip: Vector2 = Vector2(-12.0, 24.0)
	draw_colored_polygon(_moved(PackedVector2Array([left, right, tip]), SHADOW), _accent())
	draw_colored_polygon(
		PackedVector2Array([left + Vector2(0.0, -4.0), right + Vector2(0.0, -4.0), tip]), COLOR_BACK
	)
	draw_line(left, tip, Palette.INK, OUTLINE, true)
	draw_line(right, tip, Palette.INK, OUTLINE, true)
