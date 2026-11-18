class_name ProtagonistArt
extends RefCounted
## Dibuja al protagonista con polígonos de Godot, por piezas independientes.
## Los datos salen de tools/art/protagonist_gen.py, calcado de la hoja de diseño.

const RUST_FROM: float = 0.25
const COLOR_RUST: Color = Color("#a8482a")
const COLOR_ACID_BUBBLE: Color = Color("#c6ff00")
const RUST_OFFSETS: Array[Vector2] = [
	Vector2(-4.0, 6.0), Vector2(5.0, 14.0), Vector2(-3.0, 22.0), Vector2(6.0, 28.0), Vector2(0.0, 11.0), Vector2(-6.0, 32.0),
]
const DATA_PATH: String = "res://data/art/protagonista.json"
## Pasa de las coordenadas de la hoja a píxeles de juego.
const ART_SCALE: float = 0.085
const WORN_RATIO: float = 0.35
const WORN_TINT: Color = Color("#ff4a3a")
const WORN_MIX: float = 0.55
const LEG_SWING: float = 0.2
const ARM_SWING: float = 0.12
## P-51: modificadores de pose por estado y por gesto. Valores provisionales.
const RUN_LEAN: float = 0.08
const RUN_SWING_SCALE: float = 1.3
const CROUCH_LEG_SPREAD: float = 0.15
const CROUCH_ARM_TUCK: float = 0.25
const SIT_LEG_BEND: float = 0.6
const SIT_DROP: float = 12.0
const GATHER_ARM: float = 0.4
const ATTACK_ARM: float = -0.6
const PIECE_ARM: float = -0.5
const THROW_ARM: float = -1.2
const THROW_TIME: float = 0.15
const CAST_ARM: float = -0.8
const CELEBRATE_ARM: float = -1.0
const CELEBRATE_HOP: float = 8.0
const CELEBRATE_HOP_TIME: float = 0.3
const TAUNT_ARM: float = -0.6
const TAUNT_HEAD: float = 0.15
const TAUNT_TAIL_WIDTH: float = 1.3
const SALUTE_ARM: float = -0.8
const SALUTE_SWING: float = 0.15
const SALUTE_PERIOD: float = 0.3
const SALUTE_HEAD: float = 0.08
const POINT_ARM: float = -0.4
const POINT_HEAD: float = 0.1
const SCRATCH_ARM: float = -1.3
const SCRATCH_SWING: float = 0.05
const SCRATCH_PERIOD: float = 0.15
const SCRATCH_HEAD: float = 0.1
const HIT_LEAN: float = -0.12
const HIT_ARMS: float = 0.2
const STAGGER_LEAN: float = 0.1
const STAGGER_TIME: float = 0.6
const DEATH_SQUASH: Vector2 = Vector2(1.3, 0.7)
const DEATH_SQUASH_TIME: float = 0.3
const DEATH_FALL_END: float = 0.8
const DEATH_FALL: float = 1.2
const DEATH_SPREAD_TIME: float = 0.5
const DEATH_SPREAD: float = 4.0
const FRAGILE_RATIO: float = 0.2
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.4)
const TAIL_POINTS: int = 22
const TAIL_STEP: float = 3.6
const TAIL_WIDTH: float = 8.0
const TAIL_DARK: Color = Color("#1a1450")

const SILHOUETTE_VIEW: String = "S"
const SILHOUETTE_NEUTRAL: Color = Color("#8894b5")
const SILHOUETTE_HOLLOW: Color = Color(0.96, 0.9, 0.78, 0.55)
const SILHOUETTE_HOLLOW_WIDTH: float = 5.0
const SILHOUETTE_LOW: float = 0.25

