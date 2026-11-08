class_name SpeechBubble
extends Node2D
## Bocadillo de cómic. Sigue contando en pausa, durante las conversaciones.

const FONT_SIZE: int = 15
const WIDTH: float = 320.0
const PADDING: float = 8.0
const COLOR_BACK: Color = Color(0.97, 0.97, 0.92, 0.96)
const COLOR_TEXT: Color = Color(0.08, 0.08, 0.1)

var text: String = ""
var border: Color = Color.BLACK

var _time_left: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 50


func say(new_text: String, color: Color, duration: float) -> void:
	text = new_text
	border = color
	_time_left = duration
	visible = true
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


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var inner: float = WIDTH - PADDING * 2.0
	var size_text: Vector2 = font.get_multiline_string_size(
		text, HORIZONTAL_ALIGNMENT_LEFT, inner, FONT_SIZE
	)
	var height: float = size_text.y + PADDING * 2.0
	var box: Rect2 = Rect2(-WIDTH * 0.5, -height, WIDTH, height)
	draw_rect(box, COLOR_BACK)
	draw_rect(box, border, false, 3.0)
	var tip: PackedVector2Array = PackedVector2Array(
		[Vector2(-10.0, 0.0), Vector2(10.0, 0.0), Vector2(0.0, 14.0)]
	)
	draw_colored_polygon(tip, COLOR_BACK)
	var start: Vector2 = Vector2(-inner * 0.5, -height + PADDING + font.get_ascent(FONT_SIZE))
	draw_multiline_string(
		font, start, text, HORIZONTAL_ALIGNMENT_LEFT, inner, FONT_SIZE, -1, COLOR_TEXT
	)
