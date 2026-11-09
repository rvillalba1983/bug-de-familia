extends GdUnitTestSuite


func after_test() -> void:
	Engine.time_scale = 1.0


func test_flash_material_uses_the_flash_shader() -> void:
	var made: ShaderMaterial = ImpactFx.new_flash_material()
	assert_object(made.shader).is_equal(ImpactFx.FLASH_SHADER)


func test_hit_stop_slows_time_and_restores_it() -> void:
	ImpactFx.hit_stop(get_tree(), 0.02)
	assert_float(Engine.time_scale).is_equal_approx(ImpactFx.STOP_SCALE, 0.001)
	await get_tree().create_timer(0.1, true, false, true).timeout
	assert_float(Engine.time_scale).is_equal_approx(1.0, 0.001)


func test_hit_stop_keeps_a_time_scale_changed_meanwhile() -> void:
	ImpactFx.hit_stop(get_tree(), 0.02)
	Engine.time_scale = 6.0
	await get_tree().create_timer(0.1, true, false, true).timeout
	assert_float(Engine.time_scale).is_equal_approx(6.0, 0.001)


func test_camera_shake_moves_and_settles() -> void:
	var camera: CameraZoom = auto_free(CameraZoom.new())
	add_child(camera)
	camera.shake(10.0)
	camera._process(0.016)
	assert_bool(camera.offset != Vector2.ZERO).is_true()
	camera._process(1.0)
	assert_float(camera._shake).is_equal(0.0)
