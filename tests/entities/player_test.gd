extends GdUnitTestSuite


func test_eight_directions() -> void:
	assert_int(Player.octant_of(Vector2.RIGHT)).is_equal(0)
	assert_int(Player.octant_of(Vector2(1.0, 1.0).normalized())).is_equal(1)
	assert_int(Player.octant_of(Vector2.DOWN)).is_equal(2)
	assert_int(Player.octant_of(Vector2.LEFT)).is_equal(4)
	assert_int(Player.octant_of(Vector2.UP)).is_equal(6)
	assert_int(Player.octant_of(Vector2(1.0, -1.0).normalized())).is_equal(7)
