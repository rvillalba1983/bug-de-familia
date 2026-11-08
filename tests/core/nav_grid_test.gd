extends GdUnitTestSuite

const AREA: Rect2 = Rect2(0.0, 0.0, 800.0, 480.0)
const BLOCKER: Rect2 = Rect2(300.0, 100.0, 40.0, 300.0)


func test_path_avoids_blocker() -> void:
	var blockers: Array[Rect2] = [BLOCKER]
	var grid: NavGrid = NavGrid.new(AREA, blockers, 16.0)
	var path: PackedVector2Array = grid.find_path(Vector2(100.0, 250.0), Vector2(600.0, 250.0))
	assert_bool(path.is_empty()).is_false()
	for point: Vector2 in path:
		assert_bool(BLOCKER.grow(16.0).has_point(point)).is_false()


func test_goal_inside_blocker_uses_nearest_free_cell() -> void:
	var blockers: Array[Rect2] = [BLOCKER]
	var grid: NavGrid = NavGrid.new(AREA, blockers, 16.0)
	var path: PackedVector2Array = grid.find_path(Vector2(100.0, 250.0), BLOCKER.get_center())
	assert_bool(path.is_empty()).is_false()
	assert_bool(grid.is_walkable(path[path.size() - 1])).is_true()
