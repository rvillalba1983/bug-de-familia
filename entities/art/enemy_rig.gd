class_name EnemyRig
extends Node2D
## Personaje de piezas con huesos: anda, se sobresalta y cae con AnimationPlayer.
## Coordenadas de los huesos: las del SVG original (ver EnemyRigData).
## Tiempos y amplitudes provisionales, a ajustar al probar.

const WALK: StringName = &"andar"
const IDLE: StringName = &"quieto"
const ALERT: StringName = &"alerta"
const FALL: StringName = &"caer"
const BLEND: float = 0.12
const ALL_PARTS: Array[String] = ["pierna_i", "pierna_d", "brazo_i", "brazo_d", "torso", "cabeza"]
const FAR_LEG_TINT: Color = Color(0.68, 0.68, 0.76)
const CLIPS_PATH: String = "res://data/art/enemy_animations.json"

static var _clips: Dictionary = {}

var player: AnimationPlayer

var _hips: Node2D
var _data: Dictionary = {}
var _folder: String = ""


## Monta el esqueleto de una vista. height y feet colocan los pies como en la imagen sin animar.
func build(folder: String, height: float, feet: float) -> void:
	_data = EnemyRigData.VIEWS[folder.get_file()]
	use_parent_material = true
	_folder = folder
	var canvas: Vector2 = _data["canvas"]
	var hips: Vector2 = _data["hips"]
	var chest_at: Vector2 = _data["chest"]
	scale = Vector2.ONE * height / canvas.y
	position = Vector2(0.0, -height * feet)
	_hips = _bone("caderas", self, Vector2(hips.x - canvas.x * 0.5, hips.y))
	_limb("pierna_i", _hips, hips)
	_limb("pierna_d", _hips, hips)
	if bool(_data["side"]) and _hips.has_node("pierna_i"):
		(_hips.get_node("pierna_i") as Node2D).modulate = FAR_LEG_TINT
	var chest: Node2D = _bone("pecho", _hips, chest_at - hips)
	var front: Array = _data["front"]
	for arm: String in ["brazo_i", "brazo_d"]:
		if not front.has(arm):
			_limb(arm, chest, chest_at)
	_sprite("torso", chest, chest_at)
	for arm: String in ["brazo_i", "brazo_d"]:
		if front.has(arm):
			_limb(arm, chest, chest_at)
	_limb("cabeza", chest, chest_at)
	player = AnimationPlayer.new()
	add_child(player)
	player.root_node = player.get_path_to(_hips)
	var library: AnimationLibrary = AnimationLibrary.new()
	if _clips.is_empty():
		_clips = DataFile.load_dictionary(CLIPS_PATH)
	for clip: String in _clips:
		library.add_animation(StringName(clip), _make_clip(_clips[clip]))
	player.add_animation_library(&"", library)
	player.play(IDLE)


## Toma la animación y el instante de otra vista, para que el cambio no se note.
func continue_from(other: EnemyRig) -> void:
	player.play(other.current())
	player.seek(other.player.current_animation_position, true)


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
	bone.use_parent_material = true
	parent.add_child(bone)
	return bone


func _limb(part: String, parent: Node2D, parent_joint: Vector2) -> void:
	var joints: Dictionary = _data["joints"]
	if not joints.has(part):
		return
	var joint: Vector2 = joints[part]
	var bone: Node2D = _bone(part, parent, joint - parent_joint)
	_sprite(part, bone, joint)


func _sprite(part: String, parent: Node2D, joint: Vector2) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "imagen_" + part
	sprite.centered = false
	sprite.use_parent_material = true
	var key: String = _folder.get_file() + "/" + part
	var canvas_width: float = (_data["canvas"] as Vector2).x
	if PieceAtlas.has_entry(key):
		sprite.texture = PieceAtlas.texture()
		sprite.region_enabled = true
		sprite.region_rect = PieceAtlas.region(key)
		sprite.scale = Vector2.ONE * canvas_width / PieceAtlas.full_width(key)
		sprite.position = -joint + PieceAtlas.trim_offset(key) * sprite.scale
	else:
		sprite.texture = load(_folder.path_join(part + ".svg")) as Texture2D
		sprite.scale = Vector2.ONE * canvas_width / float(sprite.texture.get_width())
		sprite.position = -joint
	parent.add_child(sprite)


func _has(path: String) -> bool:
	return _hips.has_node(path)


func _rest(path: String) -> Vector2:
	return (_hips.get_node(path) as Node2D).position


## Las posiciones de los datos son desplazamientos sobre el reposo; los giros, absolutos.
func _make_clip(clip: Dictionary) -> Animation:
	var animation: Animation = Animation.new()
	animation.length = float(clip["length"])
	if clip["loop"]:
		animation.loop_mode = Animation.LOOP_LINEAR
	for track: Dictionary in clip["tracks"]:
		var path: String = track["path"]
		if _applies(track.get("when", {})) and _has(path.get_slice(":", 0)):
			_add_track(animation, path, track["keys"])
	return animation


func _applies(when: Dictionary) -> bool:
	if when.has("side") and bool(when["side"]) != bool(_data["side"]):
		return false
	var waddle: bool = _data["gait"] == EnemyRigData.NO_LEGS
	return not when.has("waddle") or bool(when["waddle"]) == waddle


func _add_track(animation: Animation, path: String, keys: Array) -> void:
	var track: int = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track, NodePath(path))
	var rest: Vector2 = _rest(path.get_slice(":", 0))
	for key: Array in keys:
		var value: Variant = key[1]
		if value is Array:
			value = rest + Vector2(float(value[0]), float(value[1]))
		else:
			value = float(value)
		animation.track_insert_key(track, float(key[0]), value)
