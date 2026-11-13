class_name DespliegueCeroZone
extends ZoneBase
## Zona de la beta: bosque, ciudad perdida, dos bandos y cuatro retos.

const CASE_PATH: String = "res://data/investigation/case_beta.json"
const ID_MINE: String = "mina_suelta"
const ID_CRACK: String = "muro_agrietado"
const ID_REEL: String = "bobina"
const ID_GENERATOR: String = "generador"
const ID_RAMON: String = "ramon"
const ID_CONTESTADOR: String = "contestador"
const CHAINS_IN_SUMMARY: int = 3
const BURST_RADIUS: float = 170.0

## Las pruebas fijan aquí la hora para no depender del reloj real.
static var forced_hour: int = -1

var challenges: DespliegueCeroChallenges
var protagonist: ProtagonistVoice
var rain: AcidRain
var atmosphere: DespliegueCeroAtmosphere
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
var _rosters: Dictionary = {}
var _materials: Dictionary = {}
var _depot: Array[Guard] = []
var _contestador_at: Vector2 = Vector2.ZERO


func world_size() -> Vector2:
	return DespliegueCeroLayout.world_size


func zone_definition() -> ZoneDefinition:
	return DespliegueCeroLayout.zone


## La zona de despliegue cero trae su propia definición: no espera a que el
## gestor se la asigne antes de montarse.
func _definition() -> ZoneDefinition:
	return DespliegueCeroLayout.zone


func open_spots() -> Array[Vector2]:
	return DespliegueCeroLayout.open_spots


func floor_rect() -> Rect2:
	return DespliegueCeroLayout.floor_rect


func start_point() -> Vector2:
	return DespliegueCeroLayout.start


func wall_rects() -> Array[Rect2]:
	return DespliegueCeroLayout.walls


func low_cover_rects() -> Array[Rect2]:
	return DespliegueCeroLayout.low_covers


func door_rects() -> Array[Rect2]:
	return [DespliegueCeroLayout.central_door, DespliegueCeroLayout.cracked_wall]


func save_point_positions() -> Array[Vector2]:
	return DespliegueCeroLayout.save_points


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


func guards_of(species: String) -> Array[Guard]:
	return _valid(_rosters.get(species, []))


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
	nav.clear_rect(DespliegueCeroLayout.cracked_wall, Player.RADIUS, _all_blockers())


func _ready() -> void:
	super()
	challenges.apply_flags()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size()), COLOR_BACKGROUND)
	DespliegueCeroGround.paint(self)
	for index: int in range(DespliegueCeroLayout.outdoor_shelters):
		draw_texture_rect(PropArt.texture("toldo"), DespliegueCeroLayout.shelters[index], false)
	var goal: Vector2 = DespliegueCeroLayout.crossing_goal.get_center()
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
	cracked_wall = _add_wall(DespliegueCeroLayout.cracked_wall, SandboxLayout.WALL_FRONT_HEIGHT, Wall.Kind.DOOR)
	cracked_wall.label_key = "BETA_CRACKED_WALL"
	door.label_key = "BETA_CENTRAL_DOOR"


func _build_enemies() -> void:
	for species: String in DespliegueCeroLayout.zone.species():
		_rosters[species] = []
	for actor: Dictionary in DespliegueCeroLayout.zone.list("actors"):
		_spawn_actor(actor)
	drone = Drone.new()
	drone.target = player
	drone.setup(DespliegueCeroLayout.drone_patrol, ground)
	actors.add_child(drone)
	security_camera = SecurityCamera.new()
	security_camera.target = player
	security_camera.setup(
		DespliegueCeroLayout.camera_position,
		DespliegueCeroLayout.camera_center_degrees,
		DespliegueCeroLayout.camera_amplitude_degrees,
		ground
	)
	actors.add_child(security_camera)


