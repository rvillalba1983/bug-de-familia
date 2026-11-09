class_name Sandbox
extends Node2D
## Escena del primer reto, con gráficos sencillos y vista alta inclinada.

const COLOR_BACKGROUND: Color = Color("#1d1b26")
const COLOR_FLOOR: Color = Color("#3b4a3a")
const COLOR_GOAL: Color = Color(0.3, 1.0, 0.5, 0.35)
const SAVED_NOTICE_TIME: float = 2.5
const NOTICE_TIME: float = 7.0
const ID_CRATE: String = "crate_1"
const ID_TERMINAL: String = "terminal_1"
const ID_PICKUP_LEG: String = "pickup_leg_1"
const ID_PICKUP_ARM: String = "pickup_arm_1"
const ID_GUARD: String = "guard_1"
const ID_DRONE: String = "drone_1"
const ID_SHOOTER: String = "shooter_1"
const ID_CAMERA: String = "camera_1"

## El menú inicial solo aparece al abrir el juego.
static var session_started: bool = false
## Las pruebas fijan aquí la semilla para que sean reproducibles.
static var forced_seed: int = -1

var player: Player
var nav: NavGrid
var pause: TacticalPause
var selection: SelectionSystem
var noise_bus: NoiseBus
var fight: FightDirector
var panel: BodyPanel
var actors: Node2D
var ground: Node2D
var walls: Array[Wall] = []
var door: Wall
var guard: Guard
var shooter: Guard
var combat: CombatSystem
var drone: Drone
var security_camera: SecurityCamera
var items: Dictionary = {}
var save_points: Array[SavePoint] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var challenge_done: bool = false
var overlay: MessageScreen
var catalog: ConversionCatalog
var conversion: ConversionDirector
var actions: ActionSystem
var entities: Dictionary = {}
var converted_ids: Array = []
var fallen_ids: Array = []
var action_bar: ActionBar
var ai: AiChatter
var investigation: InvestigationDirector
## Si la sesión ha continuado una partida ya empezada.
var resumed: bool = false

var _pause_label: Label
var _done_label: Label
var _saved_label: Label
var _saved_time: float = 0.0
var _notice_label: Label
var _notice_time: float = 0.0


func _ready() -> void:
	InputBindings.install()
	_build_world()
	_build_interface()
	_connect_systems()
	_start_session()
	session_started = true


func _physics_process(_delta: float) -> void:
	var feet: Vector2 = player.global_position
	for wall: Wall in walls:
		wall.update_occlusion(feet, player.current_height())
	player.in_danger = fight.phase != FightDirector.Phase.CALM
	if fight.phase == FightDirector.Phase.CALM and not player.body.is_dead:
		for point: SavePoint in save_points:
			point.track(feet)
	_check_goal(feet)


func _process(delta: float) -> void:
	if _saved_time > 0.0:
		_saved_time -= delta
		_saved_label.visible = _saved_time > 0.0
	if _notice_time > 0.0:
		_notice_time -= delta
		_notice_label.visible = _notice_time > 0.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_to"):
		var point: Vector2 = get_global_mouse_position()
		var enemy: Guard = _enemy_at(point)
		if enemy != null:
			combat.engage(enemy)
			return
		combat.disengage()
		player.set_path(nav.find_path(player.global_position, point))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size()), COLOR_BACKGROUND)
	draw_rect(floor_rect(), COLOR_FLOOR)
	draw_rect(SandboxLayout.GOAL, COLOR_GOAL)
	var goal_top: Vector2 = SandboxLayout.GOAL.get_center() - Vector2(0.0, 8.0)
	WorldLabel.draw_on(self, tr("ITEM_GOAL"), goal_top)


## Para pruebas de sistemas que no necesitan enemigos.
func set_enemies_active(active: bool) -> void:
	var mode: ProcessMode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
	for enemy: Node in [guard, shooter, drone, security_camera]:
		if is_instance_valid(enemy):
			enemy.process_mode = mode


