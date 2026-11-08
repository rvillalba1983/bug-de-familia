class_name Guard
extends CharacterBody2D
## Guardia con patrulla, investigación de ruidos y persecución.

signal alert_started
signal alert_ended

enum State { PATROL, WAIT, INVESTIGATE, LOOK_AROUND, ALERT, STUNNED }

## Valores provisionales, a ajustar al probar.
const PATROL_SPEED: float = 110.0
const INVESTIGATE_SPEED: float = 150.0
const CHASE_SPEED: float = 240.0
const WAIT_TIME: float = 1.5
const LOOK_TIME: float = 2.0
const LOSE_TIME: float = 4.0
const VIEW_RANGE: float = 320.0
const VIEW_HALF_ANGLE: float = 35.0
const REPATH_TIME: float = 0.4
const HIT_RANGE: float = 46.0
const HIT_COOLDOWN: float = 1.2
const HIT_DAMAGE: float = 34.0
const RADIUS: float = 18.0
const BODY_HEIGHT: float = 60.0
const WAYPOINT_TOLERANCE: float = 6.0
const COLOR_BODY: Color = Color("#3f7fd0")
const COLOR_ALERT: Color = Color("#e04040")

var state: State = State.PATROL
var detector: Detector = Detector.new(VIEW_RANGE, VIEW_HALF_ANGLE, true)
var target: Player
var nav: NavGrid
var rng: RandomNumberGenerator

var _patrol: Array[Vector2] = []
var _patrol_index: int = 0
var _timer: float = 0.0
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _last_known: Vector2 = Vector2.ZERO
var _lost_time: float = 0.0
var _repath: float = 0.0
var _hit_timer: float = 0.0
var _view: VisionConeView


func setup(points: Array[Vector2], ground: Node2D) -> void:
	_patrol = points
	position = points[0]
	collision_layer = PhysicsLayers.ENEMIES
	collision_mask = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = RADIUS
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)
	_view = Sentinel.add_cone(self, ground, detector)
	detector.detected.connect(_on_detected)


func _physics_process(delta: float) -> void:
	_hit_timer = maxf(_hit_timer - delta, 0.0)
	if state == State.STUNNED:
		_tick_stun(delta)
		return
	detector.update(global_position, get_world_2d(), target, delta)
	match state:
		State.PATROL:
			_move_toward_point(_patrol[_patrol_index], PATROL_SPEED, _on_patrol_point)
		State.WAIT:
			_tick_wait(delta)
		State.INVESTIGATE:
			_follow_path(INVESTIGATE_SPEED, _on_investigate_done)
		State.LOOK_AROUND:
			_tick_look(delta)
		State.ALERT:
			_tick_alert(delta)
	_view.refresh(global_position, get_world_2d())
	queue_redraw()


func _draw() -> void:
	var color: Color = COLOR_ALERT if state == State.ALERT else COLOR_BODY
	draw_circle(Vector2(0.0, -BODY_HEIGHT * 0.5), BODY_HEIGHT * 0.42, color)


## Reacciona a un ruido si llega hasta aquí. Las paredes lo atenúan a la mitad.
func hear(origin: Vector2, radius: float) -> void:
	if state == State.ALERT or state == State.STUNNED:
		return
	var heard: float = radius
	var world: World2D = get_world_2d()
	if Detector.ray_end(global_position, origin, world, PhysicsLayers.WALLS) != origin:
		heard *= 0.5
	if global_position.distance_to(origin) <= heard:
		investigate(origin)


## Va a comprobar un punto, sin que empiece una pelea.
func investigate(point: Vector2) -> void:
	if state == State.ALERT or state == State.STUNNED:
		return
	_set_path_to(point)
	state = State.INVESTIGATE


## Deja al guardia fuera de combate un rato, sin matarlo.
func stun(duration: float) -> void:
	var was_alert: bool = state == State.ALERT
	state = State.STUNNED
	_timer = duration
	detector.reset()
	_view.visible = false
	velocity = Vector2.ZERO
	if was_alert:
		alert_ended.emit()


func _exit_tree() -> void:
	_view.queue_free()


func is_alert() -> bool:
	return state == State.ALERT


func _on_detected(at: Vector2) -> void:
	_last_known = at
	_lost_time = 0.0
	_repath = 0.0
	state = State.ALERT
	alert_started.emit()


func _tick_stun(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_view.visible = true
		state = State.PATROL


func _tick_wait(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	if _timer <= 0.0:
		_patrol_index = (_patrol_index + 1) % _patrol.size()
		state = State.PATROL


func _tick_look(delta: float) -> void:
	velocity = Vector2.ZERO
	_timer -= delta
	detector.facing_angle += delta * 1.6
	if _timer <= 0.0:
		state = State.PATROL


func _tick_alert(delta: float) -> void:
	var sees: bool = detector.can_see(global_position, get_world_2d(), target)
	if sees:
		_last_known = target.global_position
		_lost_time = 0.0
	else:
		_lost_time += delta
	if _lost_time >= LOSE_TIME:
		state = State.PATROL
		detector.reset()
		var point: Vector2 = _last_known
		alert_ended.emit()
		investigate(point)
		return
	_repath -= delta
	if _repath <= 0.0:
		_repath = REPATH_TIME
		_set_path_to(_last_known)
	_follow_path(CHASE_SPEED, Callable())
	if global_position.distance_to(target.global_position) <= HIT_RANGE and _hit_timer <= 0.0:
		_hit_timer = HIT_COOLDOWN
		target.receive_hit(HIT_DAMAGE, rng, self)


func _on_patrol_point() -> void:
	_timer = WAIT_TIME
	state = State.WAIT


func _on_investigate_done() -> void:
	_timer = LOOK_TIME
	state = State.LOOK_AROUND


func _set_path_to(point: Vector2) -> void:
	_path = nav.find_path(global_position, point)
	_path_index = 0


func _follow_path(speed: float, on_done: Callable) -> void:
	while _path_index < _path.size():
		var point: Vector2 = _path[_path_index]
		if global_position.distance_to(point) > WAYPOINT_TOLERANCE:
			_steer(global_position.direction_to(point), speed)
			return
		_path_index += 1
	velocity = Vector2.ZERO
	if on_done.is_valid():
		on_done.call()


func _move_toward_point(point: Vector2, speed: float, on_arrive: Callable) -> void:
	if global_position.distance_to(point) <= WAYPOINT_TOLERANCE:
		velocity = Vector2.ZERO
		on_arrive.call()
		return
	_steer(global_position.direction_to(point), speed)


func _steer(direction: Vector2, speed: float) -> void:
	velocity = direction * speed
	detector.facing_angle = direction.angle()
	move_and_slide()
