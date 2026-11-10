class_name Player
extends CharacterBody2D
## Protagonista provisional. El origen del nodo son sus pies.

## Valores provisionales, a ajustar al probar.
const WALK_SPEED: float = 180.0
const RUN_SPEED: float = 320.0
const CROUCH_SPEED: float = 110.0
const RUN_NOISE_RADIUS: float = 340.0
const RUN_NOISE_INTERVAL: float = 0.4
const RADIUS: float = 18.0
const PICKUP_RADIUS: float = 40.0
const BODY_HEIGHT: float = 60.0
const CROUCH_HEIGHT: float = 38.0
const CROUCH_RANGE_FACTOR: float = 0.7
const CAMOUFLAGE_RANGE_FACTOR: float = 0.5
const BOOST_FACTOR: float = 1.6
const PANIC_FACTOR: float = 1.25
const BUBBLE_RECHARGE: float = 15.0
const WORRY_NOISE_RADIUS: float = 120.0
const WORRY_NOISE_INTERVAL: float = 3.0
const SPIKES_STUN_TIME: float = 1.5
const WAYPOINT_TOLERANCE: float = 6.0
const HIDE_RANGE_FACTOR: float = 0.15
const DISGUISE_RANGE_FACTOR: float = 0.25
const TICK_NOISE_RADIUS: float = 200.0
const TICK_NOISE_INTERVAL: float = 7.0
const SLOW_FACTOR: float = 0.55
const COLOR_DISGUISE: Color = Color(0.72, 1.0, 0.72)
const COLOR_HIDDEN: Color = Color(1.0, 1.0, 1.0, 0.45)

const WALK_ANIMATION_SPEED: float = 11.0
const HIT_REFERENCE: float = 34.0
const HIT_SHAKE: float = 14.0
const HIT_STOP: float = 0.07
const HIT_SQUASH: Vector2 = Vector2(1.22, 0.78)
## Segundos que se ve una acción antes de volver a idle (P-25, provisional).
const ACTION_SHOW_TIME: float = 0.5

## Lo fija Siestaware cuando está activa.
var still_stealth_factor: float = 1.0
## En la vista de estrategia el personaje se queda quieto.
var controls_locked: bool = false
var facing: Vector2 = Vector2.DOWN
var is_crouching: bool = false
var body: ModularBody = ModularBody.new()
var knockback: Knockback = Knockback.new()
var noise_bus: NoiseBus
var in_danger: bool = false
var tail_color: Color = Color("#404050")
var tail_speaking: bool = false
## Fotograma de la acción actual para el atlas (P-25, provisional).
var action_frames: ActionFrame = ActionFrame.new()
## Bando al que engaña el disfraz puesto; "any" engaña a todos.
var disguise_faction: String = ""
var disguise_time: float = 0.0
var disguise_factor: float = DISGUISE_RANGE_FACTOR
var hide_time: float = 0.0
var silent_time: float = 0.0
var slow_time: float = 0.0

var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _autorun: bool = false
var _run_toggled: bool = false
var _noise_timer: float = 0.0
var _worry_timer: float = 0.0
var _walk_phase: float = 0.0
var _boost_time: float = 0.0
var _bubble_cooldown: float = 0.0
var _excuse_cooldown: float = 0.0
var _tick_timer: float = TICK_NOISE_INTERVAL
## Deformación del dibujo al recibir un golpe.
var _squash: Vector2 = Vector2.ONE
var _footsteps: AudioStreamPlayer2D
var _action_left: float = 0.0


func _ready() -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = RADIUS
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = PhysicsLayers.PLAYER
	collision_mask = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER
	_footsteps = load("res://audio/footstep_audio.gd").new()
	add_child(_footsteps)


func _physics_process(delta: float) -> void:
	tick_action(delta)
	if body.is_dead:
		velocity = Vector2.ZERO
		return
	_tick_body(delta)
	if knockback.is_active():
		velocity = knockback.tick(delta)
		move_and_slide()
		queue_redraw()
		return
	_read_toggles()
	var direction: Vector2 = _resolve_direction()
	velocity = direction * current_speed()
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
	var before: Vector2 = global_position
	move_and_slide()
	if velocity != Vector2.ZERO:
		_walk_phase += delta * WALK_ANIMATION_SPEED
	_after_move(global_position.distance_to(before), delta)
	_collect_pickups()
	queue_redraw()