## Enemigos que pueden pelear o seguir en el suelo.
func guards() -> Array[Guard]:
	var result: Array[Guard] = []
	for enemy: Variant in [guard, shooter]:
		if is_instance_valid(enemy):
			result.append(enemy as Guard)
	return result


func spawn_tracer(from: Vector2, to: Vector2, color: Color) -> void:
	var tracer: Tracer = Tracer.new()
	tracer.setup(from, to, color)
	ground.add_child(tracer)


## Geometría del nivel. Cada zona la sustituye por la suya.
func world_size() -> Vector2:
	return Vector2(1920.0, 1080.0)


func floor_rect() -> Rect2:
	return SandboxLayout.FLOOR_RECT


func start_point() -> Vector2:
	return SandboxLayout.PLAYER_START


func wall_rects() -> Array[Rect2]:
	return SandboxLayout.WALLS


func low_cover_rects() -> Array[Rect2]:
	return SandboxLayout.LOW_COVERS


func door_rects() -> Array[Rect2]:
	return [SandboxLayout.DOOR]


func save_point_positions() -> Array[Vector2]:
	return SandboxLayout.SAVE_POINTS


func snapshot() -> Dictionary:
	var used: Array = []
	for id: String in items:
		if (items[id] as Interactable).used:
			used.append(id)
	return {
		"dead": player.body.is_dead,
		"seed": rng.seed,
		"body": player.body.to_dict(),
		"player": {"x": player.global_position.x, "y": player.global_position.y},
		"used": used,
		"converted": converted_ids,
		"fallen": fallen_ids,
		"door_open": door.is_open,
		"ai": ai.team.to_dict(),
		"case": investigation.to_dict(),
		"challenge_done": challenge_done,
	}


## Aviso breve de algo importante que ha pasado en el mundo.
func show_notice(text: String) -> void:
	_notice_label.text = text
	_notice_label.visible = true
	_notice_time = NOTICE_TIME


func autosave() -> void:
	if not player.body.is_dead and SaveSystem.write(snapshot()):
		_saved_time = SAVED_NOTICE_TIME
		_saved_label.visible = true


func start_new_game() -> void:
	var fresh_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	fresh_rng.randomize()
	var seed_value: int = fresh_rng.seed if forced_seed < 0 else forced_seed
	var data: Dictionary = {
		"dead": false,
		"seed": seed_value,
		"body": default_body().to_dict(),
		"player": {"x": start_point().x, "y": start_point().y},
		"used": [],
		"converted": [],
		"fallen": [],
		"door_open": false,
		"ai": {},
		"case": {},
		"challenge_done": false,
			"world": {},
	}
	SaveSystem.write(data)
	session_started = true
	get_tree().paused = false
	get_tree().reload_current_scene()


static func default_body() -> ModularBody:
	var body: ModularBody = ModularBody.new()
	for slot: ModularBody.Slot in [
		ModularBody.Slot.HEAD,
		ModularBody.Slot.LEG_LEFT,
		ModularBody.Slot.LEG_RIGHT,
		ModularBody.Slot.ARM_MAIN_LEFT,
		ModularBody.Slot.ARM_MAIN_RIGHT,
	]:
		var spare: BodyPiece = BodyPiece.new(ModularBody.kind_of(slot))
		spare.pick_visual_variant("repuesto_%d" % slot)
		body.add_spare(slot, spare)
	return body


