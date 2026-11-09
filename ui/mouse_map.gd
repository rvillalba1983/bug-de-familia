class_name MouseMap
extends Control
## Dibujo del ratón con lo que hace cada botón.

const BODY: Rect2 = Rect2(0.0, 40.0, 130.0, 210.0)
const COLOR_BODY: Color = Color("#3a404c")
const COLOR_BUTTON: Color = Color("#ffcf40")
const COLOR_WHEEL: Color = Color("#ff9a3c")
const COLOR_INK: Color = Color("#1b0e2a")
const TEXT_X: float = 160.0
const TEXT_WIDTH: float = 280.0
const FONT_SIZE: int = 20


func _draw() -> void:
	var font: Font = UiStyle.FONT_LOUD
	var points: PackedVector2Array = PackedVector2Array()
	var center: Vector2 = BODY.get_center()
	for index: int in range(40):
		var angle: float = TAU * float(index) / 40.0
		points.append(center + Vector2(cos(angle), sin(angle)) * BODY.size * 0.5)
	draw_colored_polygon(points, COLOR_BODY)
	var split: float = center.y - 30.0
	var left: PackedVector2Array = PackedVector2Array([Vector2(center.x, BODY.position.y)])
	var right: PackedVector2Array = PackedVector2Array([Vector2(center.x, BODY.position.y)])
	for point: Vector2 in points:
		if point.y <= split:
			(left if point.x <= center.x else right).append(point)
	left.append(Vector2(center.x, split))
	right.append(Vector2(center.x, split))
	for side: PackedVector2Array in [left, right]:
		if Geometry2D.triangulate_polygon(_sorted(side, center)).size() > 0:
			draw_colored_polygon(_sorted(side, center), COLOR_BUTTON)
	draw_rect(Rect2(center.x - 12.0, BODY.position.y + 24.0, 24.0, 54.0), COLOR_WHEEL)
	points.append(points[0])
	draw_polyline(points, COLOR_INK, 3.0)
	draw_line(Vector2(center.x, BODY.position.y), Vector2(center.x, split), COLOR_INK, 3.0)
	draw_line(Vector2(BODY.position.x + 8.0, split), Vector2(BODY.end.x - 8.0, split), COLOR_INK, 3.0)
	var y: float = 30.0
	for row: Variant in ControlsPanel.load_rows("mouse"):
		draw_string(font, Vector2(TEXT_X, y), str(row[0]), HORIZONTAL_ALIGNMENT_LEFT, TEXT_WIDTH, FONT_SIZE, COLOR_BUTTON)
		var text: String = str(row[1])
		draw_multiline_string(font, Vector2(TEXT_X, y + 26.0), text, HORIZONTAL_ALIGNMENT_LEFT, TEXT_WIDTH, FONT_SIZE - 2, 4, Color.WHITE)
		y += 62.0 + 22.0 * floorf(float(text.length()) / 28.0)


func _sorted(points: PackedVector2Array, center: Vector2) -> PackedVector2Array:
	var list: Array = Array(points)
	var anchor: Vector2 = Vector2(center.x, center.y - 30.0)
	var pivot: Vector2 = (anchor + list[0]) * 0.5 + Vector2(1.0 if list[1].x > center.x else -1.0, 0.0) * 20.0
	list.sort_custom(func(a: Vector2, b: Vector2) -> bool: return (a - pivot).angle() < (b - pivot).angle())
	return PackedVector2Array(list)