func _spawn_actor(actor: Dictionary) -> void:
	var id: String = str(actor.get("id", ""))
	var route_key: String = str(actor.get("route", ""))
	if id.is_empty() or route_key.is_empty():
		push_error("%s: actor sin id o sin ruta: %s" % [DespliegueCeroLayout.PATH, actor])
		return
	var look: Dictionary = _look_of(actor)
	if look.is_empty():
		return
	if not DespliegueCeroLayout.zone.has(route_key):
		push_error("%s: el actor «%s» no tiene la ruta «%s»" % [
			DespliegueCeroLayout.PATH, id, route_key
		])
		return
	var route: Array[Vector2] = DespliegueCeroLayout.zone.points(route_key)
	if route.is_empty():
		push_error("%s: la ruta «%s» del actor «%s» está vacía" % [
			DespliegueCeroLayout.PATH, route_key, id
		])
		return
	var enemy: Guard = _add_guard(id, route, look, str(actor.get("weapon", "")))
	if actor.get("passive", false):
		enemy.set_passive(true)
	for role: String in actor.get("roles", []):
		match role:
			"guard":
				guard = enemy
			"shooter":
				shooter = enemy
			"strip_jubilado":
				strip_jubilado = enemy
			"strip_mohocrata":
				strip_mohocrata = enemy
			"ramon":
				ramon = enemy
			"depot":
				_depot.append(enemy)


func _look_of(actor: Dictionary) -> Dictionary:
	if actor.has("species"):
		return _species_look(str(actor["species"]))
	var progenitor: String = str(actor.get("progenitor", ""))
	if not ProgenitorCatalog.has(progenitor):
		push_error("%s: actor sin especie ni progenitor conocido: %s" % [
			DespliegueCeroLayout.PATH, actor
		])
		return {}
	var entry: Dictionary = ProgenitorCatalog.entry(progenitor)
	return {
		"species": "", "color": Color(str(entry["color"])), "art": entry["art"],
		"material": entry["material"], "deaths": entry["deaths"],
	}


func _species_look(species: String) -> Dictionary:
	return {
		"species": species, "color": SpeciesCatalog.color(species), "art": SpeciesCatalog.art(species),
		"material": SpeciesCatalog.material(species), "deaths": SpeciesCatalog.deaths(species),
	}


func _add_guard(id: String, route: Array[Vector2], look: Dictionary, weapon_id: String = "") -> Guard:
	var enemy: Guard = Guard.new()
	enemy.target = player
	enemy.nav = nav
	enemy.rng = rng
	enemy.visual.body_color = look["color"]
	enemy.visual.art_views = _load_views(str(look["art"]))
	enemy.visual.rig_folder = ART_FOLDER + "rig/" + str(look["art"])
	enemy.death = DeathCatalog.pick(look["deaths"], rng)
	if not weapon_id.is_empty():
		enemy.make_ranged(self, weapon_id)
	enemy.setup(route, ground)
	var species: String = str(look.get("species", ""))
	if not species.is_empty():
		enemy.detector.faction = species
		var roster: Array = _rosters.get(species, [])
		roster.append(enemy)
		_rosters[species] = roster
	actors.add_child(enemy)
	_enemy_ids[enemy] = id
	_materials[enemy] = look["material"]
	return enemy


func _build_items() -> void:
	for entry: Dictionary in DespliegueCeroLayout.zone.list("items"):
		_build_item(entry)
	for index: int in range(DespliegueCeroLayout.mines.size()):
		_add_mine(index)
	DespliegueCeroFacades.build(self)


func _build_item(entry: Dictionary) -> void:
	var id: String = entry["id"]
	var at: Vector2 = DespliegueCeroLayout.zone.point(str(entry["at"]))
	match str(entry["type"]):
		"named":
			_add_named(id, at, str(entry["label"]), bool(entry["reusable"]))
			if entry.has("art"):
				(items[id] as Interactable).art = load(str(entry["art"])) as Texture2D
		"crate":
			_add_item(id, Interactable.Kind.CRATE, at)
		"leg":
			_add_item(id, Interactable.Kind.PICKUP_LEG, at)
		"arm":
			_add_item(id, Interactable.Kind.PICKUP_ARM, at)
		_:
			push_error("%s: tipo de objeto desconocido en «%s»" % [DespliegueCeroLayout.PATH, id])


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
	mine.setup("mine_%d" % index, DespliegueCeroLayout.mines[index], self)
	mine.exploded.connect(_on_mine_exploded)
	actors.add_child(mine)
	mines[mine.mine_id] = mine


