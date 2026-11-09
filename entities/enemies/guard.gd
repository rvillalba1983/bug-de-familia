class_name Guard
extends CharacterBody2D
## Guardia con patrulla, investigación de ruidos y persecución.

signal attacked
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
const SCREEN_MARGIN: float = 120.0
## Provisionales. Quedan dentro de HIT_RANGE, y el ángulo reparte bien a cualquier número.
const FIGHT_SPREAD: float = 34.0
const FIGHT_ANGLE_STEP: float = 2.4
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
## Hueco alrededor del jugador en una pelea, para que un grupo no se apile en un punto.
var _fight_spot: Vector2 = Vector2.ZERO
static var _next_fight_angle: float = 0.0
var _view: VisionConeView
var health: float = MAX_HEALTH
## Un guardia pasivo no vigila ni acude a ruidos; solo responde si le atacan.
var passive: bool = false
var visual: GuardVisual
var attack: GuardAttack
var impacts: GuardImpacts
var _corpse_time: float = 0.0


func _init() -> void:
	visual = GuardVisual.new(self)
	attack = GuardAttack.new(self)
	impacts = GuardImpacts.new(self)


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
	attack.tick(delta)
	var seen: bool = _near_screen()
	if visual.rig != null:
		visual.rig.player.active = seen
	if seen or visual.rig == null:
		visual.update_rig()
	if state == State.DOWN:
		_corpse_time -= delta
		if _corpse_time <= 0.0:
			corpse_expired.emit(self)
		return
	if state == State.STUNNED:
		_tick_stun(delta)
		return
	if not passive:
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
	if seen:
		if _view.visible:
			_view.refresh(global_position, get_world_2d())
		queue_redraw()


## Fuera de pantalla no se anima ni se calcula el dibujo del cono. Las reglas siguen igual.
func _near_screen() -> bool:
	var view: Rect2 = get_canvas_transform().affine_inverse() * get_viewport_rect()
	return view.grow(detector.view_range + SCREEN_MARGIN).has_point(global_position)


func _draw() -> void:
	visual.draw()


## Convierte a este guardia en tirador. Llamar antes de setup.
func make_ranged(host: Sandbox) -> void:
	attack.make_ranged(host)
	detector = Detector.new(SHOOTER_VIEW_RANGE, SHOOTER_HALF_ANGLE, true)


func take_damage(amount: float) -> void:
	if state == State.DOWN:
		return
	health = maxf(health - amount, 0.0)
	attacked.emit()
	impacts.on_hit()
	if health <= 0.0:
		_fall()
	elif state != State.ALERT and state != State.STUNNED:
		_on_detected(target.global_position)


## Se une a una pelea que ya ha empezado cerca.
func join_fight() -> void:
	if state != State.ALERT and state != State.STUNNED and state != State.DOWN:
		_on_detected(target.global_position)


## Golpe de otro combatiente en una batalla: no alerta contra el jugador ni agita la pantalla.
func take_battle_hit(amount: float) -> void:
	if state == State.DOWN:
		return
	health = maxf(health - amount, 0.0)
	if health <= 0.0:
		impacts.quiet = true
		_fall()


## Muere por un suceso del mundo, sin efectos de pantalla.
func die_quietly() -> void:
	if state == State.DOWN:
		return
	impacts.quiet = true
	health = 0.0
	_fall()


## Sustituye la ronda, por ejemplo cuando un conflicto mueve a los bandos.
func set_patrol(points: Array[Vector2]) -> void:
	_patrol = points
	_patrol_index = 0
	if nav != null:
		investigate(points[0])


func set_passive(value: bool) -> void:
	passive = value
	if _view != null:
		_view.visible = not value and state != State.STUNNED


func is_down() -> bool:
	return state == State.DOWN


## Reacciona a un ruido si llega hasta aquí. Las paredes lo atenúan a la mitad.
func hear(origin: Vector2, radius: float) -> void:
	if passive or state == State.ALERT or state == State.STUNNED or state == State.DOWN:
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
	attack.cancel()
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
	_fight_spot = Vector2.from_angle(_next_fight_angle) * FIGHT_SPREAD
	_next_fight_angle += FIGHT_ANGLE_STEP
	alert_started.emit()


func _tick_stun(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_view.visible = not passive
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
	if attack.handle_windup(delta):
		return
	var distance: float = global_position.distance_to(target.global_position)
	if attack.try_aim(sees, distance):
		return
	_repath -= delta
	if _repath <= 0.0:
		_repath = REPATH_TIME
		_set_path_to(_last_known + (Vector2.ZERO if attack.is_ranged() else _fight_spot))
	chase_step()
	attack.try_melee(distance)


## Un paso más de la persecución en curso.
func chase_step() -> void:
	_follow_path(CHASE_SPEED, Callable())


func _fall() -> void:
	impacts.on_fall()
	var was_alert: bool = state == State.ALERT
	state = State.DOWN
	attack.cancel()
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
