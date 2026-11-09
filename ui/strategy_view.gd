class_name StrategyView
extends CanvasLayer
## Solo la pelea, ampliada, con muñequitos patosos dando saltos. M abre y cierra; 1, 2 y 3 dan x1, x2 y x4.

const SPEEDS: Array[float] = [1.0, 2.0, 4.0]
const VIEW: Vector2 = Vector2(1920.0, 1080.0)
const FRAME_MARGIN: Vector2 = Vector2(520.0, 420.0)
const ZOOM_MIN: float = 0.7
const ZOOM_MAX: float = 1.9
const CAMERA_SPEED: float = 2.5
const DIRT_STEP: float = 160.0
const COLOR_GROUND: Color = Color("#a8875a")
const COLOR_DIRT: Color = Color("#957548")
const COLOR_INK: Color = Color("#1a1024")
const COLOR_TONGUE: Color = Color("#e0405a")
const MOOD_TIME: float = 1.3

enum Mood { ANGRY, DISGUST, SCREAM, SMUG, PANIC }

var director: BattleDirector
var is_open: bool = false

var _canvas: Control
var _focus: Vector2 = Vector2.ZERO
var _zoom: float = 1.0
var _time: float = 0.0


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 9
	visible = false


func _ready() -> void:
	_canvas = Control.new()
	_canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	_canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_canvas.draw.connect(_draw_map)
	add_child(_canvas)


func open() -> void:
	is_open = true
	visible = true
	_update_camera(0.0, true)
	director.level.player.controls_locked = true


func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	director.level.player.controls_locked = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"map") and not event.is_echo() and not is_open:
		if director.phase == BattleDirector.Phase.RUNNING:
			open()
			get_viewport().set_input_as_handled()
		return
	if is_open and event.is_action_pressed(&"close_panel") and not event.is_echo():
		director.close_view()
		get_viewport().set_input_as_handled()
		return
	if not is_open:
		return
	for index: int in range(SPEEDS.size()):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			director.set_speed(SPEEDS[index])
			get_viewport().set_input_as_handled()
			return


func _process(delta: float) -> void:
	if not is_open:
		return
	if director.level.fight.phase != FightDirector.Phase.CALM:
		director.close_view()
		return
	_time += delta * director.speed
	_update_camera(delta, false)
	_canvas.queue_redraw()


func _draw_map() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, VIEW), COLOR_GROUND)
	_draw_dirt()
	for species: String in director.species:
		_draw_fallen(species)
	var fighters: Array = []
	for species: String in director.species:
		for guard: Guard in director.alive_in(species):
			fighters.append([guard, species])
	fighters.sort_custom(func(a: Array, b: Array) -> bool:
		return (a[0] as Guard).global_position.y < (b[0] as Guard).global_position.y)
	for entry: Array in fighters:
		_draw_fighter(entry[0] as Guard, str(entry[1]))
	_draw_labels()


func _draw_labels() -> void:
	var font: Font = ThemeDB.fallback_font
	var line: float = 44.0
	for species: String in director.species:
		var text: String = "%s: %d" % [director.data["names"][species], director.alive_in(species).size()]
		_canvas.draw_string_outline(font, Vector2(1590.0, line), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 6, Color.BLACK)
		_canvas.draw_string(font, Vector2(1590.0, line), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, SpeciesCatalog.map_color(species))
		line += 36.0
	var help: String = "x%d   ·   1: x1   2: x2   3: x4   ·   M: salir" % roundi(director.speed)
	_canvas.draw_string_outline(font, Vector2(24.0, 44.0), help, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, 6, Color.BLACK)
	_canvas.draw_string(font, Vector2(24.0, 44.0), help, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)


func _to_view(point: Vector2) -> Vector2:
	return VIEW * 0.5 + (point - _focus) * _zoom


