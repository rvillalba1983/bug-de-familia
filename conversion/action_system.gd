class_name ActionSystem
extends Node
## Ejecuta las acciones activas de las piezas puestas, con las teclas numéricas.

signal door_hacked

## Valores provisionales.
const COOLDOWN: float = 6.0
const USE_WEAR: float = 5.0
const MELEE_RANGE: float = 110.0
const HACK_RANGE: float = 420.0
const STUN_TIME: float = 5.0
const SLAP_STUN_TIME: float = 3.0
const SLAP_NOISE_RADIUS: float = 300.0
const BOOST_TIME: float = 2.0
const DISABLE_TIME: float = 6.0
const LURE_NOISE_RADIUS: float = 420.0
const MAX_KEYS: int = 6

var level: Sandbox

var _cooldowns: Dictionary = {}


func _physics_process(delta: float) -> void:
	for id: String in _cooldowns.keys():
		_cooldowns[id] = maxf(float(_cooldowns[id]) - delta, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	for index: int in range(MAX_KEYS):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			trigger(index)
			return


func trigger(index: int) -> bool:
	var body: ModularBody = level.player.body
	var available: Array = body.active_actions()
	if index >= available.size():
		return false
	var action: Dictionary = available[index]
	var id: String = action["id"]
	if float(_cooldowns.get(id, 0.0)) > 0.0 or not _perform(id):
		return false
	var weapon: Dictionary = CombatSystem.RANGED_WEAPONS.get(id, {})
	_cooldowns[id] = float(weapon.get("cooldown", COOLDOWN))
	body.wear_piece(action["slot"] as ModularBody.Slot, float(weapon.get("wear", USE_WEAR)))
	return true


func _perform(id: String) -> bool:
	var player: Player = level.player
	if CombatSystem.RANGED_WEAPONS.has(id):
		return level.combat.fire_weapon(id, player.get_global_mouse_position())
	var stun_factor: float = player.body.multiplier("stun") * level.ai.stun_bonus()
	match id:
		"a003":
			return _stun_guard(STUN_TIME * stun_factor)
		"a006":
			if not _stun_guard(SLAP_STUN_TIME * stun_factor):
				return false
			level.noise_bus.emit_noise(player.global_position, SLAP_NOISE_RADIUS)
			return true
		"a009":
			player.start_boost(BOOST_TIME)
			return true
		"a054":
			if level.door.is_open or not _near(level.door_rects()[0].get_center(), HACK_RANGE * level.ai.perks.hack_factor()):
				return false
			door_hacked.emit()
			level.ai.on_hacked()
			return true
		"a055":
			var camera: SecurityCamera = level.security_camera
			if not is_instance_valid(camera) or not _near(camera.global_position, HACK_RANGE):
				return false
			camera.blind(DISABLE_TIME * level.ai.perks.hack_factor())
			level.ai.on_hacked()
			return true
		"a056":
			var drone: Drone = level.drone
			if not is_instance_valid(drone) or not _near(drone.global_position, HACK_RANGE):
				return false
			drone.confuse(DISABLE_TIME * level.ai.perks.hack_factor())
			level.ai.on_hacked()
			return true
		"a062":
			level.noise_bus.emit_noise(player.get_global_mouse_position(), LURE_NOISE_RADIUS)
			return true
	return false


func _stun_guard(duration: float) -> bool:
	for guard: Guard in level.guards():
		if not guard.is_down() and _near(guard.global_position, MELEE_RANGE):
			guard.stun(duration)
			return true
	return false


func _near(point: Vector2, distance: float) -> bool:
	return level.player.global_position.distance_to(point) <= distance
