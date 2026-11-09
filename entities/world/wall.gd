class_name Wall
extends StaticBody2D
## Pared, cobertura baja o puerta provisional.
## Su origen es el borde inferior de la huella, para el orden Y.

const FADED_ALPHA: float = 0.45
const COLOR_ROOF: Color = Color("#75668f")
const COLOR_FRONT_LIGHT: Color = Color("#7a5ea6")
const COLOR_LOW_TOP: Color = Color("#c07a40")
const COLOR_DARK_WINDOW: Color = Color("#120a1e")
const RIM_COLOR: Color = Color(0.0, 0.9, 1.0, 0.7)
const OUTLINE: float = 2.5
const PATCH_SPACING: float = 40.0
const HAZARD_WIDTH: float = 14.0
const WINDOW_SPACING: float = 70.0
const WINDOW_SIZE: Vector2 = Vector2(26.0, 22.0)
const MIN_BLOCK_WIDTH: float = 110.0
const MAX_BLOCK_WIDTH: float = 240.0
const MAX_EXTRA_HEIGHT: float = 30.0
const BLOCK_SCHEMES: Array[Array] = [
	[Color("#7a5ea6"), Color("#3a1a5c"), Color("#75668f")],
	[Color("#5f90c6"), Color("#26325c"), Color("#6a7fa8")],
	[Color("#d36b36"), Color("#592420"), Color("#8a6f60")],
	[Color("#b86a9e"), Color("#452050"), Color("#7f6a88")],
]
const TREE_FOOTPRINT: Vector2 = Vector2(44.0, 44.0)
const TREE_VISUAL_MARGIN: Vector2 = Vector2(40.0, 120.0)
const COLOR_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.35)
const SHADOW_HEIGHT: float = 14.0
const CHARACTER_WIDTH: float = 36.0

enum Kind { SOLID, LOW, DOOR }

var footprint: Rect2
var front_height: float
var kind: Kind = Kind.SOLID
var is_open: bool = false
var label_key: String = ""

var _collider: CollisionShape2D
var _mesh: ArrayMesh


func setup(new_footprint: Rect2, new_front_height: float, new_kind: Kind = Kind.SOLID) -> void:
	footprint = new_footprint
	front_height = new_front_height
	kind = new_kind
	position = Vector2(footprint.position.x, footprint.end.y)
	collision_layer = PhysicsLayers.LOW_COVER if kind == Kind.LOW else PhysicsLayers.WALLS
	collision_mask = 0
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = footprint.size
	_collider = CollisionShape2D.new()
	_collider.shape = shape
	_collider.position = Vector2(footprint.size.x * 0.5, -footprint.size.y * 0.5)
	add_child(_collider)


func _draw() -> void:
	if is_open:
		return
	if is_tree():
		_draw_tree()
		return
	if _mesh == null:
		_mesh = _build_mesh()
	draw_mesh(_mesh, null)


## Toda la pared en una malla, hecha una vez: su aspecto solo depende de la huella.
func _build_mesh() -> ArrayMesh:
	var batch: PolyBatch = PolyBatch.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(footprint.position)
	batch.add_rect(Rect2(0.0, 0.0, footprint.size.x, SHADOW_HEIGHT), COLOR_SHADOW)
	if kind == Kind.SOLID and footprint.size.x >= MIN_BLOCK_WIDTH:
		_add_blocks(batch, rng)
	else:
		_add_block(batch, Rect2(0.0, 0.0, footprint.size.x, 0.0), 0.0, _kind_colors(), rng)
	return batch.build()


## Trocea una muralla larga en edificios distintos, cada uno con su altura y color.
func _add_blocks(batch: PolyBatch, rng: RandomNumberGenerator) -> void:
	var x: float = 0.0
	while x < footprint.size.x:
		var block: float = minf(rng.randf_range(MIN_BLOCK_WIDTH, MAX_BLOCK_WIDTH), footprint.size.x - x)
		if footprint.size.x - x - block < MIN_BLOCK_WIDTH:
			block = footprint.size.x - x
		var scheme: Array = BLOCK_SCHEMES[rng.randi_range(0, BLOCK_SCHEMES.size() - 1)]
		_add_block(batch, Rect2(x, 0.0, block, 0.0), rng.randf_range(0.0, MAX_EXTRA_HEIGHT), scheme, rng)
		x += block


func _add_block(batch: PolyBatch, slot: Rect2, extra: float, colors: Array, rng: RandomNumberGenerator) -> void:
	var height: float = front_height + extra
	var depth: float = footprint.size.y
	var front: Rect2 = Rect2(slot.position.x, -height, slot.size.x, height)
	var top: Rect2 = Rect2(slot.position.x, -height - depth, slot.size.x, depth)
	batch.add_gradient(front, colors[0], colors[1])
	batch.add_rect(top, colors[2])
	batch.add_rect(top.grow(-5.0), colors[2].darkened(0.28))
	_add_face_details(batch, front, rng)
	if kind == Kind.SOLID and slot.size.x >= MIN_BLOCK_WIDTH:
		_add_roof_details(batch, top, rng)
	batch.add_rect_outline(front, Palette.INK, OUTLINE)
	batch.add_rect_outline(top, Palette.INK, OUTLINE)
	batch.add_line(front.position, Vector2(front.end.x, front.position.y), RIM_COLOR, 2.0)


func _add_roof_details(batch: PolyBatch, top: Rect2, rng: RandomNumberGenerator) -> void:
	var box: Rect2 = Rect2(
		Vector2(rng.randf_range(top.position.x + 10.0, top.end.x - 34.0), top.position.y + 8.0),
		Vector2(24.0, maxf(top.size.y - 18.0, 6.0))
	)
	batch.add_rect(box, Palette.HIERRO)
	batch.add_rect_outline(box, Palette.INK, 2.0)
	if rng.randf() < 0.35:
		var sign_rect: Rect2 = Rect2(top.position.x + 8.0, top.end.y - 7.0, 46.0, 7.0)
		batch.add_rect(sign_rect, Palette.NEONES[rng.randi_range(0, 3)])