## La cámara encuadra solo a quienes pelean.
func _update_camera(delta: float, snap: bool) -> void:
	var box: Rect2 = Rect2()
	var first: bool = true
	for species: String in director.species:
		for guard: Guard in director.alive_in(species):
			box = Rect2(guard.global_position, Vector2.ZERO) if first else box.expand(guard.global_position)
			first = false
	if first:
		return
	var need: Vector2 = box.size + FRAME_MARGIN
	var zoom: float = clampf(minf(VIEW.x / need.x, VIEW.y / need.y), ZOOM_MIN, ZOOM_MAX)
	var blend: float = 1.0 if snap else clampf(delta * CAMERA_SPEED, 0.0, 1.0)
	_focus = _focus.lerp(box.get_center(), blend)
	_zoom = lerpf(_zoom, zoom, blend)


func _draw_dirt() -> void:
	var step: float = DIRT_STEP
	var origin: Vector2 = (_focus - VIEW * 0.5 / _zoom).snapped(Vector2(step, step)) - Vector2(step, step)
	var count: Vector2i = Vector2i(ceili(VIEW.x / _zoom / step) + 3, ceili(VIEW.y / _zoom / step) + 3)
	for x: int in range(count.x):
		for y: int in range(count.y):
			var world: Vector2 = origin + Vector2(x, y) * step
			var seed_value: int = hash(world)
			var offset: Vector2 = Vector2(posmod(seed_value, 70), posmod(seed_value / 7, 70))
			var size: float = (10.0 + float(posmod(seed_value / 13, 26))) * _zoom
			_canvas.draw_circle(_to_view(world + offset), size, COLOR_DIRT)


func _draw_fallen(species: String) -> void:
	for id: String in director.sides[species]:
		var guard: Variant = director.level.live_world.citizens.get(id)
		if is_instance_valid(guard) and (guard as Guard).is_down():
			var spot: Vector2 = _to_view((guard as Guard).global_position)
			var style: int = absi((guard as Guard).get_instance_id()) % 628
			_draw_body(spot, species, _time * 3.0, 0.0, 1.0, true, false, style)
			_draw_soul(spot, float(style) * 0.01)


func _draw_fighter(guard: Guard, species: String) -> void:
	var at: Vector2 = guard.global_position
	var phase: float = float(absi(guard.get_instance_id()) % 628) * 0.01
	var near: bool = _is_fighting(guard, species)
	var beat: float = _time * (17.0 if near else 12.0) + phase
	var hop: float = absf(sin(beat)) * (30.0 if near else 16.0) * _zoom
	var tilt: float = sin(beat) * (0.42 if near else 0.28)
	var squash: float = 0.84 + 0.2 * absf(cos(beat))
	var spot: Vector2 = _to_view(at)
	_canvas.draw_set_transform(spot, 0.0, Vector2.ONE)
	_canvas.draw_circle(Vector2(0.0, 6.0), 26.0 * _zoom, Color(0.0, 0.0, 0.0, 0.3))
	_canvas.draw_set_transform(Vector2.ZERO)
	_draw_body(spot - Vector2(0.0, hop), species, beat, tilt, squash, false, near, _mood_of(phase, near))
	if near and sin(beat * 0.5) > 0.93:
		_draw_bonk(spot - Vector2(0.0, 92.0 * _zoom), phase)


func _is_fighting(guard: Guard, species: String) -> bool:
	var rival: String = SpeciesCatalog.rival(species)
	for foe: Guard in director.alive_in(rival):
		if guard.global_position.distance_to(foe.global_position) <= BattleDirector.STRIKE_RANGE * 1.4:
			return true
	return false


func _draw_bonk(at: Vector2, phase: float) -> void:
	var words: Array = director.data["bonks"]
	var word: String = words[int(phase * 100.0) % words.size()]
	var font: Font = ThemeDB.fallback_font
	_canvas.draw_string_outline(font, at, word, HORIZONTAL_ALIGNMENT_CENTER, 200.0, 30, 8, Color.BLACK)
	_canvas.draw_string(font, at, word, HORIZONTAL_ALIGNMENT_CENTER, 200.0, 30, Color("#ffe14a"))


