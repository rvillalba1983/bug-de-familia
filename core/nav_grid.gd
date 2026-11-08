class_name NavGrid
extends RefCounted
## Rutas sobre rejilla para el movimiento con clic.

const CELL_SIZE: float = 16.0

var _grid: AStarGrid2D = AStarGrid2D.new()
var _area: Rect2


## blockers son las huellas sobre el suelo; agent_radius evita rozar paredes.
func _init(area: Rect2, blockers: Array[Rect2], agent_radius: float) -> void:
	_area = area
	var cols: int = int(area.size.x / CELL_SIZE)
	var rows: int = int(area.size.y / CELL_SIZE)
	_grid.region = Rect2i(0, 0, cols, rows)
	_grid.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	_grid.offset = area.position + Vector2(CELL_SIZE, CELL_SIZE) * 0.5
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_grid.update()
	var walkable: Rect2 = area.grow(-agent_radius)
	for x: int in range(cols):
		for y: int in range(rows):
			var id: Vector2i = Vector2i(x, y)
			var point: Vector2 = _grid.get_point_position(id)
			var blocked: bool = _hits(point, blockers, agent_radius)
			_grid.set_point_solid(id, blocked or not walkable.has_point(point))


func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var start: Vector2i = _nearest_free(_to_cell(from))
	var goal: Vector2i = _nearest_free(_to_cell(to))
	if start.x < 0 or goal.x < 0:
		return PackedVector2Array()
	return _grid.get_point_path(start, goal)


func is_walkable(point: Vector2) -> bool:
	var cell: Vector2i = _to_cell(point)
	return _grid.region.has_point(cell) and not _grid.is_point_solid(cell)


func _hits(point: Vector2, blockers: Array[Rect2], agent_radius: float) -> bool:
	for blocker: Rect2 in blockers:
		if blocker.grow(agent_radius).has_point(point):
			return true
	return false


func _to_cell(point: Vector2) -> Vector2i:
	var local: Vector2 = (point - _area.position) / CELL_SIZE
	return Vector2i(
		clampi(int(local.x), 0, _grid.region.size.x - 1),
		clampi(int(local.y), 0, _grid.region.size.y - 1)
	)


func _nearest_free(cell: Vector2i) -> Vector2i:
	var limit: int = maxi(_grid.region.size.x, _grid.region.size.y)
	for radius: int in range(limit):
		for x: int in range(cell.x - radius, cell.x + radius + 1):
			for y: int in range(cell.y - radius, cell.y + radius + 1):
				var id: Vector2i = Vector2i(x, y)
				if _grid.region.has_point(id) and not _grid.is_point_solid(id):
					return id
	return Vector2i(-1, -1)
