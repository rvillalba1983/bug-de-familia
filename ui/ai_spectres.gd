class_name AiSpectres
extends Control
## Durante la pausa táctica, todas las IAs son bocas exageradas sentadas en butacas enormes.
## Solo es ambiente: no gasta tokens y usa su propio azar para no tocar la semilla de la partida.

const SPEAK_INTERVAL: float = 3.2
const SPEAKERS: int = 3
const LINE_ALPHA: float = 0.92
const LINE_WIDTH: float = 340.0
const FONT_SIZE: int = 16
const CURVE_STEPS: int = 14
const MOUTH_WIDTH: float = 46.0
const MOUTH_HEIGHT: float = 34.0
const COLOR_INSIDE: Color = Color("#2a0a14")
const COLOR_TONGUE: Color = Color("#e0405a")
const COLOR_TEETH: Color = Color("#fff6e0")
const COLOR_INK: Color = Color("#140a1e")
const SLOTS: Array[Vector2] = [
	Vector2(530, 100), Vector2(730, 100), Vector2(1210, 100), Vector2(1420, 100),
	Vector2(1630, 100), Vector2(1840, 100), Vector2(1840, 290), Vector2(1840, 480),
	Vector2(1840, 670), Vector2(1840, 860), Vector2(1630, 985), Vector2(1430, 985),
	Vector2(1230, 985), Vector2(1030, 985), Vector2(830, 985), Vector2(540, 340),
	Vector2(540, 540), Vector2(1630, 340), Vector2(1630, 660), Vector2(1630, 500),
]

var team: AiTeam

var _mono: SystemFont
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _ghosts: Array = []
var _spoken: Dictionary = {}
var _time: float = 0.0
var _next_line: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_mono = SystemFont.new()
	_mono.font_names = PackedStringArray([
		"Courier New", "Consolas", "DejaVu Sans Mono", "Liberation Mono", "monospace"
	])


func set_shown(shown: bool) -> void:
	visible = shown
	if shown:
		_ghosts = team.ais.keys().filter(func(id: String) -> bool: return not team.lost.has(id))
		_next_line = 0.0
		_spoken.clear()


func speaking() -> Dictionary:
	return _spoken


func ghosts() -> Array:
	return _ghosts


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	_next_line -= delta
	if _next_line <= 0.0:
		_next_line = SPEAK_INTERVAL
		_pick_lines()
	queue_redraw()


func _pick_lines() -> void:
	_spoken.clear()
	var pool: Array = _ghosts.duplicate()
	while _spoken.size() < SPEAKERS and not pool.is_empty():
		var id: String = pool.pop_at(_rng.randi_range(0, pool.size() - 1))
		var lines: Array = team.ais[id]["spectre"]
		_spoken[id] = lines[_rng.randi_range(0, lines.size() - 1)]


func _draw() -> void:
	for index: int in range(mini(_ghosts.size(), SLOTS.size())):
		var id: String = _ghosts[index]
		var info: Dictionary = team.ais[id]
		var color: Color = Color(info["color"] as String)
		_draw_armchair(SLOTS[index], color)
		_draw_gesture(SLOTS[index], color, float(index), _spoken.has(id))
		_draw_name(SLOTS[index], str(info["name"]))
	for index: int in range(mini(_ghosts.size(), SLOTS.size())):
		var id: String = _ghosts[index]
		if _spoken.has(id):
			_draw_line(SLOTS[index], str(_spoken[id]), Color(team.ais[id]["color"] as String))


func _draw_armchair(at: Vector2, color: Color) -> void:
	var fabric: Color = color.darkened(0.45)
	var cushion: Color = color.darkened(0.2)
	_box(Rect2(at + Vector2(-58, -74), Vector2(116, 112)), fabric)
	_box(Rect2(at + Vector2(-48, 8), Vector2(96, 36)), cushion)
	_box(Rect2(at + Vector2(-78, -18), Vector2(30, 64)), cushion)
	_box(Rect2(at + Vector2(48, -18), Vector2(30, 64)), cushion)
	for x: float in [-32.0, 0.0, 32.0]:
		draw_circle(at + Vector2(x, -56), 4.0, COLOR_INK)
	for x: float in [-66.0, 62.0]:
		draw_rect(Rect2(at + Vector2(x, 46), Vector2(9, 12)), COLOR_INK)


func _box(area: Rect2, color: Color) -> void:
	draw_rect(area, color)
	draw_rect(area, COLOR_INK, false, 3.0)


