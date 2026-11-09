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


func test_nivel_y_especial_se_guardan() -> void:
	var piece: BodyPiece = BodyPiece.new(BodyPiece.Kind.ARM)
	piece.level = 4
	piece.actions = [{"id": "a009", "name": "x", "active": true}]
	var back: BodyPiece = BodyPiece.from_dict(piece.to_dict())
	assert_int(back.level).is_equal(4)
	assert_bool(back.is_special()).is_true()
	assert_bool(BodyPiece.new(BodyPiece.Kind.LEG).is_special()).is_false()


func test_nivel_cubre_toda_la_potencia() -> void:
	assert_int(PieceForge.level_of(PieceForge.MIN_POWER)).is_equal(1)
	assert_int(PieceForge.level_of(PieceForge.MAX_POWER)).is_equal(5)


func _click(card: PieceCard, button: MouseButton) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	card._gui_input(event)


func test_clic_pone_y_clic_derecho_descarta() -> void:
	var card: PieceCard = auto_free(PieceCard.new())
	card.piece = BodyPiece.new(BodyPiece.Kind.ARM)
	var log_calls: Array[String] = []
	card.equip_requested.connect(func() -> void: log_calls.append("poner"))
	card.discard_requested.connect(func() -> void: log_calls.append("descartar"))
	_click(card, MOUSE_BUTTON_LEFT)
	_click(card, MOUSE_BUTTON_RIGHT)
	assert_array(log_calls).is_equal(["poner", "descartar"] as Array[String])
	card.is_worn = true
	_click(card, MOUSE_BUTTON_LEFT)
	assert_int(log_calls.size()).is_equal(2)


func test_opciones_se_guardan_y_quitan_temblores() -> void:
	GameSettings.path = "user://opciones_prueba.cfg"
	GameSettings.reset()
	GameSettings.reduce_motion = true
	GameSettings.text_scale = 1.5
	GameSettings.save()
	GameSettings.reset()
	GameSettings._loaded = false
	GameSettings.ensure_loaded()
	assert_bool(GameSettings.reduce_motion).is_true()
	assert_int(GameSettings.font_size(20)).is_equal(30)
	DirAccess.remove_absolute(GameSettings.path)
	GameSettings.path = GameSettings.PATH
	GameSettings.reset()


func test_volumen_cero_silencia_el_bus() -> void:
	GameSettings.reset()
	GameSettings.music_volume = 0.0
	AudioMixer.apply_settings()
	var bus: int = AudioServer.get_bus_index(AudioMixer.BUS_MUSIC)
	assert_float(AudioServer.get_bus_volume_db(bus)).is_equal(AudioMixer.SILENT_DB)
	GameSettings.reset()
