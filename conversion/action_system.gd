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
const CALM_TIME: float = 1.2
const REDIRECT_RANGE: float = 420.0
const FAR_ZOOM: float = 0.7
const RED_BUTTON: Array[Dictionary] = [
	{"k": "noise", "r": 900.0}, {"k": "boost", "t": 3.0}, {"k": "hide", "t": 6.0},
	{"k": "reveal", "what": "all", "t": 6.0}, {"k": "stun_all", "t": 3.0, "r": 400.0},
]

var level: Sandbox

var _cooldowns: Dictionary = {}
var _robbed: Dictionary = {}


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
	var weapon: Dictionary = WeaponCatalog.player(id) if WeaponCatalog.has_player_weapon(id) else {}
	_cooldowns[id] = float(weapon.get("cooldown", COOLDOWN)) * body.multiplier("cooldown")
	level.player.set_action("recarga")
	body.wear_piece(
		action["slot"] as ModularBody.Slot, float(weapon.get("wear", USE_WEAR)) * body.multiplier("use_wear")
	)
	return true


func _perform(id: String) -> bool:
	var player: Player = level.player
	if WeaponCatalog.has_player_weapon(id):
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
			if level.door_open() or level.door_rects().is_empty():
				return false
			if not _near(level.door_rects()[0].get_center(), HACK_RANGE * level.ai.perks.hack_factor()):
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
	var spec: Dictionary = level.catalog.actions.get(id, {}).get("do", {})
	return false if spec.is_empty() else _perform_generic(spec)


## Acciones del catálogo descritas por datos. Valores provisionales (P-02).
func _perform_generic(spec: Dictionary) -> bool:
	var player: Player = level.player
	var mouse: Vector2 = player.get_global_mouse_position()
	var time: float = float(spec.get("t", 0.0))
	var faction: String = str(spec.get("faction", ""))
	var reach: float = float(spec.get("reach", MELEE_RANGE))
	var stun_factor: float = player.body.multiplier("stun") * level.ai.stun_bonus()
	var done: bool = true
	match str(spec["k"]):
		"stun":
			var victim: Guard = _closest_guard(reach, faction)
			done = victim != null
			if done:
				victim.stun(time * stun_factor)
		"stun_all":
			done = _stun_around(time * stun_factor, float(spec["r"]), faction, int(spec.get("limit", 99))) > 0
		"calm":
			var calmed: Guard = _closest_guard(reach, faction)
			done = calmed != null
			if done:
				calmed.stun(CALM_TIME)
		"calm_all":
			done = _stun_around(CALM_TIME, float(spec["r"]), "", 99) > 0
		"redirect":
			var sent: Guard = _closest_guard(REDIRECT_RANGE, "")
			done = sent != null
			if done:
				sent.investigate(mouse)
		"boost":
			player.start_boost(time)
			player.silent_time = time if spec.has("silent") else 0.0
			player.slow_time = float(spec.get("slow", 0.0))
			if spec.has("slow"):
				player.slow_time += time
		"blink":
			_blink(mouse, reach)
		"hide":
			player.start_hide(time)
		"disguise":
			player.start_disguise(
				faction, time * level.ai.perks.disguise_time_factor(), level.ai.perks.disguise_range_factor()
			)
		"noise":
			level.noise_bus.emit_noise(mouse, float(spec["r"]))
		"decoy":
			var decoy: Decoy = Decoy.new()
			decoy.setup(mouse, time, level.noise_bus)
			level.actors.add_child(decoy)
		"reveal":
			_reveal(str(spec["what"]), time)
		"zoom":
			_zoom_out(time)
		"camera":
			done = is_instance_valid(level.security_camera) and _near(level.security_camera.global_position, HACK_RANGE)
			if done:
				level.security_camera.blind(time * level.ai.perks.hack_factor())
				level.ai.on_hacked()
		"drone":
			done = is_instance_valid(level.drone) and _near(level.drone.global_position, HACK_RANGE)
			if done:
				level.drone.confuse(time * level.ai.perks.hack_factor())
				level.ai.on_hacked()
		"door":
			done = not level.door_open() and not level.door_rects().is_empty()
			if done:
				done = _near(level.door_rects()[0].get_center(), reach)
			if done:
				door_hacked.emit()
		"relation":
			done = level is DespliegueCeroZone
			if done:
				(level as DespliegueCeroZone).live_world.sim.change_species_relation(float(spec["amount"]))
		"pull":
			done = _pull_pickup(float(spec["r"]))
		"steal":
			done = _steal(time * stun_factor)
		"random":
			return _perform_generic(RED_BUTTON[level.rng.randi_range(0, RED_BUTTON.size() - 1)])
		_:
			done = false
	if done and spec.has("noise"):
		level.noise_bus.emit_noise(player.global_position, float(spec["noise"]))
	return done