## Quien habla abre la boca a lo bestia; el resto hace muecas lentas.
func _draw_gesture(at: Vector2, color: Color, index: float, talking: bool) -> void:
	var open: float
	var smile: float
	var tilt: float
	var hop: float = 0.0
	if talking:
		open = 0.45 + 0.55 * absf(sin(_time * 9.0 + index))
		smile = 0.5 * sin(_time * 4.0 + index)
		tilt = 0.28 * sin(_time * 6.0 + index)
		hop = -absf(sin(_time * 9.0 + index)) * 16.0
	else:
		open = 0.08 + 0.16 * maxf(sin(_time * 1.3 + index * 2.1), 0.0)
		smile = sin(_time * 0.8 + index * 1.7)
		tilt = 0.12 * sin(_time * 0.6 + index)
	_draw_mouth(at + Vector2(0.0, -18.0 + hop), open, smile, tilt, color)


func _draw_mouth(center: Vector2, open: float, smile: float, tilt: float, lip: Color) -> void:
	var width: float = MOUTH_WIDTH * (1.05 - 0.2 * open)
	draw_set_transform(center, tilt, Vector2.ONE)
	var upper: PackedVector2Array = _curve(width, -(6.0 + MOUTH_HEIGHT * open), smile)
	var lower: PackedVector2Array = _curve(width, 6.0 + MOUTH_HEIGHT * open, smile)
	draw_colored_polygon(_shape(_grow(upper, 9.0), _grow(lower, 9.0)), lip)
	draw_colored_polygon(_shape(upper, lower), COLOR_INSIDE)
	if open > 0.2:
		_draw_teeth(upper, 11.0 + 8.0 * open)
		draw_circle(Vector2(0.0, MOUTH_HEIGHT * open * 0.55), 11.0 + 9.0 * open, COLOR_TONGUE)
	draw_polyline(_closed(_grow(upper, 9.0), _grow(lower, 9.0)), COLOR_INK, 3.0)
	draw_set_transform(Vector2.ZERO)


func _draw_teeth(upper: PackedVector2Array, height: float) -> void:
	for index: int in range(3, CURVE_STEPS - 3, 2):
		var left: Vector2 = upper[index]
		var right: Vector2 = upper[index + 2]
		draw_rect(Rect2(left.x + 1.0, minf(left.y, right.y), right.x - left.x - 2.0, height), COLOR_TEETH)


func _curve(width: float, bulge: float, smile: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(CURVE_STEPS + 1):
		var t: float = float(step) / float(CURVE_STEPS)
		var x: float = lerpf(-width, width, t)
		var corner: float = -smile * 12.0 * pow(absf(2.0 * t - 1.0), 2.0)
		points.append(Vector2(x, sin(t * PI) * bulge + corner))
	return points


func _grow(curve: PackedVector2Array, amount: float) -> PackedVector2Array:
	var out: PackedVector2Array = curve.duplicate()
	var direction: float = -1.0 if curve[CURVE_STEPS / 2].y < curve[0].y else 1.0
	for index: int in range(out.size()):
		out[index].y += direction * amount
	return out


func _shape(top: PackedVector2Array, bottom: PackedVector2Array) -> PackedVector2Array:
	var reversed: PackedVector2Array = bottom.duplicate()
	reversed.reverse()
	if reversed[0].is_equal_approx(top[top.size() - 1]):
		reversed = reversed.slice(1, reversed.size() - 1)
	return top + reversed


func _closed(top: PackedVector2Array, bottom: PackedVector2Array) -> PackedVector2Array:
	var points: PackedVector2Array = _shape(top, bottom)
	points.append(points[0])
	return points


func _draw_name(at: Vector2, label: String) -> void:
	draw_string_outline(
		_mono, at + Vector2(-75.0, 74.0), label, HORIZONTAL_ALIGNMENT_CENTER, 150.0, 13, 4, COLOR_INK
	)
	draw_string(_mono, at + Vector2(-75.0, 74.0), label, HORIZONTAL_ALIGNMENT_CENTER, 150.0, 13, Color.WHITE)


func _draw_line(at: Vector2, text: String, color: Color) -> void:
	color.a = LINE_ALPHA
	var x: float = clampf(at.x - LINE_WIDTH * 0.5, 20.0, 1900.0 - LINE_WIDTH)
	var y: float = at.y + 112.0 if at.y < 540.0 else at.y - 120.0
	draw_rect(Rect2(x - 8.0, y - 20.0, LINE_WIDTH + 16.0, 70.0), Color(0.04, 0.02, 0.1, 0.86))
	draw_multiline_string(
		_mono, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, LINE_WIDTH, FONT_SIZE, 3, color
	)
