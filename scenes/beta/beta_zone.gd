class_name BetaZone
extends Sandbox
## Zona de la beta: bosque, ciudad perdida, dos bandos y cuatro retos.

## Provisional: distancia a la que un grupo se mete en la pelea de los suyos.
const GROUP_REACT_RADIUS: float = 250.0
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
const ART_REEL: String = "res://art/beta/bobina.svg"
const COLOR_JUBILADO: Color = Color("#a0a8b8")
const COLOR_MOHOCRATA: Color = Color("#8fbf60")
const COLOR_RAMON: Color = Color("#e0a040")
const CHAINS_IN_SUMMARY: int = 3
const BURST_RADIUS: float = 170.0

## Las pruebas fijan aquí la hora para no depender del reloj real.
static var forced_hour: int = -1

var challenges: BetaChallenges
var protagonist: ProtagonistVoice
var rain: AcidRain
var atmosphere: BetaAtmosphere
var live_world: LiveWorld
var battles: BattleDirector
var music: MusicDirector
var screen_filter: ScreenFilter
var rain_label: Label
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
var _contestador_at: Vector2 = Vector2.ZERO


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
	open_door()


func open_cracked_wall() -> void:
	cracked_wall.set_open(true)
	nav.clear_rect(BetaLayout.CRACKED_WALL, Player.RADIUS, _all_blockers())


func _ready() -> void:
	super()
	challenges.apply_flags()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size()), COLOR_BACKGROUND)
	BetaGround.paint(self)
	for index: int in range(BetaLayout.OUTDOOR_SHELTERS):
		draw_texture_rect(PropArt.texture("toldo"), BetaLayout.SHELTERS[index], false)
	var goal: Vector2 = BetaLayout.CROSSING_GOAL.get_center()
	draw_texture_rect(PropArt.texture("mirador"), Rect2(goal - Vector2(110.0, 90.0), Vector2(220.0, 180.0)), false)


func _physics_process(delta: float) -> void:
	super(delta)
	player.body.is_night = atmosphere.is_night()


func _shows_help_labels() -> bool:
	return false


func objective_key() -> String:
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


func _material_of(enemy: Guard) -> String:
	return "bioceramica" if enemy.visual.body_color == COLOR_MOHOCRATA else "nanoacero"


func _add_guard(
	id: String, route: Array[Vector2], color: Color, roster: Array, is_ranged: bool = false
) -> Guard:
	var enemy: Guard = Guard.new()
	enemy.target = player
	enemy.nav = nav
	enemy.rng = rng
	enemy.visual.body_color = color
	enemy.visual.art_views = _load_views(_art_base(id, color))
	enemy.visual.rig_folder = ART_FOLDER + "rig/" + _art_base(id, color)
	if is_ranged:
		enemy.make_ranged(self)
	enemy.setup(route, ground)
	if color != COLOR_RAMON:
		enemy.detector.faction = "jubilado" if color == COLOR_JUBILADO else "mohocrata"
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
	BetaFacades.build(self)


func _art_base(id: String, color: Color) -> String:
	if id == ID_RAMON:
		return ART_RAMON
	return ART_JUBILADO if color == COLOR_JUBILADO else ART_MOHOCRATA


func _load_views(base: String) -> Array[Texture2D]:
	var views: Array[Texture2D] = []
	for suffix: String in ["", "_e", "_n"]:
		views.append(load(ART_FOLDER + base + suffix + ".svg") as Texture2D)
	return views


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
		_add_convertible(_enemy_ids[enemy], enemy, _material_of(enemy))
	_add_convertible("drone_1", drone, "aleacion_magnetica")
	_add_convertible("camera_1", security_camera, "cristal_plasma")
	_add_convertible(ID_CRATE, items[ID_CRATE], "madera_cuantica")
	_add_convertible("crate_2", items["crate_2"], "madera_cuantica")
	(entities[ID_RAMON] as Node).get_children().filter(func(n: Node) -> bool: return n is Convertible)[0].fixed_property = "p047"
	for index: int in range(BetaLayout.ANTENNAS.size()):
		var antenna: WorldProp = WorldProp.new()
		antenna.setup("antena", BetaLayout.ANTENNAS[index], Vector2(70.0, 130.0))
		actors.add_child(antenna)
		_add_convertible("antena_%d" % index, antenna, "fibra_fotonica")
	for id: String in mines:
		_add_convertible(id, mines[id], "antimateria")


