extends GdUnitTestSuite


func test_catalogo_tiene_tres_acciones_y_todas_estan_en_el_atlas() -> void:
	var acciones: Array[String] = ActionFrameCatalog.actions()
	assert_int(acciones.size()).is_equal(3)
	for id: String in acciones:
		var claves: Array[String] = ActionFrameCatalog.frames(id)
		assert_bool(not claves.is_empty()).is_true()
		assert_float(ActionFrameCatalog.fps(id)).is_greater(0.0)
		for clave: String in claves:
			assert_bool(clave.contains("/")).is_false()
			assert_bool(PieceAtlas.has_entry(clave)).is_true()


func test_el_fotograma_avanza_y_vuelve_al_ciclo() -> void:
	var reloj: Array[float] = [0.0]
	var frame: ActionFrame = ActionFrame.new()
	frame.time_source = func() -> float: return reloj[0]
	frame.reset()
	assert_int(frame.current_index()).is_equal(0)
	reloj[0] = 0.6
	assert_int(frame.current_index()).is_equal(1)
	reloj[0] = 1.0
	assert_int(frame.current_index()).is_equal(0)


func test_al_cambiar_de_accion_se_reinicia_y_una_desconocida_no_cambia() -> void:
	var reloj: Array[float] = [0.0]
	var frame: ActionFrame = ActionFrame.new()
	frame.time_source = func() -> float: return reloj[0]
	frame.reset()
	reloj[0] = 5.0
	frame.set_action("ataque")
	assert_str(frame.action).is_equal("ataque")
	assert_int(frame.current_index()).is_equal(0)
	assert_str(frame.current_key()).is_equal("accion_ataque_0")
	frame.set_action("no_existe")
	assert_str(frame.action).is_equal("ataque")


func test_el_guardia_elige_ataque_recarga_o_idle() -> void:
	assert_str(GuardVisual.action_for(0.3, 0.0)).is_equal("ataque")
	assert_str(GuardVisual.action_for(0.0, 0.5)).is_equal("recarga")
	assert_str(GuardVisual.action_for(0.0, 0.0)).is_equal(ActionFrameCatalog.DEFAULT)


func test_el_jugador_vuelve_a_idle_tras_el_tiempo_de_la_accion() -> void:
	var player: Player = auto_free(Player.new())
	player.set_action("ataque")
	assert_str(player.action_frames.action).is_equal("ataque")
	player.tick_action(Player.ACTION_SHOW_TIME + 0.1)
	assert_str(player.action_frames.action).is_equal(ActionFrameCatalog.DEFAULT)