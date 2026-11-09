class_name GuardAttack
extends RefCounted
## Ataques anunciados de un guardia: quien se aparta a tiempo los evita.

var windup_left: float = 0.0
var hit_timer: float = 0.0
var aim_point: Vector2 = Vector2.ZERO
var tracer_host: Sandbox

var _guard: Guard
var _ranged: bool = false


func _init(guard: Guard) -> void:
	_guard = guard


func make_ranged(host: Sandbox) -> void:
	_ranged = true
	tracer_host = host


func is_ranged() -> bool:
	return _ranged


func tick(delta: float) -> void:
	hit_timer = maxf(hit_timer - delta, 0.0)


func cancel() -> void:
	windup_left = 0.0


## Devuelve si el turno del guardia acaba aquí.
func handle_windup(delta: float) -> bool:
	if windup_left <= 0.0:
		return false
	windup_left -= delta
	if not _ranged:
		_guard.chase_step()
	if windup_left > 0.0:
		return _ranged
	if _ranged:
		fire()
	else:
		_strike()
	return _ranged


## Si tiene a tiro al objetivo, se planta y apunta. Devuelve si se ha plantado.
func try_aim(sees: bool, distance: float) -> bool:
	if not _ranged or not sees or distance > Guard.SHOOT_RANGE:
		return false
	var target: Player = _guard.target
	_guard.velocity = Vector2.ZERO
	_guard.detector.facing_angle = _guard.global_position.angle_to_point(target.global_position)
	if hit_timer <= 0.0:
		windup_left = Guard.SHOT_WINDUP
		aim_point = target.global_position
	return true


func try_melee(distance: float) -> void:
	if not _ranged and distance <= Guard.HIT_RANGE and hit_timer <= 0.0 and windup_left <= 0.0:
		windup_left = Guard.MELEE_WINDUP


func fire() -> void:
	hit_timer = Guard.SHOT_COOLDOWN
	var target: Player = _guard.target
	var from: Vector2 = _guard.global_position
	var mask: int = PhysicsLayers.WALLS
	if target.is_crouching:
		mask |= PhysicsLayers.LOW_COVER
	var end: Vector2 = Detector.ray_end(from, aim_point, _guard.get_world_2d(), mask)
	if tracer_host != null:
		tracer_host.spawn_tracer(from, end, GuardVisual.COLOR_WINDUP)
	var near_aim: bool = target.global_position.distance_to(aim_point) <= Guard.AIM_TOLERANCE
	if end == aim_point and near_aim:
		target.receive_hit(Guard.SHOT_DAMAGE, _guard.rng, _guard)


func _strike() -> void:
	hit_timer = Guard.HIT_COOLDOWN
	var target: Player = _guard.target
	var reach: float = Guard.HIT_RANGE + Guard.MELEE_GRACE
	if _guard.global_position.distance_to(target.global_position) <= reach:
		target.receive_hit(Guard.HIT_DAMAGE, _guard.rng, _guard)