const VIEWS: Array[String] = ["E", "SE", "S", "SW", "W", "NW", "N", "NE"]
const VIEWS_FROM_BEHIND: Array[String] = ["N", "NE", "NW"]
const PART_SLOTS: Dictionary = {
	"head": ModularBody.Slot.HEAD,
	"arm_extra_left": ModularBody.Slot.ARM_EXTRA_LEFT,
	"arm_extra_right": ModularBody.Slot.ARM_EXTRA_RIGHT,
	"arm_main_left": ModularBody.Slot.ARM_MAIN_LEFT,
	"arm_main_right": ModularBody.Slot.ARM_MAIN_RIGHT,
	"leg_left": ModularBody.Slot.LEG_LEFT,
	"leg_right": ModularBody.Slot.LEG_RIGHT,
}
const VARIANT_GROUPS: Dictionary = {
	BodyPiece.Kind.HEAD: "head",
	BodyPiece.Kind.ARM: "arm",
	BodyPiece.Kind.LEG: "leg",
}

static var _views: Dictionary = {}
static var _variants: Dictionary = {}
static var _baked: Dictionary = {}
static var _meshes: Dictionary = {}
static var _silhouette_meshes: Dictionary = {}


static func draw(
	canvas: CanvasItem,
	facing: Vector2,
	height_ratio: float,
	body: ModularBody,
	tail_color: Color,
	_tail_speaking: bool,
	walk_phase: float,
	squash: Vector2 = Vector2.ONE,
	frame_key: String = "",
	pose: Dictionary = {}
) -> void:
	_ensure_loaded()
	var view_name: String = view_for(facing)
	var away: bool = VIEWS_FROM_BEHIND.has(view_name)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	var size: float = CharacterScale.value
	var total_squash: Vector2 = squash * (pose.get("squash", Vector2.ONE) as Vector2)
	CircleDot.draw(canvas, Vector2(0.0, 3.0 * size), 22.0 * size, SHADOW_COLOR)
	if not away:
		_draw_tail(canvas, facing, height_ratio, tail_color, pose)
	var bob: float = -absf(sin(walk_phase)) * 1.5 * size
	var art: float = ART_SCALE * size
	var offset: Vector2 = pose.get("body_offset", Vector2.ZERO) as Vector2
	var base: Transform2D = Transform2D(
		float(pose.get("base_rotation", 0.0)),
		Vector2(art * total_squash.x, art * height_ratio * total_squash.y),
		0.0,
		Vector2(0.0, bob) + offset * size
	)
	var view: Dictionary = _views[view_name]
	for part_name: String in view["order"]:
		_draw_part(canvas, view_name, part_name, base, body, walk_phase, pose)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	if away:
		_draw_tail(canvas, facing, height_ratio, tail_color, pose)
	_draw_action_frame(canvas, frame_key, size)


## Pose del rig según el estado del protagonista (P-51). Es pura: se puede probar
## sin dibujar. Espera claves `action`, `elapsed`, `crouching`, `running`, `sitting`
## y `dead`; devuelve rotaciones por pieza, inclinaciones y desplazamientos.
static func pose_for(state: Dictionary) -> Dictionary:
	var pose: Dictionary = {
		"base_rotation": 0.0,
		"body_offset": Vector2.ZERO,
		"swing_scale": 1.0,
		"parts": {},
		"tail_amplitude": 1.0,
		"tail_width_scale": 1.0,
		"piece_offset": 0.0,
		"hide_fragile": false,
		"squash": Vector2.ONE,
	}
	if bool(state.get("running", false)):
		pose["swing_scale"] = RUN_SWING_SCALE
		pose["base_rotation"] = RUN_LEAN
	if bool(state.get("crouching", false)):
		_add_part(pose, "leg_left", CROUCH_LEG_SPREAD)
		_add_part(pose, "leg_right", -CROUCH_LEG_SPREAD)
		_add_part(pose, "arm_main_right", CROUCH_ARM_TUCK)
		_add_part(pose, "arm_main_left", -CROUCH_ARM_TUCK)
	if bool(state.get("sitting", false)):
		pose["parts"] = {}
		_add_part(pose, "leg_left", SIT_LEG_BEND)
		_add_part(pose, "leg_right", -SIT_LEG_BEND)
		pose["body_offset"] = Vector2(0.0, SIT_DROP)
	if bool(state.get("dead", false)):
		_apply_death_pose(pose, float(state.get("elapsed", 0.0)))
		return pose
	_apply_action_pose(pose, str(state.get("action", "")), float(state.get("elapsed", 0.0)))
	return pose


