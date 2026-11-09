extends GdUnitTestSuite

const STEP: float = 1.0 / 60.0


func test_recorre_la_distancia_y_termina() -> void:
	var knockback: Knockback = Knockback.new()
	knockback.start(Vector2.RIGHT * 7.0)
	var moved: Vector2 = Vector2.ZERO
	while knockback.is_active():
		moved += knockback.tick(STEP) * STEP
	assert_float(moved.x).is_equal_approx(Knockback.DISTANCE, Knockback.DISTANCE * 0.11)
	assert_float(moved.y).is_equal(0.0)


func test_sin_direccion_no_empieza() -> void:
	var knockback: Knockback = Knockback.new()
	knockback.start(Vector2.ZERO)
	assert_bool(knockback.is_active()).is_false()