func _build_investigation() -> void:
	ai = AiChatter.new()
	ai.level = self
	add_child(ai)
	investigation = InvestigationDirector.new()
	investigation.level = self
	investigation.case_path = CASE_PATH
	add_child(investigation)
	_add_convertible(ID_CONTESTADOR, investigation.npc_nodes[ID_CONTESTADOR], "gel_memoria")
	_contestador_at = (entities[ID_CONTESTADOR] as Node2D).global_position
	(entities[ID_CONTESTADOR] as Node).get_children().filter(func(n: Node) -> bool: return n is Convertible)[0].fixed_property = "p049"
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
	var ambient: BetaAmbient = BetaAmbient.new()
	ambient.follow = player
	actors.add_child(ambient)
	live_world = LiveWorld.new()
	live_world.level = self
	add_child(live_world)
	music = MusicDirector.new()
	music.level = self
	add_child(music)
	battles = BattleDirector.new()
	battles.level = self
	add_child(battles)


func _connect_systems() -> void:
	super()
	investigation.flags_changed.connect(challenges.apply_flags)
	rain.warning.connect(ai.warn_rain)
	rain.started.connect(_on_rain.bind(true))
	rain.ended.connect(_on_rain.bind(false))
	protagonist.connect_world()


func _connect_body() -> void:
	super()
	protagonist.connect_body(player.body)
	player.body.piece_burst.connect(_on_piece_burst)


func _show_game_over() -> void:
	super()
	overlay.add_line(protagonist.pick_line("death"))
	for chain: String in live_world.sim.chain_summaries(CHAINS_IN_SUMMARY):
		overlay.add_line(chain)


func _build_interface() -> void:
	super()
	BetaInterface.build(self)


## El bando que peor te ve; Conspi-Ranoia acierta solo a veces.
func least_friendly_species() -> String:
	var standing: Dictionary = live_world.sim.player_standing
	var worst: bool = float(standing.get("jubilado", 0.0)) < float(standing.get("mohocrata", 0.0))
	if rng.randf() < 0.35:
		worst = not worst
	return "Jubilados" if worst else "Mohócratas"


func id_of_guard(enemy: Guard) -> String:
	return _enemy_ids[enemy]


func _id_of(enemy: Guard) -> String:
	return _enemy_ids[enemy]


func _on_enemy_fell(enemy: Guard) -> void:
	super(enemy)
	if enemy == ramon:
		challenges.on_ramon_fell()
	live_world.on_citizen_gone(_id_of(enemy))


func _on_converted(entity_id: String) -> void:
	super(entity_id)
	mines.erase(entity_id)
	live_world.on_citizen_gone(entity_id)
	if entity_id == ID_RAMON:
		challenges.on_ramon_fell()
	if entity_id == ID_CONTESTADOR and _contestador_at != Vector2.ZERO:
		challenges.leave_footprint(BetaChallenges.ID_CONTESTADOR_TRACE, _contestador_at, "BETA_TRACE_CONTESTADOR", "El Contestador")


func on_item_activated(item: Interactable) -> void:
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
	entities.erase(mine.mine_id)


## Metralla y explosiones de piezas al romperse.
func _on_piece_burst(effects: Dictionary) -> void:
	if effects.has("burst_noise"):
		noise_bus.emit_noise(player.global_position, float(effects["burst_noise"]))
	if effects.has("burst_stun"):
		for enemy: Guard in guards():
			if not enemy.is_down() and enemy.global_position.distance_to(player.global_position) <= BURST_RADIUS:
				enemy.stun(float(effects["burst_stun"]))


func _on_rain(is_raining: bool) -> void:
	rain_label.visible = is_raining
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
	_add_convertible(id, enemy, _material_of(enemy))
	fight.track(enemy)
	enemy.fell.connect(_on_enemy_fell)
	enemy.corpse_expired.connect(_on_corpse_expired)
	enemy.attacked.connect(_on_citizen_attacked.bind(enemy, species))
	return enemy


## Viene de la conversación: selecciona a la persona y empieza a pegarle.
func attack_citizen(enemy: Guard) -> void:
	selection.select_exactly(enemy)
	combat.engage(enemy)


## Quienes están cerca y son de su especie se unen a la pelea.
func _on_citizen_attacked(victim: Guard, species: String) -> void:
	for id: String in live_world.citizens:
		var other: Guard = live_world.citizens[id]
		if other == victim or not is_instance_valid(other):
			continue
		if (live_world.sim.npcs[id] as NpcState).species != species or battles.is_fighter(id):
			continue
		if other.global_position.distance_to(victim.global_position) <= GROUP_REACT_RADIUS:
			other.join_fight()


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
			if investigation.has_flag(id) or converted_ids.has(id):
				(mines[id] as PetanqueMine).queue_free()
				mines.erase(id)
	return result


func _valid(list: Array) -> Array[Guard]:
	var result: Array[Guard] = []
	for enemy: Variant in list:
		if is_instance_valid(enemy):
			result.append(enemy as Guard)
	return result
