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
const THROW_COOLDOWN: float = 1.0
const HIT_MARGIN: float = 10.0
const THROWN: Dictionary = {
	"damage": 8.0, "stun": 0.0, "range": 320.0, "pellets": 1, "spread": 0.0,
	"noise": 160.0, "noise_at_impact": true, "stops_at_aim": true, "color": Color("#c0c0c0"),
}
## Armas a distancia del catálogo, por acción. Valores provisionales: ver el ADR 0005.
const RANGED_WEAPONS: Dictionary = {
	"a101": {
		"damage": 10.0, "stun": 0.0, "range": 380.0, "pellets": 1, "spread": 0.0,
		"noise": 120.0, "noise_at_impact": true, "cooldown": 1.0, "wear": 1.0,
		"color": Color("#d8d0a0"),
	},
	"a102": {
		"damage": 9.0, "stun": 0.0, "range": 200.0, "pellets": 5, "spread": 18.0,
		"noise": 420.0, "noise_at_impact": false, "cooldown": 3.0, "wear": 6.0,
		"color": Color("#ffa040"),
	},
	"a103": {
		"damage": 40.0, "stun": 0.0, "range": 560.0, "pellets": 1, "spread": 0.0,
		"noise": 240.0, "noise_at_impact": false, "cooldown": 4.0, "wear": 4.0,
		"color": Color("#70d0ff"),
	},
	"a104": {
		"damage": 0.0, "stun": 4.0, "range": 300.0, "pellets": 1, "spread": 0.0,
		"noise": 100.0, "noise_at_impact": true, "cooldown": 7.0, "wear": 3.0,
		"color": Color("#90e040"),
	},
}
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
	damage *= level.ai.perks.melee_factor() * body.multiplier("melee")
	damage *= 1.0 + body.total("melee_per_spare") * float(body.spare_count())
	if not enemy.is_alert():
		damage *= SILENT_SNEAK_FACTOR if body.has_action("a002") else SNEAK_FACTOR
	return damage


## Devuelve si se ha realizado el golpe.
func strike(enemy: Guard) -> bool:
	var body: ModularBody = level.player.body
	if _attack_timer > 0.0 or body.arm_count() == 0:
		return false
	_attack_timer = attack_interval()
	level.player.break_disguise()
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
	_shoot(THROWN, point)
	return true


## Dispara el arma de la acción hacia el punto. Las recargas las lleva ActionSystem.
func fire_weapon(id: String, point: Vector2) -> bool:
	if not RANGED_WEAPONS.has(id):
		return false
	_shoot(RANGED_WEAPONS[id] as Dictionary, point)
	return true


func _shoot(weapon: Dictionary, point: Vector2) -> void:
	var origin: Vector2 = level.player.global_position
	var offset: Vector2 = point - origin
	var direction: Vector2 = level.player.facing if offset.is_zero_approx() else offset.normalized()
	var reach: float = float(weapon["range"])
	if weapon.get("stops_at_aim", false):
		reach = minf(reach, offset.length())
	var pellets: int = weapon["pellets"]
	var spread: float = float(weapon["spread"])
	var impact: Vector2 = origin
	for pellet: int in range(pellets):
		var weight: float = 0.5 if pellets == 1 else float(pellet) / float(pellets - 1)
		var angle: float = deg_to_rad(lerpf(-spread, spread, weight))
		impact = _cast_shot(weapon, origin, origin + direction.rotated(angle) * reach)
	var noise_at: Vector2 = impact if weapon["noise_at_impact"] else origin
	level.noise_bus.emit_noise(noise_at, float(weapon["noise"]))


## Paredes y coberturas detienen el tiro; solo lo recibe el primer enemigo de la línea.
func _cast_shot(weapon: Dictionary, origin: Vector2, aim: Vector2) -> Vector2:
	var mask: int = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER
	var end: Vector2 = Detector.ray_end(origin, aim, level.player.get_world_2d(), mask)
	var victim: Guard = null
	var best: float = INF
	for enemy: Guard in level.guards():
		if enemy.is_down():
			continue
		var at: Vector2 = enemy.global_position
		var closest: Vector2 = Geometry2D.get_closest_point_to_segment(at, origin, end)
		if closest.distance_to(at) <= Guard.RADIUS + HIT_MARGIN and origin.distance_to(closest) < best:
			best = origin.distance_to(closest)
			victim = enemy
	if victim != null:
		end = origin + (end - origin).limit_length(best)
		_apply_shot(weapon, victim)
	level.spawn_tracer(origin, end, weapon["color"] as Color)
	return end


func _apply_shot(weapon: Dictionary, victim: Guard) -> void:
	if float(weapon["damage"]) > 0.0:
		victim.take_damage(float(weapon["damage"]))
	if float(weapon["stun"]) > 0.0:
		var factor: float = level.player.body.multiplier("stun") * level.ai.stun_bonus()
		victim.stun(float(weapon["stun"]) * factor)


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
