class_name Detector
extends RefCounted
## Cono de visión y medidor de detección.

signal detected(position: Vector2)

## Valores provisionales, a ajustar al probar.
const CROUCH_RANGE_FACTOR: float = 0.7
const MIN_FILL_TIME: float = 0.6
const EXTRA_FILL_TIME_AT_RANGE: float = 1.0
const DECAY_TIME: float = 1.5

var view_range: float
var half_angle: float
var low_cover_blocks: bool
var facing_angle: float = 0.0
var meter: float = 0.0

var _fired: bool = false


func _init(new_range: float, half_angle_degrees: float, blocks_with_low_cover: bool) -> void:
	view_range = new_range
	half_angle = deg_to_rad(half_angle_degrees)
	low_cover_blocks = blocks_with_low_cover


func update(origin: Vector2, world: World2D, target: Player, delta: float) -> void:
	if can_see(origin, world, target):
		var distance: float = origin.distance_to(target.global_position)
		var fill: float = MIN_FILL_TIME + EXTRA_FILL_TIME_AT_RANGE * distance / view_range
		meter = minf(meter + delta / fill, 1.0)
		if meter >= 1.0 and not _fired:
			_fired = true
			detected.emit(target.global_position)
	else:
		meter = maxf(meter - delta / DECAY_TIME, 0.0)
		if meter <= 0.0:
			_fired = false


func can_see(origin: Vector2, world: World2D, target: Player) -> bool:
	var reach: float = view_range * (CROUCH_RANGE_FACTOR if target.is_crouching else 1.0)
	if not in_cone(origin, facing_angle, half_angle, reach, target.global_position):
		return false
	var mask: int = PhysicsLayers.WALLS
	if low_cover_blocks and target.is_crouching:
		mask |= PhysicsLayers.LOW_COVER
	return ray_end(origin, target.global_position, world, mask) == target.global_position


func reset() -> void:
	meter = 0.0
	_fired = false


static func in_cone(
	origin: Vector2, facing: float, half: float, reach: float, point: Vector2
) -> bool:
	var offset: Vector2 = point - origin
	if offset.length() > reach:
		return false
	return absf(angle_difference(facing, offset.angle())) <= half


## Hasta dónde llega un rayo antes de chocar; devuelve to si no choca.
static func ray_end(from: Vector2, to: Vector2, world: World2D, mask: int) -> Vector2:
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to, mask)
	var hit: Dictionary = world.direct_space_state.intersect_ray(query)
	return to if hit.is_empty() else hit[&"position"]
