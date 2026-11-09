class_name AiSpectres
extends Control
## Durante la pausa táctica, todas las IAs flotan como espectros y divagan.
## Solo es ambiente: no gasta tokens y usa su propio azar para no tocar la semilla de la partida.

const SPEAK_INTERVAL: float = 3.2
const SPEAKERS: int = 3
const GHOST_ALPHA: float = 0.68
const LINE_ALPHA: float = 0.88
const LINE_WIDTH: float = 340.0
const FONT_SIZE: int = 16
const BOB_HEIGHT: float = 7.0
const SLOTS: Array[Vector2] = [
	Vector2(500, 70), Vector2(720, 60), Vector2(940, 75), Vector2(1160, 60), Vector2(1380, 70),
	Vector2(1600, 60), Vector2(1810, 80), Vector2(1810, 280), Vector2(1810, 480),
	Vector2(1810, 680), Vector2(1810, 880), Vector2(1600, 960), Vector2(1380, 975),
	Vector2(1160, 960), Vector2(940, 975), Vector2(730, 960), Vector2(520, 300),
	Vector2(520, 460), Vector2(1560, 300), Vector2(1560, 700),
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
		var talking: bool = _spoken.has(id)
		color.a = 0.8 if talking else GHOST_ALPHA
		var at: Vector2 = SLOTS[index] + Vector2(0.0, sin(_time * 1.6 + float(index)) * BOB_HEIGHT)
		_draw_ghost(at, info, color)
		if talking:
			_draw_line(at, str(_spoken[id]), Color(info["color"] as String))


func _draw_ghost(at: Vector2, info: Dictionary, color: Color) -> void:
	var y: float = at.y
	for row: Variant in info["avatar"]:
		draw_string(_mono, Vector2(at.x - 40.0, y), str(row), HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, color)
		y += 17.0


func _draw_line(at: Vector2, text: String, color: Color) -> void:
	color.a = LINE_ALPHA
	var x: float = clampf(at.x - LINE_WIDTH * 0.5, 20.0, 1900.0 - LINE_WIDTH)
	var below: bool = at.y < 540.0
	var y: float = at.y + 70.0 if below else at.y - 70.0
	var box: Rect2 = Rect2(x - 8.0, y - 20.0, LINE_WIDTH + 16.0, 70.0)
	draw_rect(box, Color(0.04, 0.02, 0.1, 0.72))
	draw_multiline_string(
		_mono, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, LINE_WIDTH, FONT_SIZE, 3, color
	)
