class_name BetaZone
extends Sandbox
## Zona de la beta: bosque, ciudad perdida, dos bandos y cuatro retos.

const CASE_PATH: String = "res://data/investigation/case_beta.json"
const ID_MINE: String = "mina_suelta"
const ID_CRACK: String = "muro_agrietado"
const ID_REEL: String = "bobina"
const ID_GENERATOR: String = "generador"
const ID_RAMON: String = "ramon"
const ID_CONTESTADOR: String = "contestador"
const ART_FOLDER: String = "res://art/beta/"
const ART_JUBILADO: String = "jubilado_hierro"
const ART_MOHOCRATA: String = "mohocrata"
const ART_RAMON: String = "don_ramon"
const ART_FACADE_CENTRAL: String = "res://art/beta/fachada_centralita.svg"
const ART_FACADE_DEPOT: String = "res://art/beta/fachada_deposito.svg"
const ART_REEL: String = "res://art/beta/bobina.svg"
const COLOR_SHELTER: Color = Color(0.2, 0.5, 0.8, 0.22)
const COLOR_GOAL_MARK: Color = Color(0.3, 1.0, 0.5, 0.25)
const COLOR_JUBILADO: Color = Color("#a0a8b8")
const COLOR_MOHOCRATA: Color = Color("#8fbf60")
const COLOR_RAMON: Color = Color("#e0a040")
const CHAINS_IN_SUMMARY: int = 3

## Las pruebas fijan aquí la hora para no depender del reloj real.
static var forced_hour: int = -1

var challenges: BetaChallenges
var protagonist: ProtagonistVoice
var rain: AcidRain
var atmosphere: BetaAtmosphere
var live_world: LiveWorld
var cracked_wall: Wall
var ramon: Guard
var strip_jubilado: Guard
var strip_mohocrata: Guard
var mines: Dictionary = {}
var moved_to_war: bool = false
var moved_home: bool = false

var _enemy_ids: Dictionary = {}
var _jubilados: Array[Guard] = []
var _mohocratas: Array[Guard] = []
var _depot: Array[Guard] = []
var _rain_label: Label


func world_size() -> Vector2:
	return BetaLayout.WORLD_SIZE


func floor_rect() -> Rect2:
	return BetaLayout.FLOOR_RECT


func start_point() -> Vector2:
	return BetaLayout.START


func wall_rects() -> Array[Rect2]:
	return BetaLayout.WALLS


func low_cover_rects() -> Array[Rect2]:
	return BetaLayout.LOW_COVERS


func door_rects() -> Array[Rect2]:
	return [BetaLayout.CENTRAL_DOOR, BetaLayout.CRACKED_WALL]


func save_point_positions() -> Array[Vector2]:
	return BetaLayout.SAVE_POINTS


func guards() -> Array[Guard]:
	var result: Array[Guard] = []
	for enemy: Variant in _enemy_ids:
		if is_instance_valid(enemy):
			result.append(enemy as Guard)
	return result


func strip_guards() -> Array[Guard]:
	return _valid([strip_jubilado, strip_mohocrata])


func depot_guards() -> Array[Guard]:
	return _valid(_depot)


func jubilado_guards() -> Array[Guard]:
	return _valid(_jubilados)


func mohocrata_guards() -> Array[Guard]:
	return _valid(_mohocratas)


func is_enemy_id(id: String) -> bool:
	return _enemy_ids.values().has(id) or id == ID_DRONE or id == ID_CAMERA


func local_hour() -> int:
	return challenges.hour_source.call()


func ramon_item() -> Interactable:
	var item: Variant = investigation.npc_nodes.get(ID_RAMON)
	return item as Interactable if is_instance_valid(item) else null


func set_enemies_active(active: bool) -> void:
	var mode: ProcessMode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
	for enemy: Guard in guards():
		enemy.process_mode = mode
	for sentinel: Node in [drone, security_camera]:
		if is_instance_valid(sentinel):
			sentinel.process_mode = mode


func open_central_door() -> void:
	_open_door()


func open_cracked_wall() -> void:
	cracked_wall.set_open(true)
	nav.clear_rect(BetaLayout.CRACKED_WALL, Player.RADIUS, _all_blockers())