func _register_convertibles() -> void:
	for enemy: Guard in guards():
		_add_convertible(_enemy_ids[enemy], enemy, str(_materials.get(enemy, "")))
	for entry: Dictionary in DespliegueCeroLayout.zone.list("convertibles"):
		var node: Node2D = _convertible_node(entry)
		if node == null:
			continue
		_add_convertible(str(entry["id"]), node, str(entry["material"]))
	_fix_progenitor_property(ID_RAMON)
	for prop: Dictionary in DespliegueCeroLayout.zone.list("props"):
		_build_prop(prop)
	for id: String in mines:
		_add_convertible(id, mines[id], str(DespliegueCeroLayout.zone.data["mine_material"]))


func _convertible_node(entry: Dictionary) -> Node2D:
	match str(entry.get("node", "")):
		"drone":
			return drone
		"camera":
			return security_camera
	var node: Variant = items.get(str(entry["id"]))
	if node == null:
		push_error("%s: el convertible «%s» no tiene objeto" % [
			DespliegueCeroLayout.PATH, str(entry["id"])
		])
		return null
	return node as Node2D


func _build_prop(prop: Dictionary) -> void:
	var spots: Array[Vector2] = DespliegueCeroLayout.zone.points(str(prop["at"]))
	var size: Vector2 = Vector2(float(prop["size"][0]), float(prop["size"][1]))
	for index: int in range(spots.size()):
		var world_prop: WorldProp = WorldProp.new()
		world_prop.setup(str(prop["prop"]), spots[index], size)
		actors.add_child(world_prop)
		_add_convertible("%s_%d" % [prop["id_prefix"], index], world_prop, str(prop["material"]))


func _fix_progenitor_property(id: String) -> void:
	if not entities.has(id):
		push_error("%s: no hay entidad «%s» que arreglar" % [DespliegueCeroLayout.PATH, id])
		return
	var entry: Dictionary = ProgenitorCatalog.entry(id)
	for child: Node in (entities[id] as Node).get_children():
		if child is Convertible:
			(child as Convertible).fixed_property = str(entry["fixed_property"])


func _build_investigation() -> void:
	ai = AiChatter.new()
	ai.level = self
	add_child(ai)
	investigation = InvestigationDirector.new()
	investigation.level = self
	investigation.case_path = CASE_PATH
	add_child(investigation)
	var contestador: Dictionary = ProgenitorCatalog.entry(ID_CONTESTADOR)
	_add_convertible(ID_CONTESTADOR, investigation.npc_nodes[ID_CONTESTADOR], str(contestador["material"]))
	_contestador_at = (entities[ID_CONTESTADOR] as Node2D).global_position
	_fix_progenitor_property(ID_CONTESTADOR)
	_fix_progenitor_property(ID_CONTESTADOR)
	challenges = DespliegueCeroChallenges.new()
	challenges.level = self
	if forced_hour >= 0:
		challenges.hour_source = func() -> int: return forced_hour
	add_child(challenges)
	rain = AcidRain.new()
	rain.player = player
	rain.rng = rng
	rain.shelters = DespliegueCeroLayout.shelters
	add_child(rain)
	protagonist = ProtagonistVoice.new()
	protagonist.level = self
	add_child(protagonist)
	atmosphere = DespliegueCeroAtmosphere.new()
	atmosphere.player = player
	atmosphere.hour_source = challenges.hour_source
	add_child(atmosphere)
	var ambient: DespliegueCeroAmbient = DespliegueCeroAmbient.new()
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
	DespliegueCeroInterface.build(self)


