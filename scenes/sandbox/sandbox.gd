class_name Sandbox
extends Node2D
## Escena de prueba con gráficos sencillos, en vista alta inclinada.
##
## Sirve para probar movimiento y sigilo antes de que exista arte definitivo.

const FLOOR_RECT: Rect2 = Rect2(160.0, 90.0, 1600.0, 900.0)
## Altura visible del frente de las paredes, que da la inclinación.
const WALL_FRONT_HEIGHT: float = 48.0
## Huellas de las paredes sobre el suelo.
const WALL_FOOTPRINTS: Array[Rect2] = [
	Rect2(400.0, 288.0, 420.0, 40.0),
	Rect2(1040.0, 288.0, 40.0, 320.0),
	Rect2(520.0, 668.0, 300.0, 40.0),
	Rect2(1240.0, 748.0, 280.0, 40.0),
]
const DUMMY_POSITIONS: Array[Vector2] = [
	Vector2(700.0, 500.0),
	Vector2(1300.0, 400.0),
	Vector2(1500.0, 900.0),
]
const PLAYER_START: Vector2 = Vector2(320.0, 840.0)
const BOUNDARY_THICKNESS: float = 64.0

const COLOR_BACKGROUND: Color = Color("#1d1b26")
const COLOR_FLOOR: Color = Color("#3b4a3a")

var player: Player
var nav: NavGrid
var pause: TacticalPause
var selection: SelectionSystem
var actors: Node2D
var walls: Array[Wall] = []

var _pause_label: Label


func _ready() -> void:
	InputBindings.install()
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	_build_walls()
	_build_boundaries()
	_build_dummies()
	_build_player()
	nav = NavGrid.new(FLOOR_RECT, WALL_FOOTPRINTS, Player.RADIUS)
	_build_systems()
	_build_interface()


func _physics_process(_delta: float) -> void:
	for wall: Wall in walls:
		wall.update_occlusion(player.global_position, Player.BODY_HEIGHT)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_to"):
		player.set_path(nav.find_path(player.global_position, get_global_mouse_position()))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1920.0, 1080.0)), COLOR_BACKGROUND)
	draw_rect(FLOOR_RECT, COLOR_FLOOR)


func _build_walls() -> void:
	for footprint: Rect2 in WALL_FOOTPRINTS:
		var wall: Wall = Wall.new()
		wall.setup(footprint, WALL_FRONT_HEIGHT)
		actors.add_child(wall)
		walls.append(wall)


func _build_boundaries() -> void:
	var area: Rect2 = FLOOR_RECT
	var t: float = BOUNDARY_THICKNESS
	var sides: Array[Rect2] = [
		Rect2(area.position.x - t, area.position.y - t, area.size.x + t * 2.0, t),
		Rect2(area.position.x - t, area.end.y, area.size.x + t * 2.0, t),
		Rect2(area.position.x - t, area.position.y, t, area.size.y),
		Rect2(area.end.x, area.position.y, t, area.size.y),
	]
	for side: Rect2 in sides:
		var body: StaticBody2D = StaticBody2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = side.size
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = shape
		collider.position = side.get_center()
		body.add_child(collider)
		add_child(body)


func _build_dummies() -> void:
	for point: Vector2 in DUMMY_POSITIONS:
		var dummy: SelectableDummy = SelectableDummy.new()
		dummy.position = point
		actors.add_child(dummy)


func _build_player() -> void:
	player = Player.new()
	player.position = PLAYER_START
	actors.add_child(player)
	var camera: CameraZoom = CameraZoom.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1920
	camera.limit_bottom = 1080
	player.add_child(camera)


func _build_systems() -> void:
	pause = TacticalPause.new()
	add_child(pause)
	selection = SelectionSystem.new()
	add_child(selection)


func _build_interface() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	_pause_label = _add_label(layer, "UI_PAUSE", Vector2(860.0, 24.0), 32)
	_pause_label.visible = false
	_add_label(layer, "UI_SANDBOX_HELP", Vector2(24.0, 1040.0), 20)
	pause.paused_changed.connect(_on_paused_changed)


func _add_label(layer: CanvasLayer, key: String, at: Vector2, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = tr(key)
	label.position = at
	label.add_theme_font_size_override(&"font_size", font_size)
	layer.add_child(label)
	return label


func _on_paused_changed(is_paused: bool) -> void:
	_pause_label.visible = is_paused
