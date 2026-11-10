extends GdUnitTestSuite

var _motion_anterior: bool = false


func before_test() -> void:
	_motion_anterior = GameSettings.reduce_motion
	GameSettings.reduce_motion = false


func after_test() -> void:
	GameSettings.reduce_motion = _motion_anterior


func test_los_edificios_son_los_rectangulos_reales_de_la_zona() -> void:
	var vista: StrategyView = auto_free(StrategyView.new())
	var rects: Array[Rect2] = vista.building_rects()
	assert_int(rects.size()).is_equal(4)
	for esperado: Rect2 in [
		BetaLayout.central_facade,
		BetaLayout.depot_facade,
		BetaLayout.jub_home,
		BetaLayout.moho_home,
	]:
		assert_bool(rects.has(esperado)).is_true()
		assert_bool(BetaLayout.floor_rect.encloses(esperado)).is_true()


func test_la_ayuda_dice_esc_y_no_m_para_salir() -> void:
	var texto: String = StrategyView.help_text(2.0)
	assert_str(texto).contains("Esc: salir")
	assert_bool(texto.contains("M: salir")).is_false()
	assert_str(texto).contains("x2")


func test_el_zoom_min_permite_ver_la_ciudad_completa() -> void:
	assert_bool(
		StrategyView.VIEW.y / StrategyView.ZOOM_MIN >= BetaLayout.city.size.y
	).is_true()


func test_el_pulso_aleja_el_zoom_y_decae_en_tiempo_real() -> void:
	var vista: StrategyView = auto_free(StrategyView.new())
	vista.pulse()
	assert_float(vista.pulse_level()).is_equal(1.0)
	## lerpf y la resta dejan un ULP de diferencia: comparar floats requiere aproximacion.
	assert_float(StrategyView.zoom_with_pulse(1.9, vista.pulse_level())).is_equal_approx(
		StrategyView.ZOOM_MIN, 0.0001
	)
	vista.tick_pulse(0.2)
	assert_float(vista.pulse_level()).is_equal_approx(0.5, 0.0001)
	assert_bool(vista.pulse_level() < 1.0).is_true()


func test_con_movimiento_reducido_no_hay_alejazo() -> void:
	GameSettings.reduce_motion = true
	var vista: StrategyView = auto_free(StrategyView.new())
	vista.pulse()
	assert_float(vista.pulse_level()).is_equal(0.0)
	assert_float(StrategyView.zoom_with_pulse(1.9, 0.0)).is_equal(1.9)
