class_name BetaGround
extends RefCounted
## Pinta el suelo de la beta con formas de Godot: bosque, ciudad y tierra de nadie.
## Usa semilla propia para no tocar el generador de la partida.

const SEED: int = 1983
const TEXTURE_FOREST: String = "res://art/beta/suelo_bosque.png"
const TEXTURE_CITY: String = "res://art/beta/suelo_ciudad.png"
const TEXTURE_MUD: String = "res://art/beta/suelo_barro.png"
const CRACK_COUNT: int = 150
const CRATER_COUNT: int = 26
const PUDDLE_COUNT: int = 16
const STREET_LINE_GAP: float = 70.0


static func paint(canvas: CanvasItem) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var city: Rect2 = BetaLayout.CITY
	var strip: Rect2 = BetaLayout.NO_MANS_LAND
	canvas.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	canvas.draw_texture_rect(load(TEXTURE_FOREST) as Texture2D, BetaLayout.FLOOR_RECT, true)
	canvas.draw_texture_rect(load(TEXTURE_CITY) as Texture2D, city, true)
	_street_lines(canvas, city, strip)
	_cracks(canvas, rng, city)
	canvas.draw_texture_rect(load(TEXTURE_MUD) as Texture2D, strip, true)
	_craters(canvas, rng, strip)
	_puddles(canvas, rng, city)


static func _blob(rng: RandomNumberGenerator, center: Vector2, radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(9):
		var angle: float = TAU * float(index) / 9.0
		var reach: float = radius * rng.randf_range(0.7, 1.15)
		points.append(center + Vector2(cos(angle) * reach, sin(angle) * reach * 0.62))
	return points


static func _street_lines(canvas: CanvasItem, city: Rect2, strip: Rect2) -> void:
	var x: float = 2010.0
	var y: float = city.position.y
	while y < city.end.y:
		if y < strip.position.y or y > strip.end.y:
			canvas.draw_line(Vector2(x, y), Vector2(x, y + 36.0), Palette.OBRA, 4.0)
		y += STREET_LINE_GAP


static func _cracks(canvas: CanvasItem, rng: RandomNumberGenerator, area: Rect2) -> void:
	for _index: int in range(CRACK_COUNT):
		var point: Vector2 = Vector2(
			rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y)
		)
		var line: PackedVector2Array = PackedVector2Array([point])
		for _step: int in range(5):
			point += Vector2(rng.randf_range(-22.0, 22.0), rng.randf_range(6.0, 26.0))
			line.append(point)
		canvas.draw_polyline(line, Palette.INK, 2.5)


static func _craters(canvas: CanvasItem, rng: RandomNumberGenerator, area: Rect2) -> void:
	for _index: int in range(CRATER_COUNT):
		var center: Vector2 = Vector2(
			rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y)
		)
		var radius: float = rng.randf_range(24.0, 48.0)
		canvas.draw_colored_polygon(_blob(rng, center, radius * 1.25), Palette.OXIDO_OSCURO)
		canvas.draw_colored_polygon(_blob(rng, center, radius * 0.9), Palette.INK)


static func _puddles(canvas: CanvasItem, rng: RandomNumberGenerator, area: Rect2) -> void:
	for _index: int in range(PUDDLE_COUNT):
		var center: Vector2 = Vector2(
			rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y)
		)
		var color: Color = Palette.NEONES[rng.randi_range(0, Palette.NEONES.size() - 1)]
		var points: PackedVector2Array = _blob(rng, center, rng.randf_range(24.0, 48.0))
		canvas.draw_colored_polygon(points, color)
		var outline: PackedVector2Array = points.duplicate()
		outline.append(points[0])
		canvas.draw_polyline(outline, Palette.INK, 3.0)