func _ready() -> void:
	super()
	challenges.apply_flags()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size()), COLOR_BACKGROUND)
	BetaGround.paint(self)
	draw_rect(BetaLayout.CROSSING_GOAL, COLOR_GOAL_MARK)
	for shelter: Rect2 in BetaLayout.SHELTERS:
		draw_rect(shelter, COLOR_SHELTER)
	WorldLabel.draw_on(self, tr("BETA_PLACE_LOOKOUT"), BetaLayout.CROSSING_GOAL.get_center())
	WorldLabel.draw_on(self, tr("BETA_PLACE_NORTH"), Vector2(1250.0, 590.0))
	WorldLabel.draw_on(self, tr("BETA_PLACE_SOUTH"), Vector2(1700.0, 1540.0))
	WorldLabel.draw_on(self, tr("BETA_PLACE_STRIP"), Vector2(1250.0, 1250.0))
	WorldLabel.draw_on(self, tr("BETA_PLACE_CENTRAL"), Vector2(2550.0, 700.0))
	WorldLabel.draw_on(self, tr("BETA_PLACE_DEPOT"), Vector2(2500.0, 1720.0))


func _objective_key() -> String:
	return "BETA_OBJECTIVE"


func _check_goal(_feet: Vector2) -> void:
	pass


func _build_walls() -> void:
	super()
	cracked_wall = _add_wall(BetaLayout.CRACKED_WALL, SandboxLayout.WALL_FRONT_HEIGHT, Wall.Kind.DOOR)
	cracked_wall.label_key = "BETA_CRACKED_WALL"
	door.label_key = "BETA_CENTRAL_DOOR"


func _build_enemies() -> void:
	guard = _add_guard("jub_barrio", BetaLayout.JUB_BARRIO_PATROL, COLOR_JUBILADO, _jubilados)
	_add_guard("jub_frente", BetaLayout.JUB_FRONT_PATROL, COLOR_JUBILADO, _jubilados)
	strip_jubilado = _add_guard("jub_tierra", BetaLayout.JUB_STRIP_PATROL, COLOR_JUBILADO, _jubilados)
	strip_mohocrata = _add_guard("moho_tierra", BetaLayout.MOHO_STRIP_PATROL, COLOR_MOHOCRATA, _mohocratas)
	_depot.append(_add_guard("moho_deposito", BetaLayout.MOHO_DEPOT_PATROL, COLOR_MOHOCRATA, _mohocratas))
	shooter = _add_guard("moho_puerta", BetaLayout.MOHO_GATE_PATROL, COLOR_MOHOCRATA, _mohocratas, true)
	_depot.append(shooter)
	ramon = _add_guard(ID_RAMON, BetaLayout.RAMON_ROUTE, COLOR_RAMON, [])
	ramon.set_passive(true)
	drone = Drone.new()
	drone.target = player
	drone.setup(BetaLayout.DRONE_PATROL, ground)
	actors.add_child(drone)
	security_camera = SecurityCamera.new()
	security_camera.target = player
	security_camera.setup(
		BetaLayout.CAMERA_POSITION,
		BetaLayout.CAMERA_CENTER_DEGREES,
		BetaLayout.CAMERA_AMPLITUDE_DEGREES,
		ground
	)
	actors.add_child(security_camera)


func _add_guard(
	id: String, route: Array[Vector2], color: Color, roster: Array, is_ranged: bool = false
) -> Guard:
	var enemy: Guard = Guard.new()
	enemy.target = player
	enemy.nav = nav
	enemy.rng = rng
	enemy.body_color = color
	enemy.art_views = _load_views(_art_base(id, color))
	enemy.rig_folder = ART_FOLDER + "rig/" + _art_base(id, color)
	if is_ranged:
		enemy.make_ranged(self)
	enemy.setup(route, ground)
	actors.add_child(enemy)
	_enemy_ids[enemy] = id
	roster.append(enemy)
	return enemy