func _build_world() -> void:
	ground = Node2D.new()
	add_child(ground)
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	_build_walls()
	_build_boundaries()
	var blockers: Array[Rect2] = _all_blockers()
	blockers.append_array(door_rects())
	nav = NavGrid.new(floor_rect(), blockers, Player.RADIUS)
	noise_bus = NoiseBus.new()
	noise_bus.ground = ground
	add_child(noise_bus)
	_build_player()
	_build_enemies()
	_build_items()
	_build_save_points()
	pause = TacticalPause.new()
	add_child(pause)
	selection = SelectionSystem.new()
	add_child(selection)
	fight = FightDirector.new()
	fight.body = player.body
	for enemy: Guard in guards():
		fight.track(enemy)
	add_child(fight)
	combat = CombatSystem.new()
	combat.level = self
	add_child(combat)
	_register_convertibles()
	catalog = ConversionCatalog.load_default()
	_build_investigation()
	actions = ActionSystem.new()
	actions.level = self
	add_child(actions)


func _build_investigation() -> void:
	ai = AiChatter.new()
	ai.level = self
	add_child(ai)
	investigation = InvestigationDirector.new()
	investigation.level = self
	add_child(investigation)


func _add_convertible(id: String, owner_node: Node2D, material: String) -> void:
	var convertible: Convertible = Convertible.new()
	convertible.setup(id, material)
	owner_node.add_child(convertible)
	entities[id] = owner_node


func _register_convertibles() -> void:
	_add_convertible(ID_GUARD, guard, "nanoacero")
	_add_convertible(ID_SHOOTER, shooter, "nanoacero")
	_add_convertible(ID_DRONE, drone, "aleacion_magnetica")
	_add_convertible(ID_CAMERA, security_camera, "cristal_plasma")
	_add_convertible(ID_CRATE, items[ID_CRATE], "madera_cuantica")
	_add_convertible(ID_TERMINAL, items[ID_TERMINAL], "aleacion_magnetica")


func _remove_entity(id: String) -> void:
	if not entities.has(id):
		return
	var node: Node = entities[id]
	entities.erase(id)
	items.erase(id)
	node.queue_free()


func _all_blockers() -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append_array(wall_rects())
	result.append_array(low_cover_rects())
	return result


func _add_wall(rect: Rect2, height: float, kind: Wall.Kind) -> Wall:
	var wall: Wall = Wall.new()
	wall.setup(rect, height, kind)
	actors.add_child(wall)
	if kind != Wall.Kind.LOW:
		walls.append(wall)
	return wall


func _build_walls() -> void:
	var tall: float = SandboxLayout.WALL_FRONT_HEIGHT
	for rect: Rect2 in wall_rects():
		_add_wall(rect, tall, Wall.Kind.SOLID)
	for rect: Rect2 in low_cover_rects():
		_add_wall(rect, SandboxLayout.LOW_FRONT_HEIGHT, Wall.Kind.LOW)
	door = _add_wall(door_rects()[0], tall, Wall.Kind.DOOR)
	door.label_key = "ITEM_DOOR"


func _build_boundaries() -> void:
	var area: Rect2 = floor_rect()
	var t: float = 64.0
	var sides: Array[Rect2] = [
		Rect2(area.position.x - t, area.position.y - t, area.size.x + t * 2.0, t),
		Rect2(area.position.x - t, area.end.y, area.size.x + t * 2.0, t),
		Rect2(area.position.x - t, area.position.y, t, area.size.y),
		Rect2(area.end.x, area.position.y, t, area.size.y),
	]
	for side: Rect2 in sides:
		var body: StaticBody2D = StaticBody2D.new()
		body.collision_layer = PhysicsLayers.WALLS
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = side.size
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = shape
		collider.position = side.get_center()
		body.add_child(collider)
		add_child(body)


func _build_player() -> void:
	player = Player.new()
	player.position = start_point()
	player.noise_bus = noise_bus
	actors.add_child(player)
	var camera: CameraZoom = CameraZoom.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = int(world_size().x)
	camera.limit_bottom = int(world_size().y)
	player.add_child(camera)


