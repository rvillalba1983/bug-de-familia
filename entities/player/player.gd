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
## P-51: al correr la animación de piernas va un 40 % más rápida.
const RUN_ANIMATION_FACTOR: float = 1.4
const HIT_REFERENCE: float = 34.0
const HIT_SHAKE: float = 14.0
const HIT_STOP: float = 0.07
const HIT_SQUASH: Vector2 = Vector2(1.22, 0.78)
## Segundos que se ve una acción sin duración propia en el catálogo (P-25, provisional).
const ACTION_SHOW_TIME: float = 0.5
## P-51. Valores provisionales: gestos de personalidad y máquina de estados.
const QUEUE_MAX: int = 2
const SIT_IDLE_TIME: float = 30.0
const SCRATCH_MIN_TIME: float = 15.0
const SCRATCH_MAX_TIME: float = 25.0
## RNG local y fijo: los gestos de idle no consumen la semilla de la partida.
const IDLE_SEED: int = 51751
const SPARK_TIME: float = 0.35
const SPARK_COLOR: Color = Color("#ffd400")
const DEATH_TIME: float = 1.5
const DEATH_COLOR: Color = Color("#8894b5")

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
## P-51: sentado tras SIT_IDLE_TIME sin moverse ni tocar nada.
var sitting: bool = false
## RNG propio de los gestos de idle; nunca el RNG global (P-51).
var idle_rng: RandomNumberGenerator = RandomNumberGenerator.new()
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
var _action_priority: int = 0
var _action_queue: Array[String] = []
var _idle_time: float = 0.0
var _scratch_timer: float = SCRATCH_MIN_TIME
var _bound_body: ModularBody
## Interlocutores ya saludados, para saludar solo la primera vez (P-51).
var _greeted: Dictionary = {}


func _init() -> void:
	## RNG propio y fijo: los gestos de idle no consumen la semilla de la partida.
	idle_rng.seed = IDLE_SEED
	_scratch_timer = idle_rng.randf_range(SCRATCH_MIN_TIME, SCRATCH_MAX_TIME)


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
	bind_body()


func _physics_process(delta: float) -> void:
	bind_body()
	tick_action(delta)
	if body.is_dead:
		velocity = Vector2.ZERO
		if _action_left > 0.0:
			queue_redraw()
		return
	_tick_body(delta)
	tick_idle(delta)
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
		var factor: float = RUN_ANIMATION_FACTOR if is_running() else 1.0
		_walk_phase += delta * WALK_ANIMATION_SPEED * factor
	_after_move(global_position.distance_to(before), delta)
	_collect_pickups()
	queue_redraw()


func _draw() -> void:
	var pose: Dictionary = ProtagonistArt.pose_for(pose_state())
	ProtagonistArt.draw(
		self, facing, current_height() / BODY_HEIGHT, body, tail_color, tail_speaking,
		_walk_phase, _squash, action_frames.current_key(), pose
	)


## Estado que decide la pose del rig (P-51). Solo lectura.
func pose_state() -> Dictionary:
	return {
		"action": action_frames.action,
		"elapsed": action_frames.elapsed(),
		"crouching": is_crouching,
		"running": is_running() and velocity != Vector2.ZERO,
		"sitting": sitting,
		"dead": body.is_dead,
	}


func set_path(path: PackedVector2Array) -> void:
	_path = path
	_path_index = 0
	_autorun = false


func has_path() -> bool:
	return _path_index < _path.size()


func set_crouching(value: bool) -> void:
	is_crouching = value
	queue_redraw()


## Pide un gesto. Devuelve si se ha aplicado (o encolado).
## Prioridad mayor interrumpe; misma prioridad se encola; menor se descarta.
func set_action(next: String) -> bool:
	if not ActionFrameCatalog.has_action(next):
		return false
	if ActionFrameCatalog.is_terminal(action_frames.action):
		return false
	var priority: int = ActionFrameCatalog.priority(next)
	if _action_left > 0.0:
		if priority < _action_priority:
			return false
		if priority == _action_priority and action_frames.action != next:
			if _action_queue.size() < QUEUE_MAX and not _action_queue.has(next):
				_action_queue.append(next)
			return false
	_start_action(next)
	return true


## Vuelve a idle al acabarse el tiempo del clip, o pasa el siguiente de la cola.
func tick_action(delta: float) -> void:
	if _action_left <= 0.0:
		return
	_action_left = maxf(_action_left - delta, 0.0)
	if _action_left > 0.0 or ActionFrameCatalog.is_terminal(action_frames.action):
		return
	if not _action_queue.is_empty():
		_start_action(_action_queue.pop_front())
		return
	_action_priority = 0
	action_frames.set_action(ActionFrameCatalog.DEFAULT)
	queue_redraw()