## Los árboles del escenario son paredes cuadradas de este tamaño.
func is_tree() -> bool:
	return kind == Kind.SOLID and footprint.size.is_equal_approx(TREE_FOOTPRINT)


func _kind_colors() -> Array[Color]:
	match kind:
		Kind.LOW:
			return [Palette.OXIDO, Palette.OXIDO_OSCURO, COLOR_LOW_TOP]
		Kind.DOOR:
			return [Palette.BUTANO, Palette.OXIDO_OSCURO, Palette.OBRA]
	return [COLOR_FRONT_LIGHT, Palette.MORA, COLOR_ROOF]


func _add_face_details(batch: PolyBatch, front: Rect2, rng: RandomNumberGenerator) -> void:
	for _index: int in range(int(front.size.x / PATCH_SPACING)):
		var patch: Vector2 = Vector2(rng.randf_range(8.0, 34.0), rng.randf_range(4.0, 12.0))
		var corner: Vector2 = front.position + Vector2(
			rng.randf_range(0.0, maxf(front.size.x - patch.x, 0.0)),
			rng.randf_range(0.0, maxf(front.size.y - patch.y, 0.0))
		)
		var color: Color = Palette.OXIDO if rng.randf() < 0.4 else Palette.INK
		color.a = 0.35
		batch.add_rect(Rect2(corner, patch), color)
	if kind == Kind.DOOR:
		_add_hazard_stripes(batch, front)
	elif kind == Kind.SOLID and front.size.x >= WINDOW_SPACING:
		_add_windows(batch, front, rng)


func _add_hazard_stripes(batch: PolyBatch, front: Rect2) -> void:
	var x: float = front.position.x
	while x < front.end.x:
		var stripe: float = minf(HAZARD_WIDTH, front.end.x - x)
		batch.add_rect(Rect2(x, front.position.y + 8.0, stripe, front.size.y - 16.0), Palette.INK)
		x += HAZARD_WIDTH * 2.0


func _add_windows(batch: PolyBatch, front: Rect2, rng: RandomNumberGenerator) -> void:
	var x: float = front.position.x + WINDOW_SPACING * 0.3
	while x + WINDOW_SIZE.x < front.end.x:
		var window: Rect2 = Rect2(Vector2(x, front.position.y + 10.0), WINDOW_SIZE)
		var lit: bool = rng.randf() < 0.4
		batch.add_rect(window, Palette.NEONES[rng.randi_range(0, 3)] if lit else COLOR_DARK_WINDOW)
		batch.add_rect_outline(window, Palette.INK, 2.0)
		batch.add_line(window.get_center() + Vector2.UP * 10.0, window.get_center() + Vector2.DOWN * 10.0, Palette.INK, 1.5)
		x += WINDOW_SPACING


func _draw_tree() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(footprint.position)
	var center: float = footprint.size.x * 0.5
	CircleDot.draw(self, Vector2(center, 2.0), 30.0, COLOR_SHADOW)
	draw_rect(Rect2(center - 9.0, -46.0, 18.0, 46.0), Palette.OXIDO_OSCURO)
	draw_rect(Rect2(center - 9.0, -46.0, 18.0, 46.0), Palette.INK, false, OUTLINE)
	var mushroom: bool = rng.randf() < 0.3
	var color: Color = Palette.ROSA if mushroom else (Palette.MOHO if rng.randf() < 0.6 else Palette.BERENJENA)
	for _index: int in range(1 if mushroom else 6):
		var offset: Vector2 = Vector2.ZERO if mushroom else Vector2(rng.randf_range(-26.0, 26.0), rng.randf_range(-18.0, 18.0))
		var radius: float = 42.0 if mushroom else rng.randf_range(20.0, 30.0)
		var spot: Vector2 = Vector2(center, -70.0) + offset
		CircleDot.draw(self, spot, radius + 3.0, Palette.INK)
		CircleDot.draw(self, spot, radius, color.darkened(rng.randf_range(0.0, 0.3)))
	if mushroom:
		for _index: int in range(6):
			CircleDot.draw(self, Vector2(center + rng.randf_range(-28.0, 28.0), -70.0 + rng.randf_range(-24.0, 16.0)), rng.randf_range(4.0, 8.0), Palette.HUESO)


func set_open(value: bool) -> void:
	is_open = value
	_collider.set_deferred(&"disabled", value)
	queue_redraw()


## Rectángulo visible: huella elevada más frente.
func visual_rect() -> Rect2:
	if is_tree():
		return footprint.grow_individual(TREE_VISUAL_MARGIN.x, TREE_VISUAL_MARGIN.y, TREE_VISUAL_MARGIN.x, 0.0)
	return footprint.grow_side(SIDE_TOP, front_height + (MAX_EXTRA_HEIGHT if kind == Kind.SOLID else 0.0))


## Atenúa la pared si tapa a alguien que está detrás de ella.
func update_occlusion(character_feet: Vector2, character_height: float) -> void:
	var base_y: float = footprint.end.y
	var fade: bool = hides_character(visual_rect(), base_y, character_feet, character_height)
	modulate.a = FADED_ALPHA if fade else 1.0


static func hides_character(
	visible_area: Rect2, base_y: float, feet: Vector2, height: float
) -> bool:
	var width: float = CHARACTER_WIDTH
	var character: Rect2 = Rect2(feet.x - width * 0.5, feet.y - height, width, height)
	return feet.y < base_y and visible_area.intersects(character)
