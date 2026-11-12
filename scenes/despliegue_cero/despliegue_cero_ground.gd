class_name BetaGround
extends RefCounted
## Pinta el suelo de la beta con formas de Godot: bosque, ciudad y tierra de nadie.
## Usa semilla propia para no tocar el generador de la partida.

const SEED: int = 1983
## Con preload porque el dibujo no retiene la textura: cargada dentro de _draw se libera
## al acabar la función y el suelo sale blanco.
const TEXTURE_FOREST: Texture2D = preload("res://art/shared/suelo_bosque.png")
const TEXTURE_CITY: Texture2D = preload("res://art/shared/suelo_ciudad.png")
const TEXTURE_MUD: Texture2D = preload("res://art/shared/suelo_barro.png")
const CRACK_COUNT: int = 150
const CRATER_COUNT: int = 26
const PUDDLE_COUNT: int = 16
const STREET_LINE_GAP: float = 70.0

## El dibujo no retiene las mallas: si se sueltan, el suelo se queda sin detalles.
static var _meshes: Array[ArrayMesh] = []


static func paint(canvas: CanvasItem) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var city: Rect2 = DespliegueCeroLayout.city
	var strip: Rect2 = DespliegueCeroLayout.no_mans_land
	canvas.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	canvas.draw_texture_rect(TEXTURE_FOREST, DespliegueCeroLayout.floor_rect, true)
	canvas.draw_texture_rect(TEXTURE_CITY, city, true)
	var under_mud: PolyBatch = PolyBatch.new()
	_street_lines(under_mud, city, strip)
	_cracks(under_mud, rng, city)
	_meshes = [under_mud.build()]
	canvas.draw_mesh(_meshes[0], null)
	canvas.draw_texture_rect(TEXTURE_MUD, strip, true)
	var over_mud: PolyBatch = PolyBatch.new()
	_craters(over_mud, rng, strip)
	_puddles(over_mud, rng, city)
	_meshes.append(over_mud.build())
	canvas.draw_mesh(_meshes[1], null)


static func _blob(rng: RandomNumberGenerator, center: Vector2, radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(9):
		var angle: float = TAU * float(index) / 9.0
		var reach: float = radius * rng.randf_range(0.7, 1.15)
		points.append(center + Vector2(cos(angle) * reach, sin(angle) * reach * 0.62))
	return points


static func _street_lines(batch: PolyBatch, city: Rect2, strip: Rect2) -> void:
	var x: float = 2010.0
	var y: float = city.position.y
	while y < city.end.y:
		if y < strip.position.y or y > strip.end.y:
			batch.add_line(Vector2(x, y), Vector2(x, y + 36.0), Palette.OBRA, 4.0)
		y += STREET_LINE_GAP


static func _cracks(batch: PolyBatch, rng: RandomNumberGenerator, area: Rect2) -> void:
	for _index: int in range(CRACK_COUNT):
		var point: Vector2 = Vector2(
			rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y)
		)
		var line: PackedVector2Array = PackedVector2Array([point])
		for _step: int in range(5):
			point += Vector2(rng.randf_range(-22.0, 22.0), rng.randf_range(6.0, 26.0))
			line.append(point)
		batch.add_polyline(line, Palette.INK, 2.5)


static func _craters(batch: PolyBatch, rng: RandomNumberGenerator, area: Rect2) -> void:
	for _index: int in range(CRATER_COUNT):
		var center: Vector2 = Vector2(
			rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y)
		)
		var radius: float = rng.randf_range(24.0, 48.0)
		batch.add_polygon(_blob(rng, center, radius * 1.25), PackedColorArray([Palette.OXIDO_OSCURO]))
		batch.add_polygon(_blob(rng, center, radius * 0.9), PackedColorArray([Palette.INK]))


static func _puddles(batch: PolyBatch, rng: RandomNumberGenerator, area: Rect2) -> void:
	for _index: int in range(PUDDLE_COUNT):
		var center: Vector2 = Vector2(
			rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y)
		)
		var color: Color = Palette.NEONES[rng.randi_range(0, Palette.NEONES.size() - 1)]
		var points: PackedVector2Array = _blob(rng, center, rng.randf_range(24.0, 48.0))
		batch.add_polygon(points, PackedColorArray([color]))
		var outline: PackedVector2Array = points.duplicate()
		outline.append(points[0])
		batch.add_polyline(outline, Palette.INK, 3.0)