## Fotograma de la acción actual, del atlas compartido (P-25). Una sola llamada de dibujo.
static func _draw_action_frame(canvas: CanvasItem, key: String, size: float) -> void:
	if key.is_empty() or not PieceAtlas.has_entry(key):
		return
	var lado: float = 26.0 * size
	var caja: Rect2 = Rect2(10.0 * size, -46.0 * size, lado, lado)
	canvas.draw_texture_rect_region(
		PieceAtlas.texture(), caja, PieceAtlas.region(key), Color.WHITE, false
	)


## Silueta de frente para la interfaz. Cada pieza se pinta según lo gastada que está;
## la que falta se queda en un hueco con el contorno. hits: ranuras recién golpeadas.
static func draw_silhouette(
	canvas: CanvasItem, feet: Vector2, size: float, body: ModularBody, hits: Dictionary, pulse: float
) -> void:
	_ensure_loaded()
	var view: Dictionary = _views[SILHOUETTE_VIEW]
	var batch: PolyBatch = PolyBatch.new()
	for part_name: String in view["order"]:
		_add_silhouette_part(batch, part_name, body, hits, pulse)
	# El dibujo no retiene la malla: si se suelta, desaparece.
	var mesh: ArrayMesh = batch.build()
	_silhouette_meshes[canvas.get_instance_id()] = mesh
	canvas.draw_set_transform_matrix(Transform2D(0.0, Vector2(size, size), 0.0, feet))
	canvas.draw_mesh(mesh, null)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


## Dibuja una pieza suelta, entera, ajustada al recuadro.
static func draw_piece(canvas: CanvasItem, box: Rect2, slot: ModularBody.Slot, piece: BodyPiece) -> void:
	_ensure_loaded()
	var part_name: String = PART_SLOTS.find_key(slot)
	var group: String = VARIANT_GROUPS[piece.kind]
	var shapes: Array = _shapes_for(SILHOUETTE_VIEW, part_name, group, piece.visual_variant, false)
	var bounds: Rect2 = Rect2()
	var first: bool = true
	for shape: Dictionary in shapes:
		var key: String = "points" if shape.has("points") else "line"
		for point: Vector2 in shape[key] as PackedVector2Array:
			bounds = Rect2(point, Vector2.ZERO) if first else bounds.expand(point)
			first = false
	if first:
		return
	var zoom: float = minf(box.size.x / maxf(bounds.size.x, 1.0), box.size.y / maxf(bounds.size.y, 1.0))
	var offset: Vector2 = box.get_center() - bounds.get_center() * zoom
	canvas.draw_set_transform_matrix(Transform2D(0.0, Vector2(zoom, zoom), 0.0, offset))
	for shape: Dictionary in shapes:
		_draw_shape(canvas, shape)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


## Color del estado de una pieza: verde entera, amarillo a medias y rojo al final.
static func wear_color(ratio: float) -> Color:
	if ratio >= 0.5:
		return Palette.OBRA.lerp(Palette.ACIDO, (ratio - 0.5) * 2.0)
	return Palette.ROSA.lerp(Palette.OBRA, ratio * 2.0)


static func _add_silhouette_part(
	batch: PolyBatch, part_name: String, body: ModularBody, hits: Dictionary, pulse: float
) -> void:
	var base: Color = SILHOUETTE_NEUTRAL
	var missing: bool = false
	if PART_SLOTS.has(part_name):
		var slot: int = PART_SLOTS[part_name]
		var piece: BodyPiece = body.equipped(slot as ModularBody.Slot)
		if piece == null:
			missing = true
		else:
			var ratio: float = piece.durability / BodyPiece.MAX_DURABILITY
			base = wear_color(ratio)
			if ratio < SILHOUETTE_LOW:
				base = base.lerp(Color.WHITE, 0.45 * pulse)
			if hits.has(slot):
				base = Color.WHITE
	for shape: Dictionary in _shapes_for(SILHOUETTE_VIEW, part_name, "", 0, false):
		_add_silhouette_shape(batch, shape, base, missing)