func _build_enemies() -> void:
	guard = Guard.new()
	guard.target = player
	guard.nav = nav
	guard.rng = rng
	guard.setup(SandboxLayout.GUARD_PATROL, ground)
	actors.add_child(guard)
	shooter = Guard.new()
	shooter.target = player
	shooter.nav = nav
	shooter.rng = rng
	shooter.make_ranged(self)
	shooter.setup(SandboxLayout.SHOOTER_PATROL, ground)
	actors.add_child(shooter)
	drone = Drone.new()
	drone.target = player
	drone.setup(SandboxLayout.DRONE_PATROL, ground)
	actors.add_child(drone)
	security_camera = SecurityCamera.new()
	security_camera.target = player
	security_camera.setup(
		SandboxLayout.CAMERA_POSITION,
		SandboxLayout.CAMERA_CENTER_DEGREES,
		SandboxLayout.CAMERA_AMPLITUDE_DEGREES,
		ground
	)
	actors.add_child(security_camera)


func _add_item(id: String, kind: Interactable.Kind, at: Vector2) -> void:
	var item: Interactable = Interactable.new()
	item.setup(id, kind, at)
	item.activated.connect(_on_item_activated)
	actors.add_child(item)
	items[id] = item


func _build_items() -> void:
	_add_item(ID_CRATE, Interactable.Kind.CRATE, SandboxLayout.CRATE)
	_add_item(ID_TERMINAL, Interactable.Kind.TERMINAL, SandboxLayout.TERMINAL)
	_add_item(ID_PICKUP_LEG, Interactable.Kind.PICKUP_LEG, SandboxLayout.PICKUP_LEG)
	_add_item(ID_PICKUP_ARM, Interactable.Kind.PICKUP_ARM, SandboxLayout.PICKUP_ARM)


func _build_save_points() -> void:
	for at: Vector2 in save_point_positions():
		var point: SavePoint = SavePoint.new()
		point.position = at
		point.entered.connect(autosave)
		ground.add_child(point)
		save_points.append(point)


func _build_interface() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 2
	add_child(layer)
	_pause_label = _add_label(layer, "UI_PAUSE", Vector2(860.0, 24.0), 32)
	_pause_label.visible = false
	_done_label = _add_label(layer, "UI_CHALLENGE_DONE", Vector2(820.0, 70.0), 32)
	_done_label.visible = false
	_saved_label = _add_label(layer, "UI_SAVED", Vector2(860.0, 980.0), 26)
	_saved_label.visible = false
	_notice_label = _add_label(layer, "UI_SAVED", Vector2(420.0, 110.0), 26)
	_notice_label.visible = false
	_notice_label.process_mode = Node.PROCESS_MODE_ALWAYS
	if _shows_help_labels():
		_add_label(layer, "UI_SANDBOX_HELP", Vector2(24.0, 1040.0), 20)
		_add_label(layer, _objective_key(), Vector2(24.0, 16.0), 22)
	var hud: BodyHud = BodyHud.new()
	hud.body = player.body
	layer.add_child(hud)
	action_bar = ActionBar.new()
	layer.add_child(action_bar)
	action_bar.body = player.body
	if _shows_help_labels():
		_add_label(layer, "UI_SANDBOX_HELP2", Vector2(1560.0, 1040.0), 20)
	var conversion_hint: Label = _add_label(layer, "UI_CONVERT_NONE", Vector2(620.0, 70.0), 24)
	conversion_hint.visible = false
	var screen: ConversionScreen = ConversionScreen.new()
	add_child(screen)
	conversion = ConversionDirector.new()
	conversion.catalog = catalog
	conversion.player = player
	conversion.rng = rng
	conversion.screen = screen
	conversion.hint = conversion_hint
	panel = BodyPanel.new()
	panel.body = player.body
	panel.pause = pause
	add_child(panel)


