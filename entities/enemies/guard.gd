class_name Guard
extends CharacterBody2D
## Guardia con patrulla, investigación de ruidos y persecución.

signal alert_started
signal alert_ended
signal fell(guard: Guard)
signal corpse_expired(guard: Guard)

enum State { PATROL, WAIT, INVESTIGATE, LOOK_AROUND, ALERT, STUNNED, DOWN }

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
const MELEE_WINDUP: float = 0.4
const MELEE_GRACE: float = 14.0
const MAX_HEALTH: float = 100.0
const CORPSE_TIME: float = 25.0
const SHOOTER_VIEW_RANGE: float = 220.0
const SHOOTER_HALF_ANGLE: float = 30.0
const SHOOT_RANGE: float = 340.0
const SHOT_WINDUP: float = 0.7
const SHOT_COOLDOWN: float = 1.8
const SHOT_DAMAGE: float = 20.0
const AIM_TOLERANCE: float = 44.0
const COLOR_BODY: Color = Color("#3f7fd0")
const COLOR_SHOOTER: Color = Color("#3fb0a0")
const COLOR_DOWN: Color = Color("#505868")
const COLOR_WINDUP: Color = Color(1.0, 0.2, 0.15, 0.85)
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
var health: float = MAX_HEALTH
var ranged: bool = false
var tracer_host: Sandbox
var _windup_left: float = 0.0
var _aim_point: Vector2 = Vector2.ZERO
var _corpse_time: float = 0.0


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
	if state == State.DOWN:
		_corpse_time -= delta
		if _corpse_time <= 0.0:
			corpse_expired.emit(self)
		return
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
	if state == State.DOWN:
		draw_circle(Vector2.ZERO, BODY_HEIGHT * 0.42, COLOR_DOWN)
		return
	var color: Color = COLOR_SHOOTER if ranged else COLOR_BODY
	if state == State.ALERT:
		color = COLOR_ALERT
	draw_circle(Vector2(0.0, -BODY_HEIGHT * 0.5), BODY_HEIGHT * 0.42, color)
	if _windup_left > 0.0:
		if ranged:
			draw_line(Vector2(0.0, -30.0), _aim_point - global_position, COLOR_WINDUP, 2.0)
		else:
			draw_arc(Vector2(0.0, -30.0), HIT_RANGE, 0.0, TAU, 32, COLOR_WINDUP, 3.0)
	if health < MAX_HEALTH:
		var bar: Rect2 = Rect2(-24.0, -BODY_HEIGHT - 16.0, 48.0, 6.0)
		draw_rect(bar, Color(0.0, 0.0, 0.0, 0.6))
		bar.size.x *= health / MAX_HEALTH
		draw_rect(bar, COLOR_ALERT)


## Convierte a este guardia en tirador. Llamar antes de setup.
func make_ranged(host: Sandbox) -> void:
	ranged = true
	tracer_host = host
	detector = Detector.new(SHOOTER_VIEW_RANGE, SHOOTER_HALF_ANGLE, true)


func take_damage(amount: float) -> void:
	if state == State.DOWN:
		return
	health = maxf(health - amount, 0.0)
	if health <= 0.0:
		_fall()
	elif state != State.ALERT and state != State.STUNNED:
		_on_detected(target.global_position)


func is_down() -> bool:
	return state == State.DOWN


## Reacciona a un ruido si llega hasta aquí. Las paredes lo atenúan a la mitad.
func hear(origin: Vector2, radius: float) -> void:
	if state == State.ALERT or state == State.STUNNED or state == State.DOWN:
		return
	var heard: float = radius
	var world: World2D = get_world_2d()
	if Detector.ray_end(global_position, origin, world, PhysicsLayers.WALLS) != origin:
		heard *= 0.5
	if global_position.distance_to(origin) <= heard:
		investigate(origin)


## Va a comprobar un punto, sin que empiece una pelea.
func investigate(point: Vector2) -> void:
	if state == State.ALERT or state == State.STUNNED or state == State.DOWN:
		return
	_set_path_to(point)
	state = State.INVESTIGATE


## Deja al guardia fuera de combate un rato, sin matarlo.
func stun(duration: float) -> void:
	if state == State.DOWN:
		return
	_windup_left = 0.0
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
	if _handle_windup(delta):
		return
	var distance: float = global_position.distance_to(target.global_position)
	if ranged and sees and distance <= SHOOT_RANGE:
		velocity = Vector2.ZERO
		detector.facing_angle = global_position.angle_to_point(target.global_position)
		if _hit_timer <= 0.0:
			_windup_left = SHOT_WINDUP
			_aim_point = target.global_position
		return
	_repath -= delta
	if _repath <= 0.0:
		_repath = REPATH_TIME
		_set_path_to(_last_known)
	_follow_path(CHASE_SPEED, Callable())
	if not ranged and distance <= HIT_RANGE and _hit_timer <= 0.0 and _windup_left <= 0.0:
		_windup_left = MELEE_WINDUP


## Golpe o disparo anunciados: quien se aparta a tiempo los evita.
func _handle_windup(delta: float) -> bool:
	if _windup_left <= 0.0:
		return false
	_windup_left -= delta
	if not ranged:
		_follow_path(CHASE_SPEED, Callable())
	if _windup_left > 0.0:
		return ranged
	if ranged:
		_fire()
	else:
		_hit_timer = HIT_COOLDOWN
		if global_position.distance_to(target.global_position) <= HIT_RANGE + MELEE_GRACE:
			target.receive_hit(HIT_DAMAGE, rng, self)
	return ranged


func _fire() -> void:
	_hit_timer = SHOT_COOLDOWN
	var mask: int = PhysicsLayers.WALLS
	if target.is_crouching:
		mask |= PhysicsLayers.LOW_COVER
	var end: Vector2 = Detector.ray_end(global_position, _aim_point, get_world_2d(), mask)
	if tracer_host != null:
		tracer_host.spawn_tracer(global_position, end, COLOR_WINDUP)
	var near_aim: bool = target.global_position.distance_to(_aim_point) <= AIM_TOLERANCE
	if end == _aim_point and near_aim:
		target.receive_hit(SHOT_DAMAGE, rng, self)


func _fall() -> void:
	var was_alert: bool = state == State.ALERT
	state = State.DOWN
	_windup_left = 0.0
	_corpse_time = CORPSE_TIME
	velocity = Vector2.ZERO
	_view.visible = false
	collision_layer = 0
	collision_mask = 0
	queue_redraw()
	if was_alert:
		alert_ended.emit()
	fell.emit(self)


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