static func _add_silhouette_shape(batch: PolyBatch, shape: Dictionary, base: Color, missing: bool) -> void:
	if shape.has("line"):
		if not missing:
			batch.add_polyline(shape["line"] as PackedVector2Array, _shaded(base, shape["color"] as Color), shape["width"] as float)
		return
	var outline_only: bool = missing
	if outline_only:
		batch.add_polyline(shape["outline"] as PackedVector2Array, SILHOUETTE_HOLLOW, SILHOUETTE_HOLLOW_WIDTH)
		return
	var source: PackedColorArray = shape["colors"]
	var colors: PackedColorArray = PackedColorArray()
	for color: Color in source:
		colors.append(_shaded(base, color))
	batch.add_polygon(shape["points"] as PackedVector2Array, colors)
	var width: float = shape["width"]
	if width > 0.0:
		batch.add_polyline(shape["outline"] as PackedVector2Array, Palette.INK, width)


## Conserva las luces y sombras del dibujo, pero con el color de estado.
static func _shaded(base: Color, original: Color) -> Color:
	var shade: float = lerpf(0.55, 1.1, original.get_luminance())
	var result: Color = Color(base.r * shade, base.g * shade, base.b * shade, original.a)
	return result


## Vista de las 8 que corresponde a una dirección.
static func view_for(facing: Vector2) -> String:
	return VIEWS[wrapi(roundi(facing.angle() / (PI / 4.0)), 0, VIEWS.size())]


static func _draw_part(
	canvas: CanvasItem, view_name: String, part_name: String,
	base: Transform2D, body: ModularBody, walk_phase: float, pose: Dictionary
) -> void:
	var worn: bool = false
	var variant: int = 0
	var group: String = ""
	if PART_SLOTS.has(part_name):
		var piece: BodyPiece = body.equipped(PART_SLOTS[part_name] as ModularBody.Slot)
		if piece == null:
			return
		if bool(pose.get("hide_fragile", false)):
			if piece.durability < BodyPiece.MAX_DURABILITY * FRAGILE_RATIO:
				return
		worn = piece.durability / BodyPiece.MAX_DURABILITY < WORN_RATIO
		variant = piece.visual_variant
		group = VARIANT_GROUPS[piece.kind]
	var part: Dictionary = _views[view_name]["parts"][part_name]
	var pivot: Vector2 = _vector(part["pivot"] as Array)
	var swing: float = _swing(part_name, walk_phase) * float(pose.get("swing_scale", 1.0))
	swing += _gesture_rotation(part_name, pose)
	var rotation: Transform2D = Transform2D(swing, Vector2.ZERO)
	var placed: Transform2D = base * Transform2D(0.0, pivot) * rotation * Transform2D(0.0, -pivot)
	var spread: float = float(pose.get("piece_offset", 0.0))
	if spread > 0.0:
		## La pose da píxeles de pantalla; dentro del rig hay que pasarlos a sus unidades.
		var units: float = maxf(ART_SCALE * CharacterScale.value, 0.0001)
		placed = placed * Transform2D(0.0, Vector2(signf(pivot.x) * spread / units, 0.0))
	canvas.draw_set_transform_matrix(placed)
	canvas.draw_mesh(_mesh_for(view_name, part_name, group, variant, worn), null)
	if PART_SLOTS.has(part_name):
		_draw_damage(canvas, pivot, body.equipped(PART_SLOTS[part_name] as ModularBody.Slot), body.acid_time > 0.0)


## Rotación que añade el gesto en curso a una pieza del rig (P-51).
static func _gesture_rotation(part_name: String, pose: Dictionary) -> float:
	return float((pose.get("parts", {}) as Dictionary).get(part_name, 0.0))


