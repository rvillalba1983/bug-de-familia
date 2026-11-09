class_name GuardVisual
extends RefCounted
## Aspecto de un guardia: círculo provisional, imágenes por vista o esqueleto animado.

const COLOR_BODY: Color = Color("#3f7fd0")
const COLOR_SHOOTER: Color = Color("#3fb0a0")
const COLOR_DOWN: Color = Color("#505868")
const COLOR_WINDUP: Color = Color(1.0, 0.2, 0.15, 0.85)
const COLOR_ALERT: Color = Color("#e04040")
const COLOR_FALLEN: Color = Color(0.5, 0.5, 0.6)
const COLOR_ART_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.4)
const ART_HEIGHT: float = 77.0
## Altura de los pies dentro del dibujo, medida desde arriba.
const ART_FEET: float = 0.93
const VIEW_SOUTH: int = 0
const VIEW_EAST: int = 1
const VIEW_NORTH: int = 2
const VIEW_SUFFIX: Array[String] = ["", "_e", "_n"]

## Vistas sur, este y norte, en ese orden. El oeste refleja al este.
## Si está vacío se dibuja el círculo de color.
var art_views: Array[Texture2D] = []
## Carpeta base de piezas con huesos; vacía si este personaje no las tiene.
var rig_folder: String = ""
var body_color: Color = Color.TRANSPARENT
## Esqueleto de la vista actual. Hay uno por vista y se crean al necesitarlos.
var rig: EnemyRig
## Padre de los esqueletos, en los pies: deforma y destella a todos a la vez.
var rig_root: Node2D

var _guard: Guard
var _rigs: Array[EnemyRig] = [null, null, null]
var _rig_view: int = VIEW_SOUTH
var _was_alert: bool = false


func _init(guard: Guard) -> void:
	_guard = guard


static func view_for(direction: Vector2) -> int:
	if absf(direction.y) > absf(direction.x):
		return VIEW_SOUTH if direction.y > 0.0 else VIEW_NORTH
	return VIEW_EAST


func draw() -> void:
	if _guard.state == Guard.State.DOWN:
		_draw_down()
		return
	if not art_views.is_empty():
		_draw_art()
	else:
		_draw_placeholder()
	_draw_windup()
	_draw_health()


## Elige vista y animación según el estado. Caído, conserva la vista en la que cayó.
func update_rig() -> void:
	if rig_folder == "":
		return
	var state: Guard.State = _guard.state
	var facing: Vector2 = Vector2.from_angle(_guard.detector.facing_angle)
	if state != Guard.State.DOWN or rig == null:
		_show_view(view_for(facing))
	if _rig_view == VIEW_EAST:
		var flipped: bool = facing.x < 0.0 and state != Guard.State.DOWN
		rig.scale.x = absf(rig.scale.x) * (-1.0 if flipped else 1.0)
	rig.modulate = _rig_tint(state)
	if state == Guard.State.DOWN:
		rig.show_animation(StringName(str(_guard.death["animation"])))
	elif state == Guard.State.ALERT and not _was_alert:
		rig.show_animation(EnemyRig.ALERT)
	elif state != Guard.State.ALERT or not rig.player.is_playing():
		rig.show_animation(EnemyRig.WALK if _guard.velocity.length() > 1.0 else EnemyRig.IDLE)
	_was_alert = state == Guard.State.ALERT


func _rig_tint(state: Guard.State) -> Color:
	if state == Guard.State.DOWN:
		return COLOR_FALLEN
	return COLOR_ALERT.lightened(0.5) if state == Guard.State.ALERT else Color.WHITE


func _draw_windup() -> void:
	var attack: GuardAttack = _guard.attack
	if attack.windup_left <= 0.0:
		return
	if attack.is_ranged():
		var aim: Vector2 = attack.aim_point - _guard.global_position
		_guard.draw_line(Vector2(0.0, -30.0), aim, COLOR_WINDUP, 2.0)
	else:
		_guard.draw_arc(Vector2(0.0, -30.0), float(attack.weapon["range"]), 0.0, TAU, 32, COLOR_WINDUP, 3.0)


