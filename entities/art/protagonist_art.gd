class_name ProtagonistArt
extends RefCounted
## Dibuja al protagonista con polígonos de Godot, por piezas independientes.
## Los datos salen de tools/art/protagonist_gen.py, calcado de la hoja de diseño.

const DATA_PATH: String = "res://data/art/protagonista.json"
## Pasa de las coordenadas de la hoja a píxeles de juego.
const ART_SCALE: float = 0.085
const WORN_RATIO: float = 0.35
const WORN_TINT: Color = Color("#ff4a3a")
const WORN_MIX: float = 0.55
const LEG_SWING: float = 0.2
const ARM_SWING: float = 0.12
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.4)
const TAIL_POINTS: int = 22
const TAIL_STEP: float = 3.6
const TAIL_WIDTH: float = 8.0
const TAIL_DARK: Color = Color("#1a1450")

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


static func draw(
	canvas: CanvasItem,
	facing: Vector2,
	height_ratio: float,
	body: ModularBody,
	tail_color: Color,
	tail_speaking: bool,
	walk_phase: float,
	squash: Vector2 = Vector2.ONE
) -> void:
	_ensure_loaded()
	var view_name: String = view_for(facing)
	var away: bool = VIEWS_FROM_BEHIND.has(view_name)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	canvas.draw_circle(Vector2(0.0, 3.0), 22.0, SHADOW_COLOR)
	if not away:
		_draw_tail(canvas, facing, height_ratio, tail_color, tail_speaking)
	var bob: float = -absf(sin(walk_phase)) * 1.5
	var base: Transform2D = Transform2D(
		0.0, Vector2(ART_SCALE * squash.x, ART_SCALE * height_ratio * squash.y), 0.0, Vector2(0.0, bob)
	)
	var view: Dictionary = _views[view_name]
	for part_name: String in view["order"]:
		_draw_part(canvas, view_name, part_name, base, body, walk_phase)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	if away:
		_draw_tail(canvas, facing, height_ratio, tail_color, tail_speaking)


## Vista de las 8 que corresponde a una dirección.
static func view_for(facing: Vector2) -> String:
	return VIEWS[wrapi(roundi(facing.angle() / (PI / 4.0)), 0, VIEWS.size())]


static func _draw_part(
	canvas: CanvasItem, view_name: String, part_name: String,
	base: Transform2D, body: ModularBody, walk_phase: float
) -> void:
	var worn: bool = false
	var variant: int = 0
	var group: String = ""
	if PART_SLOTS.has(part_name):
		var piece: BodyPiece = body.equipped(PART_SLOTS[part_name] as ModularBody.Slot)
		if piece == null:
			return
		worn = piece.durability / BodyPiece.MAX_DURABILITY < WORN_RATIO
		variant = piece.visual_variant
		group = VARIANT_GROUPS[piece.kind]
	var part: Dictionary = _views[view_name]["parts"][part_name]
	var pivot: Vector2 = _vector(part["pivot"] as Array)
	var rotation: Transform2D = Transform2D(_swing(part_name, walk_phase), Vector2.ZERO)
	canvas.draw_set_transform_matrix(
		base * Transform2D(0.0, pivot) * rotation * Transform2D(0.0, -pivot)
	)
	for shape: Dictionary in _shapes_for(view_name, part_name, group, variant, worn):
		_draw_shape(canvas, shape)


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


static func _draw_tail(
	canvas: CanvasItem, facing: Vector2, height_ratio: float, color: Color, speaking: bool
) -> void:
	var back: Vector2 = -facing
	var side: Vector2 = back.orthogonal()
	var base: Vector2 = Vector2(0.0, -30.0 * height_ratio)
	var clock: float = Time.get_ticks_msec() * 0.003
	var pulse: float = 1.0 + (0.25 * sin(clock * 6.0) if speaking else 0.0)
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(TAIL_POINTS):
		var along: float = float(index) * TAIL_STEP
		var sway: float = sin(float(index) * 0.32 + clock) * float(index) * 0.75
		points.append(base + back * along + side * sway)
	var glow: Color = color
	glow.a = 0.18 * pulse
	canvas.draw_polyline(points, glow, TAIL_WIDTH * 3.4)
	for index: int in range(TAIL_POINTS):
		canvas.draw_circle(points[index], _tail_width(index, pulse) + 1.6, Palette.INK)
	for index: int in range(TAIL_POINTS):
		var lit: bool = (index + int(clock * 3.0)) / 4 % 2 == 0
		canvas.draw_circle(points[index], _tail_width(index, pulse), color if lit else TAIL_DARK)
		if lit and index % 4 == 2:
			var spark: float = _tail_width(index, pulse) * 0.7
			canvas.draw_line(points[index] + Vector2.LEFT * spark, points[index] + Vector2.RIGHT * spark, Color.WHITE, 1.2)
			canvas.draw_line(points[index] + Vector2.UP * spark, points[index] + Vector2.DOWN * spark, Color.WHITE, 1.2)


static func _tail_width(index: int, pulse: float) -> float:
	var ratio: float = float(index) / float(TAIL_POINTS - 1)
	return TAIL_WIDTH * pulse * (1.0 - 0.75 * pow(ratio, 1.4))


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
