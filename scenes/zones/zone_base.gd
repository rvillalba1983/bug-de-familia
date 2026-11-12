class_name ZoneBase
extends Sandbox
## Zona genérica del mundo (ADR 0027). La escena es fija y la geometría, la
## población y los objetos se declaran en data/zones/<id>.json.
##
## La beta conserva su escena propia (`BetaZone extends ZoneBase`). Las zonas
## provisionales usan `scenes/zones/zone.tscn`, que monta el suelo, los bloques
## de forma, los corredores y los puntos de guardado del JSON.

signal transition_requested(to_zone: String)

const ART_FOLDER: String = "res://art/beta/"
const FAST_TRAVEL_LABEL: String = "UI_FAST_TRAVEL"
const FAST_TRAVEL_ITEM: String = "fast_travel_"
## Provisional: distancia a la que un grupo se mete en la pelea de los suyos.
const GROUP_REACT_RADIUS: float = 250.0

var definition: ZoneDefinition = null
var live_world: LiveWorld = null
var battles: BattleDirector = null

var _zone_enemy_ids: Dictionary = {}
var _zone_materials: Dictionary = {}
var _corridor_areas: Array[Area2D] = []


func zone_definition() -> ZoneDefinition:
	return definition


func set_definition(zone: ZoneDefinition) -> void:
	definition = zone


func world_size() -> Vector2:
	return _definition().world_size()


func floor_rect() -> Rect2:
	return _definition().floor_rect()


func start_point() -> Vector2:
	return _definition().start()


func wall_rects() -> Array[Rect2]:
	if not _definition().has("walls"):
		return []
	return _definition().rects("walls")


func low_cover_rects() -> Array[Rect2]:
	if not _definition().has("low_covers"):
		return []
	return _definition().rects("low_covers")


func door_rects() -> Array[Rect2]:
	return []


func save_point_positions() -> Array[Vector2]:
	if not _definition().has("save_points"):
		return [start_point()]
	return _definition().points("save_points")


func open_spots() -> Array[Vector2]:
	if not _definition().has("open_spots"):
		return [start_point()]
	return _definition().points("open_spots")


func shape_blocks() -> Array[Rect2]:
	return _definition().shape_blocks()


func corridor_rects() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for corridor: Dictionary in _definition().corridors():
		result.append(corridor["rect"])
	return result


## Estado del mundo vivo, para que el gestor lo persista al salir de la zona.
func world_state() -> Dictionary:
	return live_world.to_dict() if live_world != null else {}


func population_counts() -> Dictionary:
	var counts: Dictionary = {}
	if live_world == null:
		return counts
	for id: String in live_world.sim.npc_ids:
		var npc: NpcState = live_world.sim.npcs[id]
		if npc.alive:
			counts[npc.species] = int(counts.get(npc.species, 0)) + 1
	return counts


## El gestor llama a esto después de montar la escena y aplicar el guardado.
func after_enter(from_zone: String) -> void:
	if not from_zone.is_empty():
		player.global_position = _definition().entry_point(from_zone)
	freeze_player(false)


func freeze_player(frozen: bool) -> void:
	if not is_instance_valid(player):
		return
	player.set_physics_process(not frozen)
	player.set_process_unhandled_input(not frozen)


func is_in_combat() -> bool:
	return fight != null and fight.phase != FightDirector.Phase.CALM


func _build_world() -> void:
	super()
	_build_corridors()
	_build_fast_travel()


func _build_boundaries() -> void:
	LevelBounds.build(self, floor_rect(), corridor_rects())


func _build_walls() -> void:
	for rect: Rect2 in wall_rects():
		_add_wall(rect, SandboxLayout.WALL_FRONT_HEIGHT, Wall.Kind.SOLID)
	for rect: Rect2 in low_cover_rects():
		_add_wall(rect, SandboxLayout.LOW_FRONT_HEIGHT, Wall.Kind.LOW)
	for rect: Rect2 in shape_blocks():
		_add_blocker(rect)
	var doors: Array[Rect2] = door_rects()
	if not doors.is_empty():
		door = _add_wall(doors[0], SandboxLayout.WALL_FRONT_HEIGHT, Wall.Kind.DOOR)
		door.label_key = "ITEM_DOOR"