func _build_items() -> void:
	_add_named(ID_MINE, BetaLayout.MINE_PICKUP, "BETA_ITEM_MINE", false)
	_add_named(ID_CRACK, BetaLayout.CRACKED_MARK, "BETA_ITEM_CRACK", true)
	_add_named(ID_REEL, BetaLayout.REEL, "BETA_ITEM_REEL", false)
	(items[ID_REEL] as Interactable).art = load(ART_REEL) as Texture2D
	_add_named(ID_GENERATOR, BetaLayout.GENERATOR, "BETA_ITEM_GENERATOR", false)
	_add_item(ID_CRATE, Interactable.Kind.CRATE, BetaLayout.CRATE_NORTH)
	_add_item("crate_2", Interactable.Kind.CRATE, BetaLayout.CRATE_SOUTH)
	_add_item(ID_PICKUP_LEG, Interactable.Kind.PICKUP_LEG, BetaLayout.PICKUP_LEG)
	_add_item(ID_PICKUP_ARM, Interactable.Kind.PICKUP_ARM, BetaLayout.PICKUP_ARM)
	for index: int in range(BetaLayout.MINES.size()):
		_add_mine(index)
	_build_facades()


func _art_base(id: String, color: Color) -> String:
	if id == ID_RAMON:
		return ART_RAMON
	return ART_JUBILADO if color == COLOR_JUBILADO else ART_MOHOCRATA


func _load_views(base: String) -> Array[Texture2D]:
	var views: Array[Texture2D] = []
	for suffix: String in ["", "_e", "_n"]:
		views.append(load(ART_FOLDER + base + suffix + ".svg") as Texture2D)
	return views


func _add_facade(
	path: String, base_y: float, art_rect: Rect2, interior: Rect2, labeled: Array[Wall]
) -> BuildingFacade:
	var facade: BuildingFacade = BuildingFacade.new()
	facade.texture = load(path) as Texture2D
	facade.position = Vector2(art_rect.position.x, base_y + 1.0)
	facade.art_rect = Rect2(Vector2(0.0, art_rect.position.y - facade.position.y), art_rect.size)
	facade.interior = interior
	facade.player = player
	facade.labeled_walls = labeled
	actors.add_child(facade)
	return facade


func _build_facades() -> void:
	var central: BuildingFacade = _add_facade(
		ART_FACADE_CENTRAL, BetaLayout.CENTRAL_DOOR.end.y, BetaLayout.CENTRAL_FACADE,
		BetaLayout.CENTRAL_INSIDE, [door, cracked_wall]
	)
	central.door_wall = door
	central.door_hole = Rect2(
		BetaLayout.CENTRAL_DOOR.position.x - central.position.x, -BetaLayout.FACADE_DOOR_HEIGHT - 8.0,
		BetaLayout.CENTRAL_DOOR.size.x, BetaLayout.FACADE_DOOR_HEIGHT
	)
	_add_facade(ART_FACADE_DEPOT, BetaLayout.DEPOT.end.y + 40.0, BetaLayout.DEPOT_FACADE, BetaLayout.DEPOT, [])


func _add_named(id: String, at: Vector2, label_key: String, is_reusable: bool) -> void:
	_add_item(id, Interactable.Kind.TERMINAL, at)
	var item: Interactable = items[id]
	item.custom_label = tr(label_key)
	item.reusable = is_reusable


func _add_mine(index: int) -> void:
	var mine: PetanqueMine = PetanqueMine.new()
	mine.setup("mine_%d" % index, BetaLayout.MINES[index], self)
	mine.exploded.connect(_on_mine_exploded)
	actors.add_child(mine)
	mines[mine.mine_id] = mine


func _register_convertibles() -> void:
	for enemy: Guard in guards():
		_add_convertible(_enemy_ids[enemy], enemy, "nanoacero")
	_add_convertible("drone_1", drone, "aleacion_magnetica")
	_add_convertible("camera_1", security_camera, "cristal_plasma")
	_add_convertible(ID_CRATE, items[ID_CRATE], "madera_cuantica")
	_add_convertible("crate_2", items["crate_2"], "madera_cuantica")


func _build_investigation() -> void:
	ai = AiChatter.new()
	ai.level = self
	add_child(ai)
	investigation = InvestigationDirector.new()
	investigation.level = self
	investigation.case_path = CASE_PATH
	add_child(investigation)
	_add_convertible(ID_CONTESTADOR, investigation.npc_nodes[ID_CONTESTADOR], "aleacion_magnetica")
	challenges = BetaChallenges.new()
	challenges.level = self
	if forced_hour >= 0:
		challenges.hour_source = func() -> int: return forced_hour
	add_child(challenges)
	rain = AcidRain.new()
	rain.player = player
	rain.rng = rng
	rain.shelters = BetaLayout.SHELTERS
	add_child(rain)
	protagonist = ProtagonistVoice.new()
	protagonist.level = self
	add_child(protagonist)
	atmosphere = BetaAtmosphere.new()
	atmosphere.player = player
	atmosphere.hour_source = challenges.hour_source
	add_child(atmosphere)
	live_world = LiveWorld.new()
	live_world.level = self
	add_child(live_world)