## El bando que peor te ve; Conspi-Ranoia acierta solo a veces.
func least_friendly_species() -> String:
	var standing: Dictionary = live_world.sim.player_standing
	var sides: Array[String] = DespliegueCeroLayout.zone.species()
	var worst: bool = float(standing.get(sides[0], 0.0)) < float(standing.get(sides[1], 0.0))
	if rng.randf() < 0.35:
		worst = not worst
	return SpeciesCatalog.plural(sides[0] if worst else sides[1])


func id_of_guard(enemy: Guard) -> String:
	return str(_enemy_ids.get(enemy, ""))


func _id_of(enemy: Guard) -> String:
	return str(_enemy_ids.get(enemy, ""))


func _on_enemy_fell(enemy: Guard) -> void:
	super(enemy)
	if enemy == ramon:
		challenges.on_ramon_fell()


func _on_converted(entity_id: String) -> void:
	super(entity_id)
	mines.erase(entity_id)
	live_world.on_citizen_gone(entity_id)
	if entity_id == ID_RAMON:
		challenges.on_ramon_fell()
	if entity_id == ID_CONTESTADOR and _contestador_at != Vector2.ZERO:
		challenges.leave_footprint(DespliegueCeroChallenges.ID_CONTESTADOR_TRACE, _contestador_at, "BETA_TRACE_CONTESTADOR", "El Contestador")


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
	var route: Array[Vector2] = [at, at + Vector2(90.0, 0.0)]
	route[1] = route[1].clamp(home.position, home.end)
	var enemy: Guard = _add_guard(id, route, _species_look(species))
	enemy.set_passive(true)
	_add_convertible(id, enemy, str(_materials.get(enemy, "")))
	fight.track(enemy)
	# _on_enemy_fell avisa al mundo vivo, igual que en las zonas genéricas.
	enemy.fell.connect(_on_enemy_fell)
	enemy.corpse_expired.connect(_on_corpse_expired)
	enemy.attacked.connect(_on_citizen_attacked.bind(enemy, species))
	return enemy


## Viene de la conversación: selecciona a la persona y empieza a pegarle.
func attack_citizen(enemy: Guard) -> void:
	selection.select_exactly(enemy)
	combat.engage(enemy)


## Ataca al interlocutor de un diálogo de investigación, si tiene cuerpo en escena.
func attack_dialogue_speaker(speaker: String) -> void:
	if speaker == ID_RAMON and is_instance_valid(ramon) and not ramon.is_down():
		attack_citizen(ramon)
		return
	for enemy: Guard in guards():
		if not is_instance_valid(enemy) or enemy.is_down():
			continue
		if _enemy_ids.get(enemy, "") == speaker:
			attack_citizen(enemy)
			return
	if live_world != null and live_world.citizens.has(speaker):
		var citizen: Guard = live_world.citizens[speaker]
		if is_instance_valid(citizen) and not citizen.is_down():
			attack_citizen(citizen)


## Quienes están cerca y son de su especie se unen a la pelea.
func _on_citizen_attacked(victim: Guard, species: String) -> void:
	for id: String in live_world.citizens:
		var other: Guard = live_world.citizens[id]
		if other == victim or not is_instance_valid(other):
			continue
		var npc: NpcState = live_world.sim.npcs.get(id) as NpcState
		if npc == null or npc.species != species:
			continue
		if battles != null and battles.is_fighter(id):
			continue
		if other.global_position.distance_to(victim.global_position) <= GROUP_REACT_RADIUS:
			other.join_fight()


## Premio de una misión: una pieza de repuesto.
func reward_piece() -> void:
	_add_pickup([ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT])


func _begin_fresh() -> void:
	super()
	if not world_mode:
		SaveSystem.write(snapshot())


func _apply_save(data: Dictionary) -> bool:
	var result: bool = super(data)
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
