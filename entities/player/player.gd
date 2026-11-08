class_name Player
extends CharacterBody2D
## Protagonista provisional. El origen del nodo son sus pies.

## Valores provisionales, a ajustar al probar.
const WALK_SPEED: float = 180.0
const RUN_SPEED: float = 320.0
const RADIUS: float = 18.0
const BODY_HEIGHT: float = 60.0
const WAYPOINT_TOLERANCE: float = 6.0

const COLOR_BODY: Color = Color("#e0651f")
const COLOR_EYE: Color = Color("#35e0ff")
const COLOR_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.35)

var facing: Vector2 = Vector2.DOWN

var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _autorun: bool = false
var _run_toggled: bool = false


func _ready() -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = RADIUS
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"autorun"):
		_autorun = not _autorun
	if Input.is_action_just_pressed(&"toggle_run"):
		_run_toggled = not _run_toggled
	var direction: Vector2 = _resolve_direction()
	velocity = direction * current_speed()
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
		queue_redraw()
	move_and_slide()


func _draw() -> void:
	draw_circle(Vector2(0.0, 4.0), RADIUS, COLOR_SHADOW)
	var head: Vector2 = Vector2(0.0, -BODY_HEIGHT * 0.5)
	draw_circle(head, BODY_HEIGHT * 0.42, COLOR_BODY)
	draw_circle(head + facing * 14.0, 6.0, COLOR_EYE)


func set_path(path: PackedVector2Array) -> void:
	_path = path
	_path_index = 0
	_autorun = false


func has_path() -> bool:
	return _path_index < _path.size()


func current_speed() -> float:
	var running: bool = Input.is_action_pressed(&"run") != _run_toggled
	return RUN_SPEED if running else WALK_SPEED


func is_autorunning() -> bool:
	return _autorun


## Una de las 8 direcciones de sprite: 0 es este y aumenta en sentido horario.
static func octant_of(direction: Vector2) -> int:
	return posmod(roundi(direction.angle() / (TAU / 8.0)), 8)


func _resolve_direction() -> Vector2:
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input != Vector2.ZERO:
		_autorun = false
		_path = PackedVector2Array()
		_path_index = 0
		return input
	if _autorun:
		return facing
	return _next_path_direction()


func _next_path_direction() -> Vector2:
	while has_path():
		var target: Vector2 = _path[_path_index]
		if global_position.distance_to(target) > WAYPOINT_TOLERANCE:
			return global_position.direction_to(target)
		_path_index += 1
	return Vector2.ZERO