func _add_label(layer: CanvasLayer, key: String, at: Vector2, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = tr(key)
	label.position = at
	label.add_theme_font_size_override(&"font_size", font_size)
	layer.add_child(label)
	return label


func _connect_systems() -> void:
	pause.paused_changed.connect(_on_paused_changed)
	_connect_enemies()
	fight.pre_fight_started.connect(_on_pre_fight_started)
	fight.fight_ended.connect(autosave)
	panel.closed.connect(_on_panel_closed)
	conversion.pause = pause
	add_child(conversion)
	conversion.converted.connect(_on_converted)
	conversion.answered.connect(ai.on_answered)
	conversion.all_wrong.connect(ai.on_all_wrong)
	conversion.advisor = ai.question_advice
	conversion.perks = ai.perks
	conversion.material_hinter = ai.material_hint
	conversion.taunter = ai.question_taunt
	panel.discarded.connect(ai.on_piece_discarded)
	fight.pre_fight_started.connect(ai.say.bind("fight"))
	actions.door_hacked.connect(_open_door)
	_connect_body()


func _connect_enemies() -> void:
	for enemy: Guard in guards():
		noise_bus.noise_emitted.connect(enemy.hear)
		drone.alarm_raised.connect(enemy.investigate)
		security_camera.alarm_raised.connect(enemy.investigate)
		enemy.fell.connect(_on_enemy_fell)
		enemy.corpse_expired.connect(_on_corpse_expired)


func _shows_help_labels() -> bool:
	return true


func _objective_key() -> String:
	return "UI_OBJECTIVE"


func _check_goal(feet: Vector2) -> void:
	if not challenge_done and SandboxLayout.GOAL.has_point(feet):
		_complete_challenge()


func _connect_body() -> void:
	player.body.piece_destroyed.connect(_on_piece_destroyed)
	player.body.died.connect(_on_player_died)
	player.body.piece_destroyed.connect(ai.on_piece_destroyed)
	player.body.changed.connect(ai.check_low_pieces)


func _start_session() -> void:
	var loaded: Dictionary = SaveSystem.read()
	if loaded["status"] == SaveSystem.Status.CORRUPT:
		SaveSystem.set_aside_corrupt()
	if loaded["status"] != SaveSystem.Status.OK:
		_begin_fresh()
		return
	var data: Dictionary = loaded["data"]
	if data["dead"]:
		_apply_save(data)
		_show_game_over()
		return
	if not _apply_save(data):
		SaveSystem.set_aside_corrupt()
		_begin_fresh()
		return
	resumed = not (data.get("case", {}) as Dictionary).is_empty()
	if not session_started:
		_show_start_menu()


func _begin_fresh() -> void:
	rng.seed = randi() if forced_seed < 0 else forced_seed
	_replace_body(default_body())
	ai.restore({})
	investigation.restore({})
	SaveSystem.write(snapshot())


func _apply_save(data: Dictionary) -> bool:
	var loaded_body: ModularBody = ModularBody.from_dict(data["body"])
	if data["dead"]:
		return true
	if loaded_body == null:
		return false
	_replace_body(loaded_body)
	rng.seed = int(data.get("seed", 0))
	var at: Dictionary = data.get("player", {})
	player.global_position = Vector2(
		float(at.get("x", start_point().x)),
		float(at.get("y", start_point().y))
	)
	for id: Variant in data.get("used", []):
		if items.has(id):
			(items[id] as Interactable).mark_used()
			if id == ID_TERMINAL:
				_open_door()
	for id: Variant in data.get("converted", []):
		converted_ids.append(id)
		_remove_entity(str(id))
	for id: Variant in data.get("fallen", []):
		fallen_ids.append(id)
		_remove_entity(str(id))
	if data.get("door_open", false):
		_open_door()
	ai.restore(data.get("ai", {}))
	investigation.restore(data.get("case", {}))
	if data.get("challenge_done", false):
		challenge_done = true
		_done_label.visible = true
	return true


func _replace_body(new_body: ModularBody) -> void:
	player.body = new_body
	fight.body = new_body
	panel.body = new_body
	action_bar.body = new_body
	_connect_body()
	var hud_parent: Node = _pause_label.get_parent()
	for child: Node in hud_parent.get_children():
		if child is BodyHud:
			(child as BodyHud).body = new_body
			new_body.changed.connect((child as BodyHud).queue_redraw)
			(child as BodyHud).queue_redraw()


func _show_start_menu() -> void:
	pause.begin_modal()
	overlay = MessageScreen.new()
	var entries: Array = [
		["UI_MENU_CONTINUE", _continue_game],
		["UI_MENU_NEW", start_new_game],
	]
	overlay.setup("UI_MENU_TITLE", entries)
	add_child(overlay)


func _show_game_over() -> void:
	pause.begin_modal()
	overlay = MessageScreen.new()
	overlay.setup("UI_GAME_OVER", [["UI_MENU_NEW", start_new_game]])
	add_child(overlay)


func _continue_game() -> void:
	overlay.queue_free()
	overlay = null
	pause.end_modal()


func _open_door() -> void:
	door.set_open(true)
	nav.clear_rect(door_rects()[0], Player.RADIUS, _all_blockers())


func _complete_challenge() -> void:
	challenge_done = true
	_done_label.visible = true
	autosave()


func _add_pickup(slots: Array[ModularBody.Slot]) -> void:
	for slot: ModularBody.Slot in slots:
		var found: BodyPiece = BodyPiece.new(ModularBody.kind_of(slot))
		found.pick_visual_variant("hallada_%d_%d" % [slot, player.body.spares(slot).size()])
		if player.body.add_spare(slot, found):
			return


func _on_item_activated(item: Interactable) -> void:
	match item.kind:
		Interactable.Kind.NPC:
			investigation.open_dialogue(item.item_id)
		Interactable.Kind.EVIDENCE:
			investigation.examine(item.item_id)
		Interactable.Kind.CRATE:
			noise_bus.emit_noise(item.global_position, SandboxLayout.CRATE_NOISE_RADIUS)
		Interactable.Kind.TERMINAL:
			_open_door()
		Interactable.Kind.PICKUP_LEG, Interactable.Kind.PICKUP_ARM:
			_add_pickup(item.pickup_slots())


func _on_converted(entity_id: String) -> void:
	converted_ids.append(entity_id)
	_remove_entity(entity_id)
	if fight.phase == FightDirector.Phase.CALM:
		autosave()


func _enemy_at(point: Vector2) -> Guard:
	for enemy: Guard in guards():
		if not enemy.is_down() and enemy.global_position.distance_to(point) <= Selectable.RADIUS * 1.5:
			return enemy
		if not enemy.is_down():
			var body_center: Vector2 = enemy.global_position - Vector2(0.0, Guard.BODY_HEIGHT * 0.5)
			if body_center.distance_to(point) <= Selectable.RADIUS * 1.5:
				return enemy
	return null


func _id_of(enemy: Guard) -> String:
	return ID_GUARD if enemy == guard else ID_SHOOTER


## La muerte es permanente: el caído no reaparece aunque se recargue la partida.
func _on_enemy_fell(enemy: Guard) -> void:
	fallen_ids.append(_id_of(enemy))


func _on_corpse_expired(enemy: Guard) -> void:
	_remove_entity(_id_of(enemy))


func _on_paused_changed(is_paused: bool) -> void:
	_pause_label.visible = is_paused


func _on_pre_fight_started() -> void:
	panel.open(BodyPanel.Mode.PRE_FIGHT)


func _on_panel_closed(mode: BodyPanel.Mode) -> void:
	if mode == BodyPanel.Mode.PRE_FIGHT:
		fight.confirm_pre_fight()


func _on_piece_destroyed(_slot: ModularBody.Slot) -> void:
	panel.open(BodyPanel.Mode.REPLACE)


func _on_player_died() -> void:
	panel.close()
	SaveSystem.mark_dead()
	_show_game_over()
