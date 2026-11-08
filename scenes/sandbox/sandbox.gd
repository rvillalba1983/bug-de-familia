class_name Sandbox
extends Node2D
## Escena del primer reto, con gráficos sencillos y vista alta inclinada.

const COLOR_BACKGROUND: Color = Color("#1d1b26")
const COLOR_FLOOR: Color = Color("#3b4a3a")
const COLOR_GOAL: Color = Color(0.3, 1.0, 0.5, 0.35)
const ID_CRATE: String = "crate_1"
const ID_TERMINAL: String = "terminal_1"
const ID_PICKUP_LEG: String = "pickup_leg_1"
const ID_PICKUP_ARM: String = "pickup_arm_1"

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
var drone: Drone
var security_camera: SecurityCamera
var items: Dictionary = {}
var save_points: Array[SavePoint] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var challenge_done: bool = false
var overlay: MessageScreen

var _pause_label: Label
var _done_label: Label


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
	if fight.phase == FightDirector.Phase.CALM and not player.body.is_dead:
		for point: SavePoint in save_points:
			point.track(feet)
	if not challenge_done and SandboxLayout.GOAL.has_point(feet):
		_complete_challenge()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"move_to"):
		player.set_path(nav.find_path(player.global_position, get_global_mouse_position()))


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1920.0, 1080.0)), COLOR_BACKGROUND)
	draw_rect(SandboxLayout.FLOOR_RECT, COLOR_FLOOR)
	draw_rect(SandboxLayout.GOAL, COLOR_GOAL)


## Para pruebas de sistemas que no necesitan enemigos.
func set_enemies_active(active: bool) -> void:
	var mode: ProcessMode = PROCESS_MODE_INHERIT if active else PROCESS_MODE_DISABLED
	guard.process_mode = mode
	drone.process_mode = mode
	security_camera.process_mode = mode


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
		"challenge_done": challenge_done,
	}


func autosave() -> void:
	if not player.body.is_dead:
		SaveSystem.write(snapshot())


func start_new_game() -> void:
	var fresh_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	fresh_rng.randomize()
	var seed_value: int = fresh_rng.seed if forced_seed < 0 else forced_seed
	var data: Dictionary = {
		"dead": false,
		"seed": seed_value,
		"body": default_body().to_dict(),
		"player": {"x": SandboxLayout.PLAYER_START.x, "y": SandboxLayout.PLAYER_START.y},
		"used": [],
		"challenge_done": false,
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
		body.add_spare(slot, BodyPiece.new(ModularBody.kind_of(slot)))
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
	blockers.append(SandboxLayout.DOOR)
	nav = NavGrid.new(SandboxLayout.FLOOR_RECT, blockers, Player.RADIUS)
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
	fight.track(guard)
	add_child(fight)


func _all_blockers() -> Array[Rect2]:
	var result: Array[Rect2] = []
	result.append_array(SandboxLayout.WALLS)
	result.append_array(SandboxLayout.LOW_COVERS)
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
	for rect: Rect2 in SandboxLayout.WALLS:
		_add_wall(rect, tall, Wall.Kind.SOLID)
	for rect: Rect2 in SandboxLayout.LOW_COVERS:
		_add_wall(rect, SandboxLayout.LOW_FRONT_HEIGHT, Wall.Kind.LOW)
	door = _add_wall(SandboxLayout.DOOR, tall, Wall.Kind.DOOR)


func _build_boundaries() -> void:
	var area: Rect2 = SandboxLayout.FLOOR_RECT
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
	player.position = SandboxLayout.PLAYER_START
	player.noise_bus = noise_bus
	actors.add_child(player)
	var camera: CameraZoom = CameraZoom.new()
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = 1920
	camera.limit_bottom = 1080
	player.add_child(camera)


func _build_enemies() -> void:
	guard = Guard.new()
	guard.target = player
	guard.nav = nav
	guard.rng = rng
	guard.setup(SandboxLayout.GUARD_PATROL, ground)
	actors.add_child(guard)
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
	for at: Vector2 in SandboxLayout.SAVE_POINTS:
		var point: SavePoint = SavePoint.new()
		point.position = at
		point.entered.connect(autosave)
		ground.add_child(point)
		save_points.append(point)


func _build_interface() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	add_child(layer)
	_pause_label = _add_label(layer, "UI_PAUSE", Vector2(860.0, 24.0), 32)
	_pause_label.visible = false
	_done_label = _add_label(layer, "UI_CHALLENGE_DONE", Vector2(820.0, 70.0), 32)
	_done_label.visible = false
	_add_label(layer, "UI_SANDBOX_HELP", Vector2(24.0, 1040.0), 20)
	_add_label(layer, "UI_OBJECTIVE", Vector2(24.0, 16.0), 22)
	var hud: BodyHud = BodyHud.new()
	hud.body = player.body
	layer.add_child(hud)
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
	noise_bus.noise_emitted.connect(guard.hear)
	drone.alarm_raised.connect(guard.investigate)
	security_camera.alarm_raised.connect(guard.investigate)
	fight.pre_fight_started.connect(_on_pre_fight_started)
	fight.fight_ended.connect(autosave)
	panel.closed.connect(_on_panel_closed)
	_connect_body()


func _connect_body() -> void:
	player.body.piece_destroyed.connect(_on_piece_destroyed)
	player.body.died.connect(_on_player_died)


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
	if not session_started:
		_show_start_menu()


func _begin_fresh() -> void:
	rng.seed = randi() if forced_seed < 0 else forced_seed
	_replace_body(default_body())
	autosave()


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
		float(at.get("x", SandboxLayout.PLAYER_START.x)),
		float(at.get("y", SandboxLayout.PLAYER_START.y))
	)
	for id: Variant in data.get("used", []):
		if items.has(id):
			(items[id] as Interactable).mark_used()
			if id == ID_TERMINAL:
				_open_door()
	if data.get("challenge_done", false):
		challenge_done = true
		_done_label.visible = true
	return true


func _replace_body(new_body: ModularBody) -> void:
	player.body = new_body
	fight.body = new_body
	panel.body = new_body
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
	nav.clear_rect(SandboxLayout.DOOR, Player.RADIUS, _all_blockers())


func _complete_challenge() -> void:
	challenge_done = true
	_done_label.visible = true
	autosave()


func _add_pickup(slots: Array[ModularBody.Slot]) -> void:
	for slot: ModularBody.Slot in slots:
		if player.body.add_spare(slot, BodyPiece.new(ModularBody.kind_of(slot))):
			return


func _on_item_activated(item: Interactable) -> void:
	match item.kind:
		Interactable.Kind.CRATE:
			noise_bus.emit_noise(item.global_position, SandboxLayout.CRATE_NOISE_RADIUS)
		Interactable.Kind.TERMINAL:
			_open_door()
		Interactable.Kind.PICKUP_LEG:
			_add_pickup([ModularBody.Slot.LEG_LEFT, ModularBody.Slot.LEG_RIGHT])
		Interactable.Kind.PICKUP_ARM:
			_add_pickup([ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT])


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
