class_name PolyBatch
extends RefCounted
## Junta muchas formas de color en una sola malla, para dibujarlas con una llamada.
## Dibuja lo mismo que draw_polygon, draw_polyline y draw_rect (medido en docs/adr/0017).

var _vertices: PackedVector2Array = PackedVector2Array()
var _colors: PackedColorArray = PackedColorArray()


func is_empty() -> bool:
	return _vertices.is_empty()


## colors admite un color por punto o uno solo para todos.
func add_polygon(points: PackedVector2Array, colors: PackedColorArray) -> void:
	var triangles: PackedInt32Array = Geometry2D.triangulate_polygon(points)
	for index: int in triangles:
		_vertices.append(points[index])
		_colors.append(colors[index if colors.size() > 1 else 0])


func add_polyline(points: PackedVector2Array, color: Color, width: float) -> void:
	if points.size() < 2:
		return
	var half: float = width * 0.5
	var previous_left: Vector2 = Vector2.ZERO
	var previous_right: Vector2 = Vector2.ZERO
	for index: int in range(points.size()):
		var side: Vector2 = _side_at(points, index) * half
		var left: Vector2 = points[index] + side
		var right: Vector2 = points[index] - side
		if index > 0:
			_add_quad(previous_left, left, right, previous_right, color, color)
		previous_left = left
		previous_right = right


func add_line(from: Vector2, to: Vector2, color: Color, width: float) -> void:
	add_polyline(PackedVector2Array([from, to]), color, width)


func add_rect(area: Rect2, color: Color) -> void:
	add_gradient(area, color, color)


func add_gradient(area: Rect2, upper: Color, lower: Color) -> void:
	var top_right: Vector2 = Vector2(area.end.x, area.position.y)
	var bottom_left: Vector2 = Vector2(area.position.x, area.end.y)
	_add_quad(area.position, top_right, area.end, bottom_left, upper, lower)


func add_rect_outline(area: Rect2, color: Color, width: float) -> void:
	var outer: Rect2 = area.grow(width * 0.5)
	var inner: Rect2 = area.grow(-width * 0.5)
	add_rect(Rect2(outer.position, Vector2(outer.size.x, width)), color)
	add_rect(Rect2(outer.position.x, inner.end.y, outer.size.x, width), color)
	add_rect(Rect2(outer.position.x, inner.position.y, width, inner.size.y), color)
	add_rect(Rect2(inner.end.x, inner.position.y, width, inner.size.y), color)


func build() -> ArrayMesh:
	var mesh: ArrayMesh = ArrayMesh.new()
	if is_empty():
		return mesh
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = _vertices
	arrays[Mesh.ARRAY_COLOR] = _colors
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


## Perpendicular promediada en cada punto, para que los tramos queden unidos.
func _side_at(points: PackedVector2Array, index: int) -> Vector2:
	var before: Vector2 = points[index] - points[maxi(index - 1, 0)]
	var after: Vector2 = points[mini(index + 1, points.size() - 1)] - points[index]
	var direction: Vector2 = (before.normalized() + after.normalized()).normalized()
	return direction.orthogonal()


func _add_quad(a: Vector2, b: Vector2, c: Vector2, d: Vector2, upper: Color, lower: Color) -> void:
	_vertices.append_array(PackedVector2Array([a, b, c, a, c, d]))
	_colors.append_array(PackedColorArray([upper, upper, lower, upper, lower, lower]))
