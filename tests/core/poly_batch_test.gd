extends GdUnitTestSuite


func _vertex_count(batch: PolyBatch) -> int:
	var mesh: ArrayMesh = batch.build()
	return 0 if mesh.get_surface_count() == 0 else mesh.surface_get_array_len(0)


func test_empty_batch_builds_an_empty_mesh() -> void:
	assert_int(PolyBatch.new().build().get_surface_count()).is_equal(0)


func test_rect_is_two_triangles() -> void:
	var batch: PolyBatch = PolyBatch.new()
	batch.add_rect(Rect2(0.0, 0.0, 10.0, 10.0), Color.RED)
	assert_int(_vertex_count(batch)).is_equal(6)


func test_polygon_keeps_its_triangles() -> void:
	var batch: PolyBatch = PolyBatch.new()
	var square: PackedVector2Array = PackedVector2Array([
		Vector2.ZERO, Vector2(10.0, 0.0), Vector2(10.0, 10.0), Vector2(0.0, 10.0),
	])
	batch.add_polygon(square, PackedColorArray([Color.WHITE]))
	assert_int(_vertex_count(batch)).is_equal(6)


func test_polyline_makes_a_quad_per_segment() -> void:
	var batch: PolyBatch = PolyBatch.new()
	batch.add_polyline(PackedVector2Array([Vector2.ZERO, Vector2(10.0, 0.0), Vector2(20.0, 5.0)]), Color.RED, 2.0)
	assert_int(_vertex_count(batch)).is_equal(12)


func test_many_shapes_end_in_one_surface() -> void:
	var batch: PolyBatch = PolyBatch.new()
	for index: int in range(20):
		batch.add_rect(Rect2(float(index), 0.0, 1.0, 1.0), Color.BLUE)
	assert_int(batch.build().get_surface_count()).is_equal(1)
