class_name StrategyView
extends CanvasLayer
## Mapa de la batalla con los ejércitos moviéndose. M abre y cierra; 1, 2 y 3 dan x1, x2 y x4.

const MAP_SCALE: float = 0.4
const MAP_OFFSET: Vector2 = Vector2(200.0, 30.0)
const SPEEDS: Array[float] = [1.0, 2.0, 4.0]
const COLOR_BACK: Color = Color("#10121a")
const COLOR_FLOOR: Color = Color("#2f4a3a")
const COLOR_CITY: Color = Color("#4a4256")
const COLOR_STRIP: Color = Color("#6b4a32")
const COLOR_WALL: Color = Color("#0a0a12")
const COLOR_PLAYER: Color = Color("#ff9a3c")
const COLORS: Dictionary = {"jubilado": Color("#a0c8ff"), "mohocrata": Color("#a0f060")}

var director: BattleDirector
var is_open: bool = false

var _canvas: Control


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
	director.level.player.controls_locked = true


func close() -> void:
	if not is_open:
		return
	is_open = false
	visible = false
	director.level.player.controls_locked = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"map") and not event.is_echo():
		if is_open:
			director.close_view()
		elif director.phase == BattleDirector.Phase.RUNNING:
			open()
		get_viewport().set_input_as_handled()
		return
	if not is_open:
		return
	for index: int in range(SPEEDS.size()):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			director.set_speed(SPEEDS[index])
			get_viewport().set_input_as_handled()
			return


func _process(_delta: float) -> void:
	if not is_open:
		return
	if director.level.fight.phase != FightDirector.Phase.CALM:
		director.close_view()
		return
	_canvas.queue_redraw()


func _to_map(point: Vector2) -> Vector2:
	return MAP_OFFSET + point * MAP_SCALE


func _rect(area: Rect2, color: Color) -> void:
	_canvas.draw_rect(Rect2(_to_map(area.position), area.size * MAP_SCALE), color)


func _draw_map() -> void:
	_canvas.draw_rect(Rect2(Vector2.ZERO, Vector2(1920.0, 1080.0)), COLOR_BACK)
	_rect(BetaLayout.FLOOR_RECT, COLOR_FLOOR)
	_rect(BetaLayout.CITY, COLOR_CITY)
	_rect(BetaLayout.NO_MANS_LAND, COLOR_STRIP)
	for wall: Rect2 in BetaLayout.WALLS:
		_rect(wall, COLOR_WALL)
	var font: Font = ThemeDB.fallback_font
	var line: float = 60.0
	for species: String in BattleDirector.SPECIES:
		_draw_army(species)
		var count: int = director.alive_in(species).size()
		_canvas.draw_string(font, Vector2(1690.0, line), "%s: %d" % [director.data["names"][species], count],
			HORIZONTAL_ALIGNMENT_LEFT, -1, 17, COLORS[species])
		line += 56.0
	_canvas.draw_circle(_to_map(director.level.player.global_position), 9.0, COLOR_PLAYER)
	_canvas.draw_string(font, Vector2(20.0, 60.0), "x%d" % roundi(director.speed), HORIZONTAL_ALIGNMENT_LEFT, -1, 54, Color.WHITE)
	_canvas.draw_string(font, Vector2(20.0, 110.0), "1: x1", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	_canvas.draw_string(font, Vector2(20.0, 134.0), "2: x2", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	_canvas.draw_string(font, Vector2(20.0, 158.0), "3: x4", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
	_canvas.draw_string(font, Vector2(20.0, 182.0), "M: salir", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)


func _enemy_center(species: String, fallback: Vector2) -> Vector2:
	var rival: String = "mohocrata" if species == "jubilado" else "jubilado"
	var foes: Array[Guard] = director.alive_in(rival)
	if foes.is_empty():
		return fallback
	var sum: Vector2 = Vector2.ZERO
	for foe: Guard in foes:
		sum += _to_map(foe.global_position)
	return sum / float(foes.size())


func _draw_army(species: String) -> void:
	var color: Color = COLORS[species]
	var alive: Array[Guard] = director.alive_in(species)
	var sum: Vector2 = Vector2.ZERO
	for guard: Guard in alive:
		var at: Vector2 = _to_map(guard.global_position)
		sum += at
		_canvas.draw_circle(at, 8.0, color)
		_canvas.draw_arc(at, 8.0, 0.0, TAU, 16, Color.BLACK, 2.0)
	if alive.is_empty():
		return
	var center: Vector2 = sum / float(alive.size())
	var tip: Vector2 = center.lerp(_enemy_center(species, center), 0.55)
	_canvas.draw_line(center, tip, color, 5.0)
	if center.distance_to(tip) < 22.0:
		return
	var side: Vector2 = center.direction_to(tip).orthogonal() * 12.0
	var back: Vector2 = tip - center.direction_to(tip) * 18.0
	_canvas.draw_colored_polygon(PackedVector2Array([tip, back + side, back - side]), color)