## El clip en curso frena al jugador (P-51: lanzar chatarra).
func movement_held() -> bool:
	return _action_left > 0.0 and ActionFrameCatalog.holds_movement(action_frames.action)


## Tiempo de inactividad con el que se sienta y se rasca. La pausa táctica no
## cuenta: el árbol se para y este método no se ejecuta.
func tick_idle(delta: float) -> void:
	var moving: bool = velocity != Vector2.ZERO or Input.is_anything_pressed()
	if moving:
		_idle_time = 0.0
		_scratch_timer = _next_scratch_time()
		_stop_sitting()
		return
	_idle_time += delta
	if _idle_time >= SIT_IDLE_TIME and not sitting and not body.is_dead:
		sitting = true
		queue_redraw()
	_scratch_timer -= delta
	if _scratch_timer <= 0.0:
		_scratch_timer = _next_scratch_time()
		if not sitting and _action_left <= 0.0 and not body.is_dead:
			set_action("rascar")


## Conecta las señales del cuerpo la primera vez y cada vez que se cambia de cuerpo.
func bind_body() -> void:
	if body == _bound_body:
		return
	if _bound_body != null and _bound_body.piece_destroyed.is_connected(_on_piece_destroyed):
		_bound_body.piece_destroyed.disconnect(_on_piece_destroyed)
		_bound_body.died.disconnect(_on_died)
	_bound_body = body
	if body != null:
		body.piece_destroyed.connect(_on_piece_destroyed)
		body.died.connect(_on_died)


func _start_action(next: String) -> void:
	_action_priority = ActionFrameCatalog.priority(next)
	_action_left = maxf(ActionFrameCatalog.duration(next), 0.0)
	_action_queue.clear()
	if action_frames.action == next:
		action_frames.reset()
	else:
		action_frames.set_action(next)
	queue_redraw()


func _next_scratch_time() -> float:
	return idle_rng.randf_range(SCRATCH_MIN_TIME, SCRATCH_MAX_TIME)


func _stop_sitting() -> void:
	if not sitting:
		return
	sitting = false
	queue_redraw()


## Perder una extremidad: tambaleo corto y chispas en el pivote (P-51 R2).
func _on_piece_destroyed(slot: ModularBody.Slot) -> void:
	_spawn_effect("chispas_miembro", SPARK_COLOR, SPARK_TIME, _piece_offset(slot))
	set_action("perdida")


## Muerte del protagonista (P-51 R3): propia, fuera del DeathCatalog.
func _on_died() -> void:
	## Sigue animándose aunque la partida se pause para el game over.
	process_mode = Node.PROCESS_MODE_ALWAYS
	controls_locked = true
	_action_queue.clear()
	set_action("morir")
	_spawn_effect("muerte_protagonista", DEATH_COLOR, DEATH_TIME)


func _spawn_effect(
	effect: String, color: Color, duration: float, at: Vector2 = Vector2.ZERO
) -> void:
	if not is_inside_tree():
		return
	var fx: DeathEffect = DeathEffect.new()
	fx.position = at
	add_child(fx)
	fx.play({
		"effect": effect,
		"effect_color": color.to_html(false),
		"effect_duration": duration,
	})
	var tree: SceneTree = get_tree()
	tree.create_timer(duration + 0.2).timeout.connect(func() -> void:
		if is_instance_valid(fx):
			fx.queue_free()
	)


## Altura aproximada de cada ranura en el dibujo, para soltar las chispas ahí.
func _piece_offset(slot: ModularBody.Slot) -> Vector2:
	match slot:
		ModularBody.Slot.HEAD:
			return Vector2(0.0, -46.0)
		ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_EXTRA_LEFT:
			return Vector2(-10.0, -32.0)
		ModularBody.Slot.ARM_MAIN_RIGHT, ModularBody.Slot.ARM_EXTRA_RIGHT:
			return Vector2(10.0, -32.0)
		ModularBody.Slot.LEG_LEFT:
			return Vector2(-6.0, -12.0)
		ModularBody.Slot.LEG_RIGHT:
			return Vector2(6.0, -12.0)
	return Vector2(0.0, -30.0)


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
	set_action("daño")
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
			set_action("recoger")
			item.activate()


func _interact_nearest() -> void:
	var best: Interactable = nearest_interactable()
	if best != null:
		best.activate()


## Gesto social automático al usar algo con E o con clic derecho (P-51). Solo visual:
## saluda la primera vez que hablas con alguien y señala lo que se puede examinar.
func gesture_for(kind: Interactable.Kind, item_id: String) -> void:
	match kind:
		Interactable.Kind.EVIDENCE:
			set_action("señalar")
		Interactable.Kind.NPC:
			if _greeted.has(item_id):
				return
			_greeted[item_id] = true
			set_action("saludar")


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
	if movement_held():
		## P-51: lanzar chatarra frena al jugador durante el clip.
		return Vector2.ZERO
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