static func _add_part(pose: Dictionary, part_name: String, rotation: float) -> void:
	var parts: Dictionary = pose["parts"]
	parts[part_name] = float(parts.get(part_name, 0.0)) + rotation


## Gestos que no usan fotograma de atlas: se leen solo en la postura del rig.
static func _apply_action_pose(pose: Dictionary, action: String, elapsed: float) -> void:
	match action:
		"lanzar":
			_add_part(pose, "arm_main_right", THROW_ARM * clampf(elapsed / THROW_TIME, 0.0, 1.0))
		"convertir":
			_add_part(pose, "arm_main_right", CAST_ARM)
			_add_part(pose, "arm_main_left", -CAST_ARM)
		"recoger":
			_add_part(pose, "arm_main_right", GATHER_ARM)
		"ataque":
			_add_part(pose, "arm_main_right", ATTACK_ARM)
		"recarga":
			_add_part(pose, "arm_main_right", PIECE_ARM)
		"celebrar":
			_add_part(pose, "arm_main_right", CELEBRATE_ARM)
			_add_part(pose, "arm_main_left", -CELEBRATE_ARM)
			_add_part(pose, "arm_extra_right", CELEBRATE_ARM)
			_add_part(pose, "arm_extra_left", -CELEBRATE_ARM)
			pose["tail_amplitude"] = 2.0
			if elapsed < CELEBRATE_HOP_TIME:
				var hop: float = sin(elapsed / CELEBRATE_HOP_TIME * PI)
				pose["body_offset"] = Vector2(0.0, -CELEBRATE_HOP * hop)
		"provocar":
			_add_part(pose, "arm_main_right", TAUNT_ARM)
			_add_part(pose, "head", TAUNT_HEAD)
			pose["tail_width_scale"] = TAUNT_TAIL_WIDTH
		"saludar":
			var wave: float = sin(elapsed / SALUTE_PERIOD * TAU) * SALUTE_SWING
			_add_part(pose, "arm_main_right", SALUTE_ARM + wave)
			_add_part(pose, "head", SALUTE_HEAD * sin(elapsed / SALUTE_PERIOD * PI))
		"señalar":
			_add_part(pose, "arm_main_right", POINT_ARM)
			_add_part(pose, "head", POINT_HEAD)
		"rascar":
			var scratch: float = sin(elapsed / SCRATCH_PERIOD * TAU) * SCRATCH_SWING
			_add_part(pose, "arm_main_right", SCRATCH_ARM + scratch)
			_add_part(pose, "head", SCRATCH_HEAD)
		"daño":
			pose["base_rotation"] += HIT_LEAN
			_add_part(pose, "arm_main_right", HIT_ARMS)
			_add_part(pose, "arm_main_left", -HIT_ARMS)
		"perdida":
			var cycles: float = elapsed / STAGGER_TIME * 3.0
			pose["base_rotation"] += STAGGER_LEAN * sin(cycles * TAU)


## Secuencia de muerte en tres fases (P-51 §2.2 R3). Terminal: no vuelve.
static func _apply_death_pose(pose: Dictionary, elapsed: float) -> void:
	pose["parts"] = {}
	pose["body_offset"] = Vector2.ZERO
	pose["swing_scale"] = 1.0
	pose["base_rotation"] = 0.0
	if elapsed < DEATH_SQUASH_TIME:
		pose["squash"] = Vector2.ONE.lerp(DEATH_SQUASH, elapsed / DEATH_SQUASH_TIME)
	elif elapsed < DEATH_FALL_END:
		var fall: float = (elapsed - DEATH_SQUASH_TIME) / (DEATH_FALL_END - DEATH_SQUASH_TIME)
		pose["base_rotation"] = DEATH_FALL * fall * fall
	else:
		pose["base_rotation"] = DEATH_FALL
		pose["hide_fragile"] = true
	if elapsed >= DEATH_SPREAD_TIME:
		pose["piece_offset"] = DEATH_SPREAD