func _closest_guard(reach: float, faction: String) -> Guard:
	var best: Guard = null
	var best_distance: float = reach
	for guard: Guard in level.guards():
		var distance: float = guard.global_position.distance_to(level.player.global_position)
		if not guard.is_down() and distance <= best_distance and (faction.is_empty() or guard.detector.faction == faction):
			best = guard
			best_distance = distance
	return best


func _stun_around(duration: float, radius: float, faction: String, limit: int) -> int:
	var count: int = 0
	for guard: Guard in level.guards():
		if count < limit and not guard.is_down() and _near(guard.global_position, radius):
			if faction.is_empty() or guard.detector.faction == faction:
				guard.stun(duration)
				count += 1
	return count


## Salta por encima de coberturas bajas, nunca a través de paredes.
func _blink(point: Vector2, reach: float) -> void:
	var player: Player = level.player
	var goal: Vector2 = player.global_position + (point - player.global_position).limit_length(reach)
	var world: World2D = player.get_world_2d()
	var end: Vector2 = Detector.ray_end(player.global_position, goal, world, PhysicsLayers.WALLS)
	var direction: Vector2 = player.global_position.direction_to(end)
	if end != goal:
		end -= direction * Player.RADIUS * 1.5
	while end.distance_to(player.global_position) > Player.RADIUS and _blocked(end):
		end -= direction * Player.RADIUS
	if not _blocked(end):
		player.global_position = end


func _blocked(point: Vector2) -> bool:
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collision_mask = PhysicsLayers.WALLS | PhysicsLayers.LOW_COVER
	return not level.player.get_world_2d().direct_space_state.intersect_point(query, 1).is_empty()


func _reveal(what: String, duration: float) -> void:
	var overlay: RevealOverlay = RevealOverlay.new()
	overlay.setup(level, what, duration)
	level.add_child(overlay)


func _zoom_out(duration: float) -> void:
	var camera: CameraZoom = get_viewport().get_camera_2d() as CameraZoom
	if camera == null:
		return
	var before: Vector2 = camera.zoom
	camera.zoom = Vector2(CameraZoom.MIN_ZOOM, CameraZoom.MIN_ZOOM) * FAR_ZOOM
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_instance_valid(camera):
			camera.zoom = before
	)


func _pull_pickup(radius: float) -> bool:
	var player: Player = level.player
	for node: Node in get_tree().get_nodes_in_group(Interactable.GROUP):
		var item: Interactable = node as Interactable
		if not item.used and item.is_pickup() and player.body.can_stow_in(item.pickup_slots()) and _near(item.global_position, radius):
			item.activate()
			return true
	return false


func _steal(duration: float) -> bool:
	var victim: Guard = _closest_guard(MELEE_RANGE, "")
	if victim == null or _robbed.has(victim) or not level is DespliegueCeroZone:
		return false
	_robbed[victim] = true
	victim.stun(duration)
	(level as DespliegueCeroZone).reward_piece()
	return true


func _stun_guard(duration: float) -> bool:
	for guard: Guard in level.guards():
		if not guard.is_down() and _near(guard.global_position, MELEE_RANGE):
			guard.stun(duration)
			return true
	return false


func _near(point: Vector2, distance: float) -> bool:
	return level.player.global_position.distance_to(point) <= distance
