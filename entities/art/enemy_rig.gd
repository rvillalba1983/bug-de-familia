class_name EnemyRig
extends Node2D
## Personaje de piezas con huesos: anda, se sobresalta y cae con AnimationPlayer.
## Coordenadas de los huesos: las del SVG original, de 512 x 512.
## Tiempos y amplitudes provisionales, a ajustar al probar.

const WALK: StringName = &"andar"
const IDLE: StringName = &"quieto"
const ALERT: StringName = &"alerta"
const FALL: StringName = &"caer"
const CANVAS: float = 512.0
const TEXTURE_SCALE: float = 2.0
const BLEND: float = 0.12
const HIPS: Vector2 = Vector2(256.0, 420.0)
const CHEST: Vector2 = Vector2(256.0, 400.0)
const JOINTS: Dictionary = {
	"pierna_i": Vector2(205.0, 400.0),
	"pierna_d": Vector2(313.0, 400.0),
	"brazo_i": Vector2(136.0, 274.0),
	"brazo_d": Vector2(380.0, 272.0),
	"cabeza": Vector2(258.0, 180.0),
}
const ALL_PARTS: Array[String] = ["pierna_i", "pierna_d", "brazo_i", "brazo_d", "torso", "cabeza"]

var player: AnimationPlayer

var _hips: Node2D


## Monta el esqueleto. height y feet colocan los pies como en la imagen sin animar.
func build(folder: String, height: float, feet: float) -> void:
	scale = Vector2.ONE * height / CANVAS
	position = Vector2(0.0, -height * feet)
	_hips = _bone("caderas", self, Vector2(HIPS.x - CANVAS * 0.5, HIPS.y))
	_limb(folder, "pierna_i", _hips, HIPS)
	_limb(folder, "pierna_d", _hips, HIPS)
	var chest: Node2D = _bone("pecho", _hips, CHEST - HIPS)
	_limb(folder, "brazo_i", chest, CHEST)
	_limb(folder, "brazo_d", chest, CHEST)
	_sprite(folder, "torso", chest, CHEST)
	_limb(folder, "cabeza", chest, CHEST)
	player = AnimationPlayer.new()
	add_child(player)
	player.root_node = player.get_path_to(_hips)
	var library: AnimationLibrary = AnimationLibrary.new()
	library.add_animation(IDLE, _make_idle())
	library.add_animation(WALK, _make_walk())
	library.add_animation(ALERT, _make_alert())
	library.add_animation(FALL, _make_fall())
	player.add_animation_library(&"", library)
	player.play(IDLE)


## Pide una animación; si ya suena, no la reinicia.
func show_animation(animation: StringName) -> void:
	if player.current_animation != animation and player.assigned_animation != animation:
		player.play(animation, BLEND)


func current() -> StringName:
	return player.assigned_animation


func _bone(bone_name: String, parent: Node2D, at: Vector2) -> Node2D:
	var bone: Node2D = Node2D.new()
	bone.name = bone_name
	bone.position = at
	parent.add_child(bone)
	return bone


func _limb(folder: String, part: String, parent: Node2D, parent_joint: Vector2) -> void:
	var joint: Vector2 = JOINTS[part]
	var bone: Node2D = _bone(part, parent, joint - parent_joint)
	_sprite(folder, part, bone, joint)


func _sprite(folder: String, part: String, parent: Node2D, joint: Vector2) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "imagen_" + part
	sprite.texture = load(folder.path_join(part + ".svg")) as Texture2D
	sprite.centered = false
	sprite.scale = Vector2.ONE * TEXTURE_SCALE
	sprite.position = -joint
	parent.add_child(sprite)


func _rest(path: String) -> Vector2:
	return (_hips.get_node(path) as Node2D).position


func _track(animation: Animation, path: String, keys: Array) -> void:
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(path))
	for key: Array in keys:
		animation.track_insert_key(track, key[0], key[1])


func _rock(animation: Animation, path: String, time: float, amount: float) -> void:
	_track(animation, path + ":rotation", [[0.0, amount], [time * 0.5, -amount], [time, amount]])


func _lift(animation: Animation, part: String, time: float, first_half: bool) -> void:
	var rest: Vector2 = _rest(part)
	var up: Vector2 = rest + Vector2(0.0, -30.0)
	var keys: Array = [[0.0, rest], [time * 0.25, up], [time * 0.5, rest], [time, rest]]
	if not first_half:
		keys = [[0.0, rest], [time * 0.5, rest], [time * 0.75, up], [time, rest]]
	_track(animation, part + ":position", keys)


func _make_idle() -> Animation:
	var animation: Animation = Animation.new()
	animation.length = 1.6
	animation.loop_mode = Animation.LOOP_LINEAR
	var rest: Vector2 = _rest("pecho")
	var breath: Vector2 = rest + Vector2(0.0, -5.0)
	_track(animation, "pecho:position", [[0.0, rest], [0.8, breath], [1.6, rest]])
	_rock(animation, "pecho/cabeza", 1.6, 0.025)
	return animation


func _make_walk() -> Animation:
	var animation: Animation = Animation.new()
	var time: float = 0.7
	animation.length = time
	animation.loop_mode = Animation.LOOP_LINEAR
	_lift(animation, "pierna_i", time, true)
	_lift(animation, "pierna_d", time, false)
	_rock(animation, "pecho", time, 0.05)
	_rock(animation, "pecho/brazo_i", time, 0.16)
	_rock(animation, "pecho/brazo_d", time, -0.09)
	_rock(animation, "pecho/cabeza", time, -0.04)
	var rest: Vector2 = _rest("pecho")
	var low: Vector2 = rest + Vector2(0.0, 9.0)
	_track(
		animation, "pecho:position",
		[[0.0, rest], [time * 0.25, low], [time * 0.5, rest], [time * 0.75, low], [time, rest]]
	)
	return animation


func _make_alert() -> Animation:
	var animation: Animation = Animation.new()
	animation.length = 0.5
	var rest: Vector2 = _rest("pecho")
	var jump: Vector2 = rest + Vector2(0.0, -44.0)
	_track(animation, "pecho:position", [[0.0, rest], [0.1, jump], [0.3, rest]])
	_track(animation, "pecho/brazo_i:rotation", [[0.0, 0.0], [0.1, 0.7], [0.5, 0.3]])
	_track(animation, "pecho/brazo_d:rotation", [[0.0, 0.0], [0.1, -0.5], [0.5, -0.2]])
	var head: Vector2 = _rest("pecho/cabeza")
	_track(animation, "pecho/cabeza:position", [[0.0, head], [0.1, head + Vector2(0.0, -32.0)], [0.3, head]])
	return animation


func _make_fall() -> Animation:
	var animation: Animation = Animation.new()
	animation.length = 0.55
	var hips: Vector2 = _hips.position
	var keys_at: Vector2 = hips + Vector2(0.0, -40.0)
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(".:rotation"))
	animation.track_insert_key(track, 0.0, 0.0)
	animation.track_insert_key(track, 0.15, -0.2)
	animation.track_insert_key(track, 0.45, PI * 0.5)
	_track(animation, ".:position", [[0.0, hips], [0.15, keys_at], [0.45, hips], [0.55, hips + Vector2(0.0, 22.0)]])
	_track(animation, "pecho/cabeza:rotation", [[0.0, 0.0], [0.45, 0.0], [0.55, 0.3]])
	_track(animation, "pecho/brazo_i:rotation", [[0.0, 0.0], [0.45, 0.9]])
	_track(animation, "pecho/brazo_d:rotation", [[0.0, 0.0], [0.45, -0.7]])
	return animation