## Óxido que avanza con el desgaste y, bajo la lluvia ácida, metal que burbujea.
static func _draw_damage(canvas: CanvasItem, pivot: Vector2, piece: BodyPiece, acid: bool) -> void:
	var damage: float = 1.0 - piece.durability / BodyPiece.MAX_DURABILITY
	if damage < RUST_FROM and not (acid and piece.metallic):
		return
	var spots: int = int(ceilf(damage * float(RUST_OFFSETS.size())))
	for index: int in range(mini(spots, RUST_OFFSETS.size())):
		CircleDot.draw(canvas, pivot + RUST_OFFSETS[index], 3.0 + 3.0 * damage, Color(COLOR_RUST, 0.45 + 0.4 * damage))
	if acid and piece.metallic:
		var bubble: float = fmod(float(Time.get_ticks_msec()) * 0.004, 1.0)
		for offset: Vector2 in RUST_OFFSETS:
			CircleDot.draw(canvas, pivot + offset + Vector2(0.0, -8.0 * bubble), 3.5 * (1.0 - bubble), COLOR_ACID_BUBBLE)


static func _shapes_for(
	view_name: String, part_name: String, group: String, variant: int, worn: bool
) -> Array:
	var key: String = "%s/%s/%d/%s" % [view_name, part_name, variant, worn]
	if _baked.has(key):
		return _baked[key]
	var part: Dictionary = _views[view_name]["parts"][part_name]
	var color_map: Dictionary = {}
	var source: Array = (part["shapes"] as Array).duplicate()
	if not group.is_empty():
		var options: Array = _variants[group]
		var chosen: Dictionary = options[posmod(variant, options.size())]
		color_map = chosen["map"]
		var addon: String = chosen["addon"]
		if not addon.is_empty():
			source.append_array(part["addons"][addon] as Array)
	var result: Array = []
	for shape: Dictionary in source:
		result.append(_bake_shape(shape, color_map, worn))
	_baked[key] = result
	return result


## Toda la pieza en una malla: una llamada de dibujo en vez de una por polígono y contorno.
static func _mesh_for(view_name: String, part_name: String, group: String, variant: int, worn: bool) -> ArrayMesh:
	var key: String = "%s/%s/%d/%s" % [view_name, part_name, variant, worn]
	if _meshes.has(key):
		return _meshes[key]
	var batch: PolyBatch = PolyBatch.new()
	for shape: Dictionary in _shapes_for(view_name, part_name, group, variant, worn):
		_add_shape(batch, shape)
	var mesh: ArrayMesh = batch.build()
	_meshes[key] = mesh
	return mesh


static func _add_shape(batch: PolyBatch, shape: Dictionary) -> void:
	if shape.has("line"):
		batch.add_polyline(shape["line"] as PackedVector2Array, shape["color"] as Color, shape["width"] as float)
		return
	batch.add_polygon(shape["points"] as PackedVector2Array, shape["colors"] as PackedColorArray)
	var width: float = shape["width"]
	if width > 0.0:
		batch.add_polyline(shape["outline"] as PackedVector2Array, Palette.INK, width)


static func _swing(part_name: String, walk_phase: float) -> float:
	var wave: float = sin(walk_phase)
	match part_name:
		"leg_left", "arm_main_right":
			return wave * (LEG_SWING if part_name.begins_with("leg") else ARM_SWING)
		"leg_right", "arm_main_left":
			return -wave * (LEG_SWING if part_name.begins_with("leg") else ARM_SWING)
		"arm_extra_left":
			return wave * ARM_SWING * 0.5
		"arm_extra_right":
			return -wave * ARM_SWING * 0.5
	return 0.0


static func _draw_shape(canvas: CanvasItem, shape: Dictionary) -> void:
	if shape.has("line"):
		canvas.draw_polyline(shape["line"] as PackedVector2Array, shape["color"] as Color, shape["width"] as float)
		return
	canvas.draw_polygon(shape["points"] as PackedVector2Array, shape["colors"] as PackedColorArray)
	var width: float = shape["width"]
	if width > 0.0:
		canvas.draw_polyline(shape["outline"] as PackedVector2Array, Palette.INK, width)


