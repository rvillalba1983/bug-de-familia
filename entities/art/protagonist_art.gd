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
const FACING_AWAY: float = -0.35
const LEG_SWING: float = 0.2
const ARM_SWING: float = 0.12
const EYE_POSITION: Vector2 = Vector2(147.0, -856.0)
const EYE_COLOR: Color = Color(0.13, 0.83, 1.0, 0.25)
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.4)
const TAIL_POINTS: int = 22
const TAIL_STEP: float = 3.6
const TAIL_WIDTH: float = 8.0
const TAIL_DARK: Color = Color("#1a1450")

const FRONT_ORDER: Array[String] = [
	"arm_extra_left", "arm_extra_right", "leg_left", "leg_right", "torso",
	"arm_main_left", "arm_main_right", "scarf", "head",
]
const BACK_ORDER: Array[String] = [
	"leg_left", "leg_right", "arm_main_left", "arm_main_right", "torso_back",
	"scarf", "head_back", "arm_extra_left", "arm_extra_right",
]
const PART_SLOTS: Dictionary = {
	"arm_extra_left": ModularBody.Slot.ARM_EXTRA_LEFT,
	"arm_extra_right": ModularBody.Slot.ARM_EXTRA_RIGHT,
	"arm_main_left": ModularBody.Slot.ARM_MAIN_LEFT,
	"arm_main_right": ModularBody.Slot.ARM_MAIN_RIGHT,
	"leg_left": ModularBody.Slot.LEG_LEFT,
	"leg_right": ModularBody.Slot.LEG_RIGHT,
}

static var _parts: Dictionary = {}


static func draw(
	canvas: CanvasItem,
	facing: Vector2,
	height_ratio: float,
	body: ModularBody,
	tail_color: Color,
	tail_speaking: bool,
	walk_phase: float
) -> void:
	_ensure_loaded()
	var away: bool = facing.y < FACING_AWAY
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	canvas.draw_circle(Vector2(0.0, 3.0), 22.0, SHADOW_COLOR)
	if not away:
		_draw_tail(canvas, facing, height_ratio, tail_color, tail_speaking)
	var flip: float = -1.0 if facing.x < -0.05 else 1.0
	var bob: float = -absf(sin(walk_phase)) * 1.5
	var base: Transform2D = Transform2D(
		0.0, Vector2(ART_SCALE * flip, ART_SCALE * height_ratio), 0.0, Vector2(0.0, bob)
	)
	for part_name: String in (BACK_ORDER if away else FRONT_ORDER):
		_draw_part(canvas, part_name, base, body, walk_phase)
	if not away:
		canvas.draw_set_transform_matrix(base)
		canvas.draw_circle(EYE_POSITION, 62.0, EYE_COLOR)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	if away:
		_draw_tail(canvas, facing, height_ratio, tail_color, tail_speaking)


static func _draw_part(
	canvas: CanvasItem, part_name: String, base: Transform2D, body: ModularBody, walk_phase: float
) -> void:
	var worn: bool = false
	if PART_SLOTS.has(part_name):
		var piece: BodyPiece = body.equipped(PART_SLOTS[part_name] as ModularBody.Slot)
		if piece == null:
			return
		worn = piece.durability / BodyPiece.MAX_DURABILITY < WORN_RATIO
	var part: Dictionary = _parts[part_name]
	var pivot: Vector2 = part["pivot"]
	var rotation: Transform2D = Transform2D(_swing(part_name, walk_phase), Vector2.ZERO)
	canvas.draw_set_transform_matrix(
		base * Transform2D(0.0, pivot) * rotation * Transform2D(0.0, -pivot)
	)
	for shape: Dictionary in part["shapes"]:
		_draw_shape(canvas, shape, worn)


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


static func _draw_shape(canvas: CanvasItem, shape: Dictionary, worn: bool) -> void:
	if shape.has("line"):
		canvas.draw_polyline(shape["line"] as PackedVector2Array, shape["color"] as Color, shape["width"] as float)
		return
	var colors: PackedColorArray = shape["worn"] if worn else shape["colors"]
	canvas.draw_polygon(shape["points"] as PackedVector2Array, colors)
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
	if not _parts.is_empty():
		return
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	for part_name: String in source:
		var part: Dictionary = source[part_name]
		var shapes: Array[Dictionary] = []
		for shape: Dictionary in part["shapes"]:
			shapes.append(_bake_shape(shape))
		_parts[part_name] = {"pivot": _vector(part["pivot"] as Array), "shapes": shapes}


static func _bake_shape(shape: Dictionary) -> Dictionary:
	if shape.has("line"):
		return {
			"line": _points(shape["line"] as Array),
			"color": Color(shape["c"] as String),
			"width": shape["w"] as float,
		}
	var points: PackedVector2Array = _points(shape["p"] as Array)
	var colors: PackedColorArray = PackedColorArray()
	var worn: PackedColorArray = PackedColorArray()
	for index: int in range(points.size()):
		var value: String = shape["cs"][index] if shape.has("cs") else shape["c"]
		var color: Color = Color(value)
		colors.append(color)
		worn.append(color.lerp(WORN_TINT, WORN_MIX))
	var outline: PackedVector2Array = points.duplicate()
	outline.append(points[0])
	return {
		"points": points,
		"colors": colors,
		"worn": worn,
		"outline": outline,
		"width": shape["o"] as float,
	}


static func _points(source: Array) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	for pair: Array in source:
		result.append(_vector(pair))
	return result


static func _vector(pair: Array) -> Vector2:
	return Vector2(pair[0] as float, pair[1] as float)