func _draw_health() -> void:
	if _guard.health >= Guard.MAX_HEALTH:
		return
	var bar: Rect2 = Rect2(-24.0, -Guard.BODY_HEIGHT - 16.0, 48.0, 6.0)
	_guard.draw_rect(bar, Color(0.0, 0.0, 0.0, 0.6))
	bar.size.x *= _guard.health / Guard.MAX_HEALTH
	_guard.draw_rect(bar, COLOR_ALERT)


func _draw_down() -> void:
	if art_views.is_empty():
		_guard.draw_circle(Vector2.ZERO, Guard.BODY_HEIGHT * 0.42, COLOR_DOWN)
		return
	if rig != null:
		_draw_shadow()
		return
	var art: Texture2D = art_views[VIEW_SOUTH]
	var half: float = ART_HEIGHT * 0.5
	_guard.draw_set_transform(Vector2(-ART_HEIGHT * 0.45, -14.0), PI * 0.5)
	_guard.draw_texture_rect(art, Rect2(-half, -half, ART_HEIGHT, ART_HEIGHT), false, COLOR_FALLEN)
	_guard.draw_set_transform(Vector2.ZERO)


## Sombra aplastada: un disco entero parecía un agujero bajo los pies.
func _draw_shadow() -> void:
	_guard.draw_set_transform(Vector2(0.0, 2.0), 0.0, Vector2(1.0, 0.38))
	_guard.draw_circle(Vector2.ZERO, 22.0, COLOR_ART_SHADOW)
	_guard.draw_set_transform(Vector2.ZERO)


func _draw_art() -> void:
	if rig != null:
		_draw_shadow()
		return
	var direction: Vector2 = Vector2.from_angle(_guard.detector.facing_angle)
	var view: int = view_for(direction)
	var art: Texture2D = art_views[view]
	var size: Vector2 = Vector2(ART_HEIGHT * art.get_size().aspect(), ART_HEIGHT)
	if view == VIEW_EAST and direction.x < 0.0:
		size.x = -size.x
	var tint: Color = COLOR_ALERT.lightened(0.5) if _guard.state == Guard.State.ALERT else Color.WHITE
	_draw_shadow()
	var at: Vector2 = Vector2(-size.x * 0.5, -ART_HEIGHT * ART_FEET)
	_guard.draw_texture_rect(art, Rect2(at, size), false, tint)


func _draw_placeholder() -> void:
	var color: Color = COLOR_SHOOTER if _guard.attack.is_ranged() else COLOR_BODY
	if body_color.a > 0.0:
		color = body_color
	if _guard.state == Guard.State.ALERT:
		color = COLOR_ALERT
	var center: Vector2 = Vector2(0.0, -Guard.BODY_HEIGHT * 0.5)
	_guard.draw_circle(center, Guard.BODY_HEIGHT * 0.42, color)


func _ensure_rig_root() -> Node2D:
	if rig_root == null:
		rig_root = Node2D.new()
		rig_root.name = "esqueletos"
		rig_root.material = ImpactFx.new_flash_material()
		_guard.add_child(rig_root)
	return rig_root


func _show_view(view: int) -> void:
	if rig != null and view == _rig_view:
		return
	var previous: EnemyRig = rig
	if _rigs[view] == null:
		_rigs[view] = EnemyRig.new()
		_ensure_rig_root().add_child(_rigs[view])
		_rigs[view].build(rig_folder + VIEW_SUFFIX[view], ART_HEIGHT, ART_FEET)
	rig = _rigs[view]
	_rig_view = view
	rig.visible = true
	if previous != null:
		rig.continue_from(previous)
		previous.visible = false
		previous.player.pause()
