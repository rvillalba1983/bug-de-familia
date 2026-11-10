class_name AiSpectres
extends Control
## Durante la pausa táctica, las tres IAs activas son fantasmas de colores, con ojos y boca propios.
## Solo es ambiente: no gasta tokens y usa su propio azar para no tocar la semilla de la partida.
## Punto de enganche de P-26 (post-beta): el futuro gestor multi-zona o la pantalla de
## viaje rápido debe crear este nodo con `team` y llamar a `set_shown(true)` mientras el
## juego esté parado, igual que `ConversionScreen._reset()`. Hoy solo se usa en la pausa
## táctica y en la conversión; el viaje rápido aún no está implementado. Sigue abierta la
## duda de si el tiempo del mundo avanza durante el viaje (decisión del director).

const SPEAK_INTERVAL: float = 3.2
const SPEAKERS: int = 3
const LINE_ALPHA: float = 0.92
const LINE_WIDTH: float = 340.0
const FONT_SIZE: int = 16
const CURVE_STEPS: int = 14
const MOUTH_WIDTH: float = 46.0
const MOUTH_HEIGHT: float = 26.0
const COLOR_INSIDE: Color = Color("#2a0a14")
const COLOR_TONGUE: Color = Color("#e0405a")
const COLOR_TEETH: Color = Color("#fff6e0")
const COLOR_INK: Color = Color("#140a1e")
const SLOTS: Array[Vector2] = [Vector2(720, 215), Vector2(1090, 215), Vector2(1460, 215)]
const SIZE: float = 1.7
const GHOST_HALF_WIDTH: float = 66.0
const GHOST_ALPHA: float = 0.94
const GHOST_ARC_STEPS: int = 20
const GHOST_WAVE_STEPS: int = 24
const FLOAT_HEIGHT: float = 4.0

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
		_ghosts = team.active.filter(func(id: String) -> bool: return not team.lost.has(id))
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
		var at: Vector2 = SLOTS[index]
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(SIZE, SIZE))
		_draw_ghost(at / SIZE + Vector2(0.0, _float_offset(index)), color)
		_draw_gesture(at + Vector2(0.0, _float_offset(index) * SIZE), color, float(index), _spoken.has(id), AiFace.face_of(id))
		draw_set_transform(Vector2.ZERO)
		_draw_name(at, str(info["name"]))
		if _spoken.has(id):
			_draw_line(at, str(_spoken[id]), color)


func _float_offset(index: int) -> float:
	return sin(_time * 1.6 + float(index) * 2.0) * FLOAT_HEIGHT


## Sábana de fantasma: cabeza redonda, dos bracitos y el borde inferior ondulado.
func _draw_ghost(at: Vector2, color: Color) -> void:
	var fabric: Color = color.lightened(0.3)
	fabric.a = GHOST_ALPHA
	var outline: PackedVector2Array = _ghost_outline(at)
	draw_colored_polygon(outline, fabric)
	outline.append(outline[0])
	draw_polyline(outline, COLOR_INK, 3.0)


func _ghost_outline(at: Vector2) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(GHOST_ARC_STEPS + 1):
		var angle: float = PI + PI * float(step) / float(GHOST_ARC_STEPS)
		points.append(at + Vector2(cos(angle) * GHOST_HALF_WIDTH, -38.0 + sin(angle) * 66.0))
	points.append(at + Vector2(GHOST_HALF_WIDTH + 2.0, 0.0))
	points.append(at + Vector2(GHOST_HALF_WIDTH + 24.0, 8.0))
	points.append(at + Vector2(GHOST_HALF_WIDTH + 2.0, 24.0))
	var bottom: float = 60.0
	for step: int in range(GHOST_WAVE_STEPS + 1):
		var t: float = float(step) / float(GHOST_WAVE_STEPS)
		var x: float = lerpf(GHOST_HALF_WIDTH + 2.0, -GHOST_HALF_WIDTH - 2.0, t)
		var wave: float = sin(t * TAU * 3.0 + _time * 2.0) * 9.0
		points.append(at + Vector2(x, bottom + wave))
	points.append(at + Vector2(-GHOST_HALF_WIDTH - 2.0, 24.0))
	points.append(at + Vector2(-GHOST_HALF_WIDTH - 24.0, 8.0))
	points.append(at + Vector2(-GHOST_HALF_WIDTH - 2.0, 0.0))
	return points


