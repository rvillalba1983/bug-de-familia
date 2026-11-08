extends GdUnitTestSuite

const AREA: Rect2 = Rect2(100.0, 100.0, 200.0, 90.0)
const BASE_Y: float = 190.0
const HEIGHT: float = 60.0


func test_character_behind_wall_is_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(200.0, 170.0), HEIGHT)).is_true()


func test_character_with_only_legs_covered_is_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(200.0, 105.0), HEIGHT)).is_true()


func test_character_in_front_is_not_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(200.0, 200.0), HEIGHT)).is_false()


func test_character_beside_wall_is_not_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(400.0, 170.0), HEIGHT)).is_false()
