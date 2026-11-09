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

const WALK_ANIMATION_SPEED: float = 11.0
const HIT_REFERENCE: float = 34.0
const HIT_SHAKE: float = 14.0
const HIT_STOP: float = 0.07
const HIT_SQUASH: Vector2 = Vector2(1.22, 0.78)

var facing: Vector2 = Vector2.DOWN
var is_crouching: bool = false
var body: ModularBody = ModularBody.new()
var noise_bus: NoiseBus
var in_danger: bool = false
var tail_color: Color = Color("#404050")
var tail_speaking: bool = false

var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _autorun: bool = false
var _run_toggled: bool = false
var _noise_timer: float = 0.0
var _worry_timer: float = 0.0
var _walk_phase: float = 0.0
var _boost_time: float = 0.0
var _bubble_cooldown: float = 0.0
## Deformación del dibujo al recibir un golpe.
var _squash: Vector2 = Vector2.ONE


func _ready() -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = RADIUS
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = PhysicsLayers.PLAYER
	collision_mask = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER
	material = ImpactFx.new_flash_material()


func _physics_process(delta: float) -> void:
	if body.is_dead:
		velocity = Vector2.ZERO
		return
	_tick_body(delta)
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
	ProtagonistArt.draw(self, facing, height_ratio, body, tail_color, tail_speaking, _walk_phase, _squash)


func set_path(path: PackedVector2Array) -> void:
	_path = path
	_path_index = 0
	_autorun = false


func has_path() -> bool:
	return _path_index < _path.size()


func set_crouching(value: bool) -> void:
	is_crouching = value
	queue_redraw()


func current_height() -> float:
	return CROUCH_HEIGHT if is_crouching else BODY_HEIGHT


func is_running() -> bool:
	if is_crouching or body.leg_count() < 2:
		return false
	return Input.is_action_pressed(&"run") != _run_toggled


func current_speed() -> float:
	var speed: float = WALK_SPEED
	if is_crouching:
		speed = CROUCH_SPEED
	elif is_running():
		speed = RUN_SPEED
	speed *= body.speed_factor() * body.multiplier("speed")
	if _boost_time > 0.0:
		speed *= BOOST_FACTOR
	if in_danger and body.has_action("a015"):
		speed *= PANIC_FACTOR
	return speed


## Parte del alcance de visión enemigo que se aplica a este personaje.
func stealth_factor() -> float:
	var factor: float = CROUCH_RANGE_FACTOR if is_crouching else 1.0
	if velocity == Vector2.ZERO and body.has_action("a024"):
		factor *= CAMOUFLAGE_RANGE_FACTOR
	return factor


func jam_radius() -> float:
	return body.total("jam_radius")


func start_boost(duration: float) -> void:
	_boost_time = duration


func receive_hit(amount: float, rng: RandomNumberGenerator, attacker: Guard) -> void:
	if body.has_action("a044") and _bubble_cooldown <= 0.0:
		_bubble_cooldown = BUBBLE_RECHARGE
		return
	if rng.randf() < body.total("dodge"):
		return
	body.damage_random(amount, rng)
	react_to_hit(amount)
	if body.has_action("a046") and attacker != null:
		attacker.stun(SPIKES_STUN_TIME * body.multiplier("stun"))


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
		return
	body.wear_legs(moved)
	_noise_timer -= delta
	var silent: bool = body.has_action("a023")
	if is_running() and not silent and _noise_timer <= 0.0 and noise_bus != null:
		_noise_timer = RUN_NOISE_INTERVAL
		noise_bus.emit_noise(global_position, RUN_NOISE_RADIUS * body.multiplier("run_noise"))
	_worry_timer -= delta
	if body.has_worried_piece() and _worry_timer <= 0.0 and noise_bus != null:
		_worry_timer = WORRY_NOISE_INTERVAL
		noise_bus.emit_noise(global_position, WORRY_NOISE_RADIUS)


## Los repuestos se recogen al pasar por encima, si queda sitio para ellos.
func _collect_pickups() -> void:
	for node: Node in get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		if item.used or not item.is_pickup() or not body.can_stow_in(item.pickup_slots()):
			continue
		if global_position.distance_to(item.global_position) <= PICKUP_RADIUS:
			item.activate()


func _interact_nearest() -> void:
	var best: Interactable = null
	var best_distance: float = Interactable.RANGE
	for node: Node in get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		var distance: float = global_position.distance_to(item.global_position)
		if not item.used and not item.is_pickup() and distance <= best_distance:
			best = item
			best_distance = distance
	if best != null:
		best.activate()


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
