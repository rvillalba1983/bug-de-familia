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
const BODY_HEIGHT: float = 60.0
const CROUCH_HEIGHT: float = 38.0
const WAYPOINT_TOLERANCE: float = 6.0

const COLOR_BODY: Color = Color("#e0651f")
const COLOR_EYE: Color = Color("#35e0ff")
const COLOR_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.35)
const COLOR_LIMB: Color = Color("#c9c4e0")
const COLOR_LIMB_WORN: Color = Color("#e05050")

var facing: Vector2 = Vector2.DOWN
var is_crouching: bool = false
var body: ModularBody = ModularBody.new()
var noise_bus: NoiseBus

var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _autorun: bool = false
var _run_toggled: bool = false
var _noise_timer: float = 0.0


func _ready() -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = RADIUS
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	add_child(collider)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	collision_layer = PhysicsLayers.PLAYER
	collision_mask = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER


func _physics_process(delta: float) -> void:
	if body.is_dead:
		velocity = Vector2.ZERO
		return
	_read_toggles()
	var direction: Vector2 = _resolve_direction()
	velocity = direction * current_speed()
	if direction != Vector2.ZERO and direction != facing:
		facing = direction
	var before: Vector2 = global_position
	move_and_slide()
	_after_move(global_position.distance_to(before), delta)
	queue_redraw()


func _draw() -> void:
	var height: float = current_height()
	draw_circle(Vector2(0.0, 4.0), RADIUS, COLOR_SHADOW)
	_draw_limbs(height)
	var head: Vector2 = Vector2(0.0, -height * 0.5)
	draw_circle(head, height * 0.42, COLOR_BODY)
	draw_circle(head + facing * 14.0, 6.0, COLOR_EYE)


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
	return speed * body.speed_factor()


func is_autorunning() -> bool:
	return _autorun


## Una de las 8 direcciones de sprite: 0 es este y aumenta en sentido horario.
static func octant_of(direction: Vector2) -> int:
	return posmod(roundi(direction.angle() / (TAU / 8.0)), 8)


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
	if is_running() and _noise_timer <= 0.0 and noise_bus != null:
		_noise_timer = RUN_NOISE_INTERVAL
		noise_bus.emit_noise(global_position, RUN_NOISE_RADIUS)


func _interact_nearest() -> void:
	var best: Interactable = null
	var best_distance: float = Interactable.RANGE
	for node: Node in get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		var distance: float = global_position.distance_to(item.global_position)
		if not item.used and distance <= best_distance:
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


func _draw_limbs(height: float) -> void:
	var shoulder: float = -height * 0.45
	var low: Vector2 = Vector2(36.0, shoulder + 22.0)
	var high: Vector2 = Vector2(40.0, shoulder - 26.0)
	_draw_limb(ModularBody.Slot.ARM_MAIN_LEFT, Vector2(-14.0, shoulder), Vector2(-low.x, low.y))
	_draw_limb(ModularBody.Slot.ARM_MAIN_RIGHT, Vector2(14.0, shoulder), low)
	var back: float = shoulder - 10.0
	_draw_limb(ModularBody.Slot.ARM_EXTRA_LEFT, Vector2(-12.0, back), Vector2(-high.x, high.y))
	_draw_limb(ModularBody.Slot.ARM_EXTRA_RIGHT, Vector2(12.0, back), high)
	_draw_limb(ModularBody.Slot.LEG_LEFT, Vector2(-8.0, -8.0), Vector2(-10.0, 4.0))
	_draw_limb(ModularBody.Slot.LEG_RIGHT, Vector2(8.0, -8.0), Vector2(10.0, 4.0))


func _draw_limb(slot: ModularBody.Slot, from: Vector2, to: Vector2) -> void:
	var piece: BodyPiece = body.equipped(slot)
	if piece == null:
		return
	var ratio: float = piece.durability / BodyPiece.MAX_DURABILITY
	draw_line(from, to, COLOR_LIMB_WORN.lerp(COLOR_LIMB, ratio), 6.0)
