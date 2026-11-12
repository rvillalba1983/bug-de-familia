class_name Drone
extends Node2D
## Dron de patrulla que vuela sobre las coberturas y da la alarma.

signal alarm_raised(position: Vector2)

## Valores provisionales, a ajustar al probar.
const SPEED: float = 130.0
const VIEW_RANGE: float = 200.0
const VIEW_HALF_ANGLE: float = 40.0
const FLY_HEIGHT: float = 70.0
const ART_SOUTH: Texture2D = preload("res://art/shared/dron_viejo.svg")
const ART_EAST: Texture2D = preload("res://art/shared/dron_viejo_e.svg")
const ART_NORTH: Texture2D = preload("res://art/shared/dron_viejo_n.svg")
const ART_SIZE: float = 64.0

var detector: Detector = Detector.new(VIEW_RANGE, VIEW_HALF_ANGLE, false)
var target: Player

var _patrol: Array[Vector2] = []
var _patrol_index: int = 0
var _view: VisionConeView
var _disabled_time: float = 0.0


func setup(points: Array[Vector2], ground: Node2D) -> void:
	_patrol = points
	position = points[0]
	_view = Sentinel.add_cone(self, ground, detector)
	detector.detected.connect(func(at: Vector2) -> void: alarm_raised.emit(at))


## Inutiliza el aparato durante un rato.
func confuse(duration: float) -> void:
	_disabled_time = duration
	detector.reset()
	_view.visible = false


func _exit_tree() -> void:
	_view.queue_free()


func _physics_process(delta: float) -> void:
	if _disabled_time > 0.0:
		_disabled_time -= delta
		_view.visible = _disabled_time <= 0.0
		return
	var goal: Vector2 = _patrol[_patrol_index]
	if global_position.distance_to(goal) < 4.0:
		_patrol_index = (_patrol_index + 1) % _patrol.size()
	else:
		var direction: Vector2 = global_position.direction_to(goal)
		global_position = global_position.move_toward(goal, SPEED * delta)
		detector.facing_angle = direction.angle()
	detector.update(global_position, get_world_2d(), target, delta)
	_view.refresh(global_position, get_world_2d())


func _draw() -> void:
	var corner: Vector2 = Vector2(-ART_SIZE * 0.5, -FLY_HEIGHT - ART_SIZE * 0.5)
	var direction: Vector2 = Vector2.from_angle(detector.facing_angle)
	var art: Texture2D = ART_EAST
	var size: Vector2 = Vector2(ART_SIZE, ART_SIZE)
	if absf(direction.y) > absf(direction.x):
		art = ART_SOUTH if direction.y > 0.0 else ART_NORTH
	elif direction.x < 0.0:
		corner.x = ART_SIZE * 0.5
		size.x = -ART_SIZE
	draw_texture_rect(art, Rect2(corner, size), false)
	draw_line(Vector2.ZERO, Vector2(0.0, -FLY_HEIGHT), Color(1.0, 1.0, 1.0, 0.2), 1.0)
