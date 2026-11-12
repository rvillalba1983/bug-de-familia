class_name LevelBounds
extends RefCounted
## Colisiones invisibles que rodean el suelo de un nivel.
##
## Los corredores de conexión dejan huecos en el borde: se pasa por ellos a la
## zona vecina en vez de chocar con una pared invisible.

const THICKNESS: float = 64.0


## gaps son rectángulos caminables que llegan al borde y deben quedar abiertos.
static func build(parent: Node, area: Rect2, gaps: Array[Rect2] = []) -> void:
	var t: float = THICKNESS
	for side: Rect2 in _sides(area, gaps, t):
		if side.size.x <= 0.0 or side.size.y <= 0.0:
			continue
		var body: StaticBody2D = StaticBody2D.new()
		body.collision_layer = PhysicsLayers.WALLS
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = side.size
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = shape
		collider.position = side.get_center()
		body.add_child(collider)
		parent.add_child(body)


static func _sides(area: Rect2, gaps: Array[Rect2], t: float) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for north: bool in [true, false]:
		var y: float = area.position.y - t if north else area.end.y
		var edge_y: float = area.position.y if north else area.end.y
		for span: Vector2 in _open_spans(area.position.x, area.end.x, gaps, edge_y, true):
			result.append(Rect2(span.x, y, span.y - span.x, t))
	for west: bool in [true, false]:
		var x: float = area.position.x - t if west else area.end.x
		var edge_x: float = area.position.x if west else area.end.x
		for span: Vector2 in _open_spans(area.position.y, area.end.y, gaps, edge_x, false):
			result.append(Rect2(x, span.x, t, span.y - span.x))
	return result


## Tramos de borde que siguen cerrados, dejando abiertos los corredores.
static func _open_spans(from: float, to: float, gaps: Array[Rect2], edge: float, horizontal: bool) -> Array[Vector2]:
	var cuts: Array[Vector2] = []
	for gap: Rect2 in gaps:
		var near: bool = is_equal_approx(gap.position.y, edge) if horizontal else is_equal_approx(gap.position.x, edge)
		var far: bool = is_equal_approx(gap.end.y, edge) if horizontal else is_equal_approx(gap.end.x, edge)
		if near or far:
			var start: float = gap.position.x if horizontal else gap.position.y
			var end: float = gap.end.x if horizontal else gap.end.y
			cuts.append(Vector2(maxf(start, from), minf(end, to)))
	cuts.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var result: Array[Vector2] = []
	var cursor: float = from
	for cut: Vector2 in cuts:
		if cut.x > cursor:
			result.append(Vector2(cursor, cut.x))
		cursor = maxf(cursor, cut.y)
	if cursor < to:
		result.append(Vector2(cursor, to))
	return result