func _draw() -> void:
	var height_ratio: float = current_height() / BODY_HEIGHT
	ProtagonistArt.draw(
		self, facing, height_ratio, body, tail_color, tail_speaking, _walk_phase,
		_squash, action_frames.current_key()
	)


func set_path(path: PackedVector2Array) -> void:
	_path = path
	_path_index = 0
	_autorun = false


func has_path() -> bool:
	return _path_index < _path.size()


func set_crouching(value: bool) -> void:
	is_crouching = value
	queue_redraw()


## Acción cosmética para los fotogramas del atlas (P-25). Provisional.
func set_action(next: String) -> void:
	action_frames.set_action(next)
	_action_left = ACTION_SHOW_TIME


## Vuelve a idle al acabarse el tiempo de la acción.
func tick_action(delta: float) -> void:
	if _action_left <= 0.0:
		return
	_action_left = maxf(_action_left - delta, 0.0)
	if _action_left <= 0.0:
		action_frames.set_action(ActionFrameCatalog.DEFAULT)


func current_height() -> float:
	return CROUCH_HEIGHT if is_crouching else BODY_HEIGHT


func is_running() -> bool:
	if is_crouching or body.leg_count() < 2:
		return false
	return Input.is_action_pressed(&"run") != _run_toggled


func current_speed() -> float:
	var speed: float = WALK_SPEED
	if is_crouching:
		speed = CROUCH_SPEED * body.multiplier("crouch_speed")
	elif is_running():
		speed = RUN_SPEED
	speed *= body.speed_factor() * body.multiplier("speed")
	if _boost_time > 0.0:
		speed *= BOOST_FACTOR
	if in_danger and body.has_action("a015"):
		speed *= PANIC_FACTOR
	if in_danger:
		speed *= body.multiplier("panic_speed")
	if slow_time > 0.0:
		speed *= SLOW_FACTOR
	return speed


## Parte del alcance de visión enemigo que se aplica a este personaje.
func stealth_factor() -> float:
	var factor: float = CROUCH_RANGE_FACTOR if is_crouching else 1.0
	if velocity == Vector2.ZERO:
		factor *= still_stealth_factor
	if velocity == Vector2.ZERO and body.has_action("a024"):
		factor *= CAMOUFLAGE_RANGE_FACTOR
	factor *= body.multiplier("sight")
	if velocity == Vector2.ZERO:
		factor *= body.multiplier("still_sight")
		if hide_time > 0.0:
			factor *= HIDE_RANGE_FACTOR
	if body.is_night:
		factor *= body.multiplier("dark_sight")
	return factor


## Lo mismo, según quién mire: disfraces y piezas que solo engañan a un bando.
func stealth_factor_for(faction: String) -> float:
	var factor: float = stealth_factor() * body.multiplier("sight_" + faction)
	if disguise_time > 0.0 and (disguise_faction == "any" or disguise_faction == faction):
		factor *= disguise_factor
	return factor


func start_disguise(faction: String, duration: float, factor: float) -> void:
	disguise_faction = faction
	disguise_time = duration
	disguise_factor = factor
	_refresh_tint()


## Pegar a alguien delata cualquier disfraz.
func break_disguise() -> void:
	disguise_time = 0.0
	_refresh_tint()


func start_hide(duration: float) -> void:
	hide_time = duration
	_refresh_tint()


func _refresh_tint() -> void:
	if disguise_time > 0.0:
		modulate = COLOR_DISGUISE
	elif hide_time > 0.0:
		modulate = COLOR_HIDDEN
	else:
		modulate = Color.WHITE


func jam_radius() -> float:
	return body.total("jam_radius")


func start_boost(duration: float) -> void:
	_boost_time = duration


func receive_hit(amount: float, rng: RandomNumberGenerator, attacker: Guard) -> void:
	if body.has_action("a044") and _bubble_cooldown <= 0.0:
		_bubble_cooldown = BUBBLE_RECHARGE
		return
	if body.total("excuse") > 0.0 and _excuse_cooldown <= 0.0:
		_excuse_cooldown = body.total("excuse")
		return
	if rng.randf() < body.total("dodge"):
		return
	body.damage_random(amount, rng)
	react_to_hit(amount)
	if attacker != null:
		knockback.start(global_position - attacker.global_position)
	if body.has_action("a046") and attacker != null:
		attacker.stun(SPIKES_STUN_TIME * body.multiplier("stun"))
	elif body.total("thorns_stun") > 0.0 and attacker != null:
		attacker.stun(body.total("thorns_stun") * body.multiplier("stun"))