## Quien habla abre la boca a lo bestia; el resto hace muecas lentas.
func _draw_gesture(at: Vector2, color: Color, index: float, talking: bool, face: Dictionary) -> void:
	var rest: float = float(face["rest_open"])
	var base_smile: float = float(face["smile"])
	var open: float = rest + 0.1 * maxf(sin(_time * 1.3 + index * 2.1), 0.0)
	var tilt: float = 0.06 * sin(_time * 0.6 + index) + float(face.get("skew", 0.0))
	var hop: float = 0.0
	if talking:
		open = minf(maxf(rest, 0.25) + 0.35 * absf(sin(_time * 9.0 + index)), 0.7)
		tilt += 0.18 * sin(_time * 6.0 + index)
		hop = -absf(sin(_time * 9.0 + index)) * 6.0
	draw_set_transform(at + Vector2(0.0, -56.0 + hop * 0.5) * SIZE, 0.0, Vector2(SIZE, SIZE))
	AiFace.draw_eyes(self, Vector2.ZERO, face, _time + index)
	_draw_mouth(at + Vector2(0.0, 8.0 + hop) * SIZE, open, base_smile, tilt, color, face)
	draw_set_transform(Vector2.ZERO)


func _draw_mouth(center: Vector2, open: float, smile: float, tilt: float, base_lip: Color, face: Dictionary) -> void:
	var width: float = MOUTH_WIDTH * float(face["width"]) * (1.05 - 0.2 * open)
	var lip: Color = Color(face["lip"] as String) if face.has("lip") else base_lip
	var wobble: float = float(face.get("wobble", 0.0))
	draw_set_transform(center, tilt, Vector2(SIZE, SIZE))
	var upper: PackedVector2Array = _curve(width, -(6.0 + MOUTH_HEIGHT * open), smile, wobble)
	var lower: PackedVector2Array = _curve(width, 6.0 + MOUTH_HEIGHT * open, smile, wobble)
	draw_colored_polygon(_shape(_grow(upper, 9.0), _grow(lower, 9.0)), lip)
	draw_colored_polygon(_shape(upper, lower), COLOR_INSIDE)
	if open > 0.2:
		_draw_teeth(upper, 11.0 + 8.0 * open, str(face["teeth"]))
		draw_circle(Vector2(0.0, MOUTH_HEIGHT * open * 0.55), 11.0 + 9.0 * open, COLOR_TONGUE)
	if face.get("tongue_out", false):
		var drop: Vector2 = lower[CURVE_STEPS / 2]
		draw_rect(Rect2(drop.x - 11.0, drop.y - 4.0, 22.0, 22.0), COLOR_TONGUE)
		draw_circle(drop + Vector2(0.0, 18.0), 11.0, COLOR_TONGUE)
	draw_polyline(_closed(_grow(upper, 9.0), _grow(lower, 9.0)), COLOR_INK, 3.0)


func _draw_teeth(upper: PackedVector2Array, height: float, kind: String) -> void:
	if kind == "ninguno":
		return
	var middle: int = CURVE_STEPS / 2
	for index: int in range(3, CURVE_STEPS - 3, 2):
		var near_middle: bool = absi(index + 1 - middle) <= 1
		if (kind == "uno" and index != 5) or (kind == "conejo" and not near_middle):
			continue
		var left: Vector2 = upper[index]
		var right: Vector2 = upper[index + 2]
		var long: float = height * 1.7 if kind == "conejo" else height
		draw_rect(Rect2(left.x + 1.0, minf(left.y, right.y), right.x - left.x - 2.0, long), COLOR_TEETH)


func _curve(width: float, bulge: float, smile: float, wobble: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(CURVE_STEPS + 1):
		var t: float = float(step) / float(CURVE_STEPS)
		var x: float = lerpf(-width, width, t)
		var corner: float = -smile * 12.0 * pow(absf(2.0 * t - 1.0), 2.0)
		var shake: float = sin(float(step) * 2.4) * wobble
		points.append(Vector2(x, sin(t * PI) * bulge + corner + shake))
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
		_mono, at + Vector2(-110.0, 78.0 * SIZE + 8.0), label, HORIZONTAL_ALIGNMENT_CENTER, 220.0, 16, 4, COLOR_INK
	)
	draw_string(_mono, at + Vector2(-110.0, 78.0 * SIZE + 8.0), label, HORIZONTAL_ALIGNMENT_CENTER, 220.0, 16, Color.WHITE)


func _draw_line(at: Vector2, text: String, color: Color) -> void:
	color.a = LINE_ALPHA
	var x: float = clampf(at.x - LINE_WIDTH * 0.5, 20.0, 1900.0 - LINE_WIDTH)
	var y: float = at.y + 78.0 * SIZE + 44.0
	draw_rect(Rect2(x - 8.0, y - 20.0, LINE_WIDTH + 16.0, 70.0), Color(0.04, 0.02, 0.1, 0.86))
	draw_multiline_string(
		_mono, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, LINE_WIDTH, FONT_SIZE, 3, color
	)