## Muñequitos propios de cada raza, cabezones y patosos.
func _draw_body(at: Vector2, species: String, beat: float, tilt: float, squash: float, down: bool, flailing: bool, mood: int) -> void:
	var scale_size: Vector2 = Vector2(_zoom * (2.0 - squash), _zoom * squash)
	_canvas.draw_set_transform(at, PI * 0.5 if down else tilt, scale_size)
	var swing: float = sin(beat) * 12.0
	if not down:
		_canvas.draw_line(Vector2(-11.0, -4.0), Vector2(-11.0 - swing * 0.5, 12.0), COLOR_INK, 7.0)
		_canvas.draw_line(Vector2(11.0, -4.0), Vector2(11.0 + swing * 0.5, 12.0), COLOR_INK, 7.0)
	var arm: float = sin(beat * 2.0) * 22.0 if flailing else swing
	var raised: float = -48.0 if flailing else -22.0
	_canvas.draw_line(Vector2(-24.0, -30.0), Vector2(-44.0, raised + arm), COLOR_INK, 6.0)
	_canvas.draw_line(Vector2(24.0, -30.0), Vector2(44.0, raised - arm), COLOR_INK, 6.0)
	_canvas.draw_circle(Vector2(-44.0, raised + arm), 7.0, Color("#ffd8b0"))
	_canvas.draw_circle(Vector2(44.0, raised - arm), 7.0, Color("#ffd8b0"))
	if SpeciesCatalog.doll(species) == "jubilado":
		_draw_jubilado()
	else:
		_draw_mohocrata()
	if down:
		_draw_death(mood, beat)
	else:
		_draw_face(mood, beat)
	_canvas.draw_set_transform(Vector2.ZERO)


func _draw_jubilado() -> void:
	_canvas.draw_circle(Vector2(0.0, -34.0), 32.0, COLOR_INK)
	_canvas.draw_circle(Vector2(0.0, -34.0), 28.0, Color("#a8b0c4"))
	_canvas.draw_rect(Rect2(-22.0, -68.0, 44.0, 10.0), Color("#6a3fa8"))
	_canvas.draw_circle(Vector2(0.0, -70.0), 16.0, Color("#6a3fa8"))
	_canvas.draw_circle(Vector2(0.0, -16.0), 5.0, Color("#ff9a3c"))


func _draw_mohocrata() -> void:
	_canvas.draw_rect(Rect2(-20.0, -36.0, 40.0, 36.0), COLOR_INK)
	_canvas.draw_rect(Rect2(-16.0, -36.0, 32.0, 32.0), Color("#a0d060"))
	_canvas.draw_circle(Vector2(0.0, -52.0), 36.0, COLOR_INK)
	_canvas.draw_circle(Vector2(0.0, -52.0), 32.0, Color("#e0408a"))
	_canvas.draw_circle(Vector2(-16.0, -62.0), 6.0, Color("#ffe6f0"))
	_canvas.draw_circle(Vector2(15.0, -68.0), 5.0, Color("#ffe6f0"))
	_canvas.draw_rect(Rect2(-14.0, -92.0, 28.0, 14.0), Color("#8a5a30"))


func _mood_of(phase: float, near: bool) -> int:
	var turn: int = int(_time / MOOD_TIME + phase * 3.0)
	if near:
		return [Mood.ANGRY, Mood.SCREAM, Mood.ANGRY, Mood.DISGUST][turn % 4]
	return [Mood.DISGUST, Mood.SMUG, Mood.PANIC, Mood.ANGRY][turn % 4]


func _draw_face(mood: int, beat: float) -> void:
	_draw_eye_pair(0.4 if mood == Mood.PANIC else 1.0, beat, mood == Mood.SMUG, mood == Mood.DISGUST)
	match mood:
		Mood.ANGRY:
			_brows(0.55)
			_canvas.draw_arc(Vector2(0.0, -6.0), 11.0, PI * 1.15, PI * 1.85, 10, COLOR_INK, 4.0)
		Mood.DISGUST:
			_brows(-0.2)
			_canvas.draw_polyline(_wavy(-12.0, 12.0, -15.0), COLOR_INK, 4.0)
			_canvas.draw_circle(Vector2(5.0, -9.0), 6.0, COLOR_TONGUE)
		Mood.SCREAM:
			_brows(-0.5)
			_canvas.draw_circle(Vector2(0.0, -11.0), 8.0 + 2.0 * absf(sin(beat)), COLOR_INK)
		Mood.SMUG:
			_canvas.draw_arc(Vector2(3.0, -22.0), 13.0, PI * 0.15, PI * 0.7, 8, COLOR_INK, 4.0)
		Mood.PANIC:
			_brows(-0.45)
			_canvas.draw_polyline(_wavy(-11.0, 11.0, -13.0), COLOR_INK, 3.0)