## Los bloques de forma no se dibujan como muro: cierran el paso y oscurecen.
func _add_blocker(rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.collision_layer = PhysicsLayers.WALLS
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = rect.size
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	collider.position = rect.get_center()
	body.add_child(collider)
	add_child(body)


func _build_corridors() -> void:
	for corridor: Dictionary in _definition().corridors():
		var area: Area2D = Area2D.new()
		area.collision_layer = 0
		area.collision_mask = PhysicsLayers.PLAYER
		area.monitoring = true
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = (corridor["rect"] as Rect2).size
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = shape
		collider.position = (corridor["rect"] as Rect2).get_center()
		area.add_child(collider)
		area.body_entered.connect(_on_corridor_entered.bind(str(corridor["to"])))
		add_child(area)
		_corridor_areas.append(area)


func _on_corridor_entered(body: Node2D, to_zone: String) -> void:
	if body != player:
		return
	transition_requested.emit(to_zone)


func _build_fast_travel() -> void:
	for index: int in range(save_points.size()):
		var point: SavePoint = save_points[index]
		var item: Interactable = Interactable.new()
		item.setup(FAST_TRAVEL_ITEM + str(index), Interactable.Kind.TERMINAL, point.position + Vector2(36.0, 0.0))
		item.custom_label = tr(FAST_TRAVEL_LABEL)
		item.reusable = true
		item.activated.connect(_on_fast_travel)
		actors.add_child(item)


func _on_fast_travel(_item: Interactable) -> void:
	if zone_manager == null or not zone_manager.has_method("travel_destinations"):
		return
	var destinations: Array = zone_manager.travel_destinations()
	if destinations.is_empty():
		show_notice(tr("UI_FAST_TRAVEL_EMPTY"))
		return
	var screen: MessageScreen = MessageScreen.new()
	var entries: Array = []
	for entry: Dictionary in destinations:
		entries.append([str(entry["name"]), _travel_to.bind(str(entry["id"]), screen)])
	entries.append([tr("UI_FAST_TRAVEL_BACK"), _close_travel.bind(screen)])
	screen.setup(FAST_TRAVEL_LABEL, entries)
	pause.begin_modal()
	add_child(screen)


func _travel_to(zone_id: String, screen: MessageScreen) -> void:
	_close_travel(screen)
	if zone_manager != null and not zone_manager.fast_travel(zone_id):
		show_notice(tr("UI_FAST_TRAVEL_BLOCKED"))


func _close_travel(screen: MessageScreen) -> void:
	screen.queue_free()
	pause.end_modal()


func _build_enemies() -> void:
	pass


func _build_investigation() -> void:
	ai = AiChatter.new()
	ai.level = self
	add_child(ai)
	investigation = InvestigationDirector.new()
	investigation.level = self
	investigation.enabled = false
	add_child(investigation)
	live_world = LiveWorld.new()
	live_world.level = self
	add_child(live_world)


func _register_convertibles() -> void:
	for entry: Dictionary in _definition().list("convertibles"):
		var id: String = str(entry["id"])
		if items.has(id):
			_add_convertible(id, items[id], str(entry["material"]))
	_build_props()


func _build_items() -> void:
	for entry: Dictionary in _definition().list("items"):
		var id: String = str(entry["id"])
		var at: Vector2 = _definition().point(str(entry["at"]))
		match str(entry["type"]):
			"named":
				_add_named(id, at, str(entry.get("label", id)), bool(entry.get("reusable", true)))
				if entry.has("art"):
					(items[id] as Interactable).art = load(str(entry["art"])) as Texture2D
			"crate":
				_add_item(id, Interactable.Kind.CRATE, at)
			"leg":
				_add_item(id, Interactable.Kind.PICKUP_LEG, at)
			"arm":
				_add_item(id, Interactable.Kind.PICKUP_ARM, at)
			_:
				push_error("%s: tipo de objeto desconocido en «%s»" % [_definition().path, id])


func _add_named(id: String, at: Vector2, label: String, reusable: bool) -> void:
	_add_item(id, Interactable.Kind.TERMINAL, at)
	var item: Interactable = items[id]
	item.custom_label = label
	item.reusable = reusable


func _build_props() -> void:
	for entry: Dictionary in _definition().list("props"):
		var spots: Array[Vector2] = _definition().points(str(entry["at"]))
		var size: Vector2 = Vector2(float(entry["size"][0]), float(entry["size"][1]))
		for index: int in range(spots.size()):
			var prop: WorldProp = WorldProp.new()
			prop.setup(str(entry["prop"]), spots[index], size)
			actors.add_child(prop)
			_add_convertible("%s_%d" % [str(entry["id_prefix"]), index], prop, str(entry["material"]))


## Pone en escena a un habitante del mundo vivo.
func add_citizen(id: String, species: String, at: Vector2, home: Rect2) -> Guard:
	var route: Array[Vector2] = [at, at + Vector2(90.0, 0.0)]
	route[1] = route[1].clamp(home.position, home.end)
	var guard_node: Guard = _add_zone_guard(id, route, _species_look(species))
	guard_node.set_passive(true)
	_add_convertible(id, guard_node, _zone_materials[guard_node])
	fight.track(guard_node)
	guard_node.fell.connect(_on_zone_enemy_fell)
	guard_node.corpse_expired.connect(_on_corpse_expired)
	guard_node.attacked.connect(_on_zone_citizen_attacked.bind(guard_node, species))
	return guard_node


func guards() -> Array[Guard]:
	var result: Array[Guard] = []
	for enemy: Variant in _zone_enemy_ids:
		if is_instance_valid(enemy):
			result.append(enemy as Guard)
	return result


func id_of_guard(enemy: Guard) -> String:
	return str(_zone_enemy_ids.get(enemy, ""))


func attack_citizen(enemy: Guard) -> void:
	selection.select_exactly(enemy)
	combat.engage(enemy)


func attack_dialogue_speaker(speaker: String) -> void:
	for enemy: Guard in guards():
		if not is_instance_valid(enemy) or enemy.is_down():
			continue
		if id_of_guard(enemy) == speaker:
			attack_citizen(enemy)
			return
	if live_world != null and live_world.citizens.has(speaker):
		var citizen: Guard = live_world.citizens[speaker]
		if is_instance_valid(citizen) and not citizen.is_down():
			attack_citizen(citizen)


func reward_piece() -> void:
	_add_pickup([ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT])


func _add_zone_guard(id: String, route: Array[Vector2], look: Dictionary) -> Guard:
	var enemy: Guard = Guard.new()
	enemy.target = player
	enemy.nav = nav
	enemy.rng = rng
	enemy.visual.body_color = look["color"]
	enemy.visual.art_views = _load_views(str(look["art"]))
	enemy.visual.rig_folder = ART_FOLDER + "rig/" + str(look["art"])
	enemy.death = DeathCatalog.pick(look["deaths"], rng)
	enemy.setup(route, ground)
	actors.add_child(enemy)
	_zone_enemy_ids[enemy] = id
	_zone_materials[enemy] = look["material"]
	return enemy


func _species_look(species: String) -> Dictionary:
	return {
		"species": species, "color": SpeciesCatalog.color(species), "art": SpeciesCatalog.art(species),
		"material": SpeciesCatalog.material(species), "deaths": SpeciesCatalog.deaths(species),
	}


func _load_views(base: String) -> Array[Texture2D]:
	var views: Array[Texture2D] = []
	for suffix: String in ["", "_e", "_n"]:
		views.append(load(ART_FOLDER + base + suffix + ".svg") as Texture2D)
	return views


func _on_zone_enemy_fell(enemy: Guard) -> void:
	fallen_ids.append(id_of_guard(enemy))
	if live_world != null:
		live_world.on_citizen_gone(id_of_guard(enemy))


func _on_zone_citizen_attacked(victim: Guard, species: String) -> void:
	for id: String in live_world.citizens:
		var other: Guard = live_world.citizens[id]
		if other == victim or not is_instance_valid(other):
			continue
		if (live_world.sim.npcs[id] as NpcState).species != species:
			continue
		if battles != null and battles.is_fighter(id):
			continue
		if other.global_position.distance_to(victim.global_position) <= GROUP_REACT_RADIUS:
			other.join_fight()


func _shows_help_labels() -> bool:
	return true


## Los bloques de forma cierran el paso y deben estar en la rejilla de navegación.
func _all_blockers() -> Array[Rect2]:
	var result: Array[Rect2] = super()
	result.append_array(shape_blocks())
	return result


func objective_key() -> String:
	return "ZONE_OBJECTIVE"


func _check_goal(_feet: Vector2) -> void:
	pass


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size()), COLOR_BACKGROUND)
	draw_rect(floor_rect(), COLOR_FLOOR)
	for block: Rect2 in shape_blocks():
		draw_rect(block, COLOR_BACKGROUND)


func _begin_fresh() -> void:
	super()
	if live_world != null:
		live_world.start({})


func _apply_save(data: Dictionary) -> bool:
	var result: bool = super(data)
	if result and not data["dead"] and live_world != null:
		live_world.start(data.get("world", {}))
	return result


func snapshot() -> Dictionary:
	var data: Dictionary = super()
	data["world"] = world_state()
	return data


func _definition() -> ZoneDefinition:
	if definition == null:
		push_error("ZoneBase sin definir: falta set_definition() antes de montar la escena")
		return ZoneDefinition.load_from(BetaLayout.PATH)
	return definition