## Efectos visuales de un golpe recibido; cuanto más daño, más fuertes.
func react_to_hit(amount: float) -> void:
	if not is_inside_tree():
		return
	var strength: float = clampf(amount / HIT_REFERENCE, 0.6, 1.6)
	ImpactFx.flash(self)
	ImpactFx.squash(self, "_squash", Vector2.ONE.lerp(HIT_SQUASH, strength))
	ImpactFx.shake(get_viewport(), HIT_SHAKE * strength)
	ImpactFx.hit_stop(get_tree(), HIT_STOP)
	queue_redraw()


func is_autorunning() -> bool:
	return _autorun


## Una de las 8 direcciones de sprite: 0 es este y aumenta en sentido horario.
static func octant_of(direction: Vector2) -> int:
	return posmod(roundi(direction.angle() / (TAU / 8.0)), 8)


func _tick_body(delta: float) -> void:
	body.tick(delta)
	_boost_time = maxf(_boost_time - delta, 0.0)
	_bubble_cooldown = maxf(_bubble_cooldown - delta, 0.0)
	_excuse_cooldown = maxf(_excuse_cooldown - delta, 0.0)
	slow_time = maxf(slow_time - delta, 0.0)
	silent_time = maxf(silent_time - delta, 0.0)
	var was_covered: bool = disguise_time > 0.0 or hide_time > 0.0
	disguise_time = maxf(disguise_time - delta, 0.0)
	hide_time = maxf(hide_time - delta, 0.0)
	if was_covered and disguise_time <= 0.0 and hide_time <= 0.0:
		_refresh_tint()
	if body.total("tick_noise") > 0.0 and noise_bus != null:
		_tick_timer -= delta
		if _tick_timer <= 0.0:
			_tick_timer = TICK_NOISE_INTERVAL
			noise_bus.emit_noise(global_position, TICK_NOISE_RADIUS)


func _read_toggles() -> void:
	if Input.is_action_just_pressed(&"autorun"):
		_autorun = not _autorun
	if Input.is_action_just_pressed(&"toggle_run"):
		_run_toggled = not _run_toggled
	if Input.is_action_just_pressed(&"crouch"):
		set_crouching(not is_crouching)
	if Input.is_action_just_pressed(&"interact"):
		_interact_nearest()


func _after_move(moved: float, delta: float) -> void:
	if moved <= 0.0:
		_noise_timer = 0.0
		if _footsteps != null:
			_footsteps.tick(delta, 0.0, false, false)
		return
	body.wear_legs(moved)
	_noise_timer -= delta
	var silent: bool = body.has_action("a023") or silent_time > 0.0
	if is_running() and not silent and _noise_timer <= 0.0 and noise_bus != null:
		_noise_timer = RUN_NOISE_INTERVAL
		noise_bus.emit_noise(global_position, RUN_NOISE_RADIUS * body.multiplier("run_noise"))
	_worry_timer -= delta
	if body.has_worried_piece() and _worry_timer <= 0.0 and noise_bus != null:
		_worry_timer = WORRY_NOISE_INTERVAL
		noise_bus.emit_noise(global_position, WORRY_NOISE_RADIUS)
	if _footsteps != null:
		_footsteps.tick(delta, velocity.length(), is_running(), is_crouching)


## Los repuestos se recogen al pasar por encima, si queda sitio para ellos.
func _collect_pickups() -> void:
	for node: Node in get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		if item.used or not item.is_pickup() or not body.can_stow_in(item.pickup_slots()):
			continue
		if global_position.distance_to(item.global_position) <= PICKUP_RADIUS + body.total("pickup_radius"):
			item.activate()


func _interact_nearest() -> void:
	var best: Interactable = nearest_interactable()
	if best != null:
		best.activate()


func nearest_interactable() -> Interactable:
	var best: Interactable = null
	var best_distance: float = Interactable.RANGE
	for node: Node in get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		var distance: float = global_position.distance_to(item.global_position)
		if not item.used and not item.is_pickup() and distance <= best_distance:
			best = item
			best_distance = distance
	return best


func _resolve_direction() -> Vector2:
	var input: Vector2 = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if controls_locked:
		input = Vector2.ZERO
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
