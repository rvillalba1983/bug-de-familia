extends GdUnitTestSuite


func _panel() -> ControlsPanel:
	var pause: TacticalPause = auto_free(TacticalPause.new())
	add_child(pause)
	var panel: ControlsPanel = auto_free(ControlsPanel.new())
	panel.pause = pause
	add_child(panel)
	return panel


func test_la_misma_tecla_abre_pausa_y_cierra() -> void:
	InputBindings.install()
	assert_bool(InputMap.has_action(&"help")).is_true()
	var panel: ControlsPanel = _panel()
	panel.toggle()
	assert_bool(panel.visible).is_true()
	assert_bool(get_tree().paused).is_true()
	panel.toggle()
	assert_bool(panel.visible).is_false()
	assert_bool(get_tree().paused).is_false()


func test_cerrar_no_quita_una_pausa_tactica_previa() -> void:
	var panel: ControlsPanel = _panel()
	panel.pause.set_paused(true)
	panel.toggle()
	panel.toggle()
	assert_bool(get_tree().paused).is_true()
	panel.pause.set_paused(false)


func test_filas_completas() -> void:
	for section: String in ["compact", "full"]:
		var rows: Array = ControlsPanel.load_rows(section)
		assert_int(rows.size()).is_greater(5)
		for row: Variant in rows:
			assert_int((row as Array).size()).is_equal(2)
