class_name CombatSystem
extends Node
## Ataques del jugador: cuerpo a cuerpo automático y lanzamientos.

## Valores provisionales: ver docs/adr/0005-combate.md.
const BASE_DAMAGE: float = 12.0
const BASE_INTERVAL: float = 0.8
const MELEE_RANGE: float = 75.0
const SNEAK_FACTOR: float = 2.0
const SILENT_SNEAK_FACTOR: float = 4.0
const ATTACK_NOISE_RADIUS: float = 220.0
const ARM_WEAR_PER_ATTACK: float = 1.0
const REPATH_TIME: float = 0.3
const THROW_DAMAGE: float = 8.0
const THROW_RANGE: float = 320.0
const THROW_COOLDOWN: float = 1.0
const THROW_NOISE_RADIUS: float = 160.0
const SLAP_BONUS_PER_ARM: float = 5.0
const WIDE_SLASH_BONUS: float = 12.0
const WIDE_SLASH_RADIUS: float = 90.0
const OLD_BLOW_BONUS: float = 25.0
const OLD_BLOW_INTERVAL_FACTOR: float = 1.6

var level: Sandbox
var target: Guard = null

var _attack_timer: float = 0.0
var _throw_timer: float = 0.0
var _repath_timer: float = 0.0


func engage(enemy: Guard) -> void:
	target = enemy
	_repath_timer = 0.0


func disengage() -> void:
	target = null


func _physics_process(delta: float) -> void:
	_attack_timer = maxf(_attack_timer - delta, 0.0)
	_throw_timer = maxf(_throw_timer - delta, 0.0)
	if Input.is_action_just_pressed(&"throw"):
		throw_at(level.player.get_global_mouse_position())
	if target == null:
		return
	if not is_instance_valid(target) or target.is_down():
		target = null
		return
	if Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down") != Vector2.ZERO:
		target = null
		return
	_pursue(delta)


func attack_interval() -> float:
	var body: ModularBody = level.player.body
	var missing: int = 4 - body.arm_count()
	var interval: float = BASE_INTERVAL * (1.0 + 0.25 * float(missing))
	if body.has_action("a008"):
		interval *= OLD_BLOW_INTERVAL_FACTOR
	return interval


func attack_damage(enemy: Guard) -> float:
	var body: ModularBody = level.player.body
	var damage: float = BASE_DAMAGE
	if body.has_action("a001"):
		damage += WIDE_SLASH_BONUS
	if body.has_action("a005"):
		damage += SLAP_BONUS_PER_ARM * float(body.arm_count())
	if body.has_action("a008"):
		damage += OLD_BLOW_BONUS
	if not enemy.is_alert():
		damage *= SILENT_SNEAK_FACTOR if body.has_action("a002") else SNEAK_FACTOR
	return damage


## Devuelve si se ha realizado el golpe.
func strike(enemy: Guard) -> bool:
	var body: ModularBody = level.player.body
	if _attack_timer > 0.0 or body.arm_count() == 0:
		return false
	_attack_timer = attack_interval()
	var silent: bool = body.has_action("a002") and not enemy.is_alert()
	enemy.take_damage(attack_damage(enemy))
	if body.has_action("a001"):
		_hit_neighbours(enemy)
	_wear_an_arm()
	if not silent:
		level.noise_bus.emit_noise(level.player.global_position, ATTACK_NOISE_RADIUS)
	return true


## Lanza chatarra: la primera pared u obstáculo la detiene.
func throw_at(point: Vector2) -> bool:
	if _throw_timer > 0.0 or level.player.body.arm_count() == 0:
		return false
	_throw_timer = THROW_COOLDOWN
	var origin: Vector2 = level.player.global_position
	var aim: Vector2 = origin + (point - origin).limit_length(THROW_RANGE)
	var mask: int = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER
	var end: Vector2 = Detector.ray_end(origin, aim, level.player.get_world_2d(), mask)
	level.spawn_tracer(origin, end, Color("#c0c0c0"))
	level.noise_bus.emit_noise(end, THROW_NOISE_RADIUS)
	for enemy: Guard in level.guards():
		if not enemy.is_down() and Geometry2D.get_closest_point_to_segment(
			enemy.global_position, origin, end
		).distance_to(enemy.global_position) <= Guard.RADIUS + 10.0:
			enemy.take_damage(THROW_DAMAGE)
			return true
	return true


func _pursue(delta: float) -> void:
	var player: Player = level.player
	if player.global_position.distance_to(target.global_position) <= MELEE_RANGE:
		player.set_path(PackedVector2Array())
		strike(target)
		return
	_repath_timer -= delta
	if _repath_timer <= 0.0:
		_repath_timer = REPATH_TIME
		player.set_path(level.nav.find_path(player.global_position, target.global_position))


func _hit_neighbours(enemy: Guard) -> void:
	for other: Guard in level.guards():
		if other == enemy or other.is_down():
			continue
		if other.global_position.distance_to(enemy.global_position) <= WIDE_SLASH_RADIUS:
			other.take_damage(BASE_DAMAGE)


func _wear_an_arm() -> void:
	var body: ModularBody = level.player.body
	for slot: ModularBody.Slot in [
		ModularBody.Slot.ARM_MAIN_RIGHT,
		ModularBody.Slot.ARM_MAIN_LEFT,
		ModularBody.Slot.ARM_EXTRA_RIGHT,
		ModularBody.Slot.ARM_EXTRA_LEFT,
	]:
		if body.equipped(slot) != null:
			body.wear_piece(slot, ARM_WEAR_PER_ATTACK)
			return