## Cola quieta, por rendimiento. Su color sigue indicando qué IA habla.
## P-51: la amplitud y el ancho cambian durante celebrar y provocar.
static func _draw_tail(
	canvas: CanvasItem, facing: Vector2, height_ratio: float, color: Color, pose: Dictionary
) -> void:
	var size: float = CharacterScale.value
	var back: Vector2 = -facing
	var side: Vector2 = back.orthogonal()
	var base: Vector2 = Vector2(0.0, -30.0 * height_ratio * size)
	var amplitude: float = float(pose.get("tail_amplitude", 1.0))
	var width_scale: float = float(pose.get("tail_width_scale", 1.0))
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(TAIL_POINTS):
		var along: float = float(index) * TAIL_STEP
		var sway: float = sin(float(index) * 0.32) * float(index) * 0.75 * amplitude
		points.append(base + (back * along + side * sway) * size)
	for index: int in range(TAIL_POINTS):
		var thick: float = _tail_width(index) * width_scale
		CircleDot.draw(canvas, points[index], (thick + 1.6) * size, Palette.INK)
	for index: int in range(TAIL_POINTS):
		var lit: bool = index / 4 % 2 == 0
		var thick: float = _tail_width(index) * width_scale
		CircleDot.draw(canvas, points[index], thick * size, color if lit else TAIL_DARK)
		if lit and index % 4 == 2:
			CircleDot.draw(canvas, points[index], thick * 0.3 * size, Color.WHITE)


static func _tail_width(index: int) -> float:
	var ratio: float = float(index) / float(TAIL_POINTS - 1)
	return TAIL_WIDTH * (1.0 - 0.75 * pow(ratio, 1.4))


static func _ensure_loaded() -> void:
	if not _views.is_empty():
		return
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	_views = source["views"]
	_variants = source["variants"]


static func _bake_shape(shape: Dictionary, color_map: Dictionary, worn: bool) -> Dictionary:
	if shape.has("line"):
		return {
			"line": _points(shape["line"] as Array),
			"color": _color(shape["c"] as String, color_map, worn),
			"width": shape["w"] as float,
		}
	var points: PackedVector2Array = _points(shape["p"] as Array)
	var outline: PackedVector2Array = points.duplicate()
	outline.append(points[0])
	return {
		"points": points,
		"colors": _vertex_colors(shape, points, color_map, worn),
		"outline": outline,
		"width": shape["o"] as float,
	}


static func _vertex_colors(
	shape: Dictionary, points: PackedVector2Array, color_map: Dictionary, worn: bool
) -> PackedColorArray:
	var top: float = points[0].y
	var bottom: float = points[0].y
	for point: Vector2 in points:
		top = minf(top, point.y)
		bottom = maxf(bottom, point.y)
	var upper: Color
	var lower: Color
	if shape.has("g"):
		upper = _color(shape["g"][0] as String, color_map, worn)
		lower = _color(shape["g"][1] as String, color_map, worn)
	else:
		upper = _color(shape["c"] as String, color_map, worn)
		lower = upper
	var alpha: float = shape.get("a", 1.0)
	upper.a = alpha
	lower.a = alpha
	var colors: PackedColorArray = PackedColorArray()
	for point: Vector2 in points:
		colors.append(upper.lerp(lower, (point.y - top) / maxf(bottom - top, 1.0)))
	return colors


static func _color(value: String, color_map: Dictionary, worn: bool) -> Color:
	var color: Color = Color(color_map.get(value, value) as String)
	return color.lerp(WORN_TINT, WORN_MIX) if worn else color


static func _points(source: Array) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for pair: Array in source:
		result.append(_vector(pair))
	return result


static func _vector(pair: Array) -> Vector2:
	return Vector2(pair[0] as float, pair[1] as float)