func _brows(slant: float) -> void:
	for side: float in [-1.0, 1.0]:
		var center: Vector2 = Vector2(side * 11.0, -43.0)
		var offset: Vector2 = Vector2(9.0, side * slant * 7.0)
		_canvas.draw_line(center - offset, center + offset, COLOR_INK, 5.0)


func _wavy(from_x: float, to_x: float, y: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(9):
		var t: float = float(step) / 8.0
		points.append(Vector2(lerpf(from_x, to_x, t), y + sin(t * TAU * 1.5) * 3.0))
	return points


func _draw_eye_pair(pupil: float, beat: float, half_lid: bool, squint: bool) -> void:
	for side: float in [-11.0, 11.0]:
		var eye: Vector2 = Vector2(side, -30.0)
		if squint and side > 0.0:
			_canvas.draw_line(eye + Vector2(-8, 0), eye + Vector2(8, -3), COLOR_INK, 5.0)
			continue
		_canvas.draw_circle(eye, 10.0, Color.WHITE)
		_canvas.draw_circle(eye + Vector2(sin(beat * 0.7) * 3.0, cos(beat * 0.9) * 2.0), 5.0 * pupil, COLOR_INK)
		if half_lid:
			_canvas.draw_rect(Rect2(eye + Vector2(-10, -10), Vector2(20, 10)), Color("#8a90a8"))


## Cada caído muere a su manera.
func _draw_death(style: int, beat: float) -> void:
	match style % 4:
		0:
			_x_eyes()
			_canvas.draw_circle(Vector2(6.0, -9.0), 7.0, COLOR_TONGUE)
		1:
			for side: float in [-11.0, 11.0]:
				_canvas.draw_arc(Vector2(side, -30.0), 9.0, beat, beat + TAU * 1.4, 20, COLOR_INK, 3.0)
			_canvas.draw_polyline(_wavy(-11.0, 11.0, -12.0), COLOR_INK, 3.0)
		2:
			_x_eyes()
			_canvas.draw_circle(Vector2(0.0, -10.0), 9.0, COLOR_INK)
		3:
			_canvas.draw_circle(Vector2(-11.0, -30.0), 10.0, Color.WHITE)
			_canvas.draw_circle(Vector2(-11.0, -30.0), 3.0, COLOR_INK)
			_canvas.draw_line(Vector2(3.0, -30.0), Vector2(19.0, -30.0), COLOR_INK, 4.0)
			_canvas.draw_arc(Vector2(0.0, -2.0), 10.0, PI * 1.2, PI * 1.8, 8, COLOR_INK, 3.0)


func _x_eyes() -> void:
	for side: float in [-11.0, 11.0]:
		var eye: Vector2 = Vector2(side, -30.0)
		_canvas.draw_line(eye + Vector2(-7, -7), eye + Vector2(7, 7), COLOR_INK, 4.0)
		_canvas.draw_line(eye + Vector2(-7, 7), eye + Vector2(7, -7), COLOR_INK, 4.0)


## Un alma diminuta sube del caído y se va quejando.
func _draw_soul(at: Vector2, phase: float) -> void:
	var rise: float = fmod(_time * 26.0 + phase * 40.0, 120.0)
	var soul: Vector2 = at + Vector2(sin(rise * 0.09) * 12.0, -50.0 - rise) * _zoom
	var alpha: float = 0.75 * (1.0 - rise / 120.0)
	_canvas.draw_circle(soul, 11.0 * _zoom, Color(1.0, 1.0, 1.0, alpha))
	_canvas.draw_circle(soul + Vector2(-3.5, -2.0) * _zoom, 1.6 * _zoom, Color(0.1, 0.1, 0.2, alpha))
	_canvas.draw_circle(soul + Vector2(3.5, -2.0) * _zoom, 1.6 * _zoom, Color(0.1, 0.1, 0.2, alpha))
