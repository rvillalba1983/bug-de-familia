extends GdUnitTestSuite


func test_zoom_stays_within_limits() -> void:
	assert_float(CameraZoom.next_zoom(CameraZoom.MAX_ZOOM, 1.0)).is_equal(CameraZoom.MAX_ZOOM)
	assert_float(CameraZoom.next_zoom(CameraZoom.MIN_ZOOM, -1.0)).is_equal(CameraZoom.MIN_ZOOM)