func _connect_systems() -> void:
	super()
	investigation.flags_changed.connect(challenges.apply_flags)
	rain.started.connect(_on_rain.bind(true))
	rain.ended.connect(_on_rain.bind(false))
	protagonist.connect_world()


func _connect_body() -> void:
	super()
	protagonist.connect_body(player.body)


func _show_game_over() -> void:
	super()
	overlay.add_line(protagonist.pick_line("death"))
	for chain: String in live_world.sim.chain_summaries(CHAINS_IN_SUMMARY):
		overlay.add_line(chain)


func _connect_enemies() -> void:
	for enemy: Guard in guards():
		noise_bus.noise_emitted.connect(enemy.hear)
		drone.alarm_raised.connect(enemy.investigate)
		security_camera.alarm_raised.connect(enemy.investigate)
		enemy.fell.connect(_on_enemy_fell)
		enemy.corpse_expired.connect(_on_corpse_expired)


func _build_interface() -> void:
	super()
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	_rain_label = _add_label(layer, "BETA_RAIN", Vector2(760.0, 150.0), 26)
	_rain_label.visible = false


func _id_of(enemy: Guard) -> String:
	return _enemy_ids[enemy]


func _on_enemy_fell(enemy: Guard) -> void:
	super(enemy)
	if enemy == ramon:
		challenges.on_ramon_fell()
	live_world.on_citizen_gone(_id_of(enemy))


func _on_converted(entity_id: String) -> void:
	super(entity_id)
	live_world.on_citizen_gone(entity_id)
	if entity_id == ID_RAMON:
		challenges.on_ramon_fell()


func _on_item_activated(item: Interactable) -> void:
	if live_world.handles_item(item):
		return
	match item.item_id:
		ID_MINE:
			challenges.take_mine()
		ID_CRACK:
			challenges.use_cracked_wall()
		ID_REEL:
			challenges.take_reel()
		ID_GENERATOR:
			challenges.break_generator()
		_:
			if item.kind == Interactable.Kind.CRATE:
				protagonist.comment("crate", ProtagonistVoice.LONG_COOLDOWN)
			super(item)


func _on_mine_exploded(mine: PetanqueMine) -> void:
	investigation.flags[mine.mine_id] = true
	mines.erase(mine.mine_id)


func _on_rain(is_raining: bool) -> void:
	_rain_label.visible = is_raining
	atmosphere.set_raining(is_raining)


func snapshot() -> Dictionary:
	var data: Dictionary = super()
	data["world"] = live_world.to_dict()
	return data


## Pone en escena a un habitante del mundo vivo. Admite nacimientos en plena partida.
func add_citizen(id: String, species: String, at: Vector2, home: Rect2) -> Guard:
	var color: Color = COLOR_JUBILADO if species == "jubilado" else COLOR_MOHOCRATA
	var roster: Array = _jubilados if species == "jubilado" else _mohocratas
	var route: Array[Vector2] = [at, at + Vector2(90.0, 0.0)]
	route[1] = route[1].clamp(home.position, home.end)
	var enemy: Guard = _add_guard(id, route, color, roster)
	enemy.set_passive(true)
	_add_convertible(id, enemy, "nanoacero")
	fight.track(enemy)
	enemy.fell.connect(_on_enemy_fell)
	enemy.corpse_expired.connect(_on_corpse_expired)
	return enemy


## Premio de una misión: una pieza de repuesto.
func reward_piece() -> void:
	_add_pickup([ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT])


func _begin_fresh() -> void:
	super()
	live_world.start({})
	SaveSystem.write(snapshot())


func _apply_save(data: Dictionary) -> bool:
	var result: bool = super(data)
	if result and not data["dead"]:
		live_world.start(data.get("world", {}))
	if result:
		for id: String in mines.keys():
			if investigation.has_flag(id):
				(mines[id] as PetanqueMine).queue_free()
				mines.erase(id)
	return result


func _valid(list: Array) -> Array[Guard]:
	var result: Array[Guard] = []
	for enemy: Variant in list:
		if is_instance_valid(enemy):
			result.append(enemy as Guard)
	return result
