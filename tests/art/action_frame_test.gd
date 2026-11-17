extends GdUnitTestSuite

## Gestos que se dibujan solo con el rig (P-51): no tienen fotograma de atlas.
const RIG_ONLY: Array[String] = [
	"recoger", "celebrar", "provocar", "saludar", "señalar", "daño", "perdida", "morir", "rascar",
]
const FRAMES_NUEVOS: Array[String] = [
	"accion_lanzar_0", "accion_lanzar_1", "accion_lanzar_2",
	"accion_convertir_0", "accion_convertir_1",
]


func test_el_catalogo_tiene_las_acciones_de_p25_y_los_gestos_de_p51() -> void:
	var acciones: Array[String] = ActionFrameCatalog.actions()
	assert_int(acciones.size()).is_equal(14)
	for id: String in acciones:
		assert_float(ActionFrameCatalog.fps(id)).is_greater(0.0)
		if ActionFrameCatalog.is_rig_only(id):
			assert_array(RIG_ONLY).contains([id])
			assert_array(ActionFrameCatalog.frames(id)).is_empty()
			continue
		var claves: Array[String] = ActionFrameCatalog.frames(id)
		assert_bool(claves.is_empty()).is_false()
		for clave: String in claves:
			assert_bool(clave.contains("/")).is_false()
			assert_bool(PieceAtlas.has_entry(clave)).is_true()


func test_los_cinco_fotogramas_nuevos_estan_en_el_atlas() -> void:
	for clave: String in FRAMES_NUEVOS:
		assert_bool(PieceAtlas.has_entry(clave)).is_true()


func test_los_fotogramas_nuevos_tienen_dibujo() -> void:
	var image: Image = PieceAtlas.texture().get_image()
	image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	for clave: String in FRAMES_NUEVOS:
		var frame: Image = image.get_region(Rect2i(PieceAtlas.region(clave)))
		var pintados: int = 0
		for y: int in range(frame.get_height()):
			for x: int in range(frame.get_width()):
				if frame.get_pixel(x, y).a > 0.1:
					pintados += 1
		assert_int(pintados).override_failure_message("%s vacío" % clave).is_greater(50)


func test_duracion_prioridad_y_estado_terminal_salen_del_catalogo() -> void:
	assert_float(ActionFrameCatalog.duration("ataque")).is_equal_approx(0.3, 0.001)
	assert_float(ActionFrameCatalog.duration("lanzar")).is_equal_approx(0.4, 0.001)
	assert_float(ActionFrameCatalog.duration("idle")).is_equal(ActionFrameCatalog.SUSTAINED)
	assert_int(ActionFrameCatalog.priority("daño")).is_equal(8)
	assert_int(ActionFrameCatalog.priority("morir")).is_equal(10)
	assert_int(ActionFrameCatalog.priority("idle")).is_equal(0)
	assert_bool(ActionFrameCatalog.is_terminal("morir")).is_true()
	assert_bool(ActionFrameCatalog.is_terminal("ataque")).is_false()
	assert_bool(ActionFrameCatalog.holds_movement("lanzar")).is_true()
	assert_bool(ActionFrameCatalog.holds_movement("ataque")).is_false()


func test_la_cadena_de_busqueda_prueba_arma_luego_tipo_y_luego_generico() -> void:
	var disponibles: Array[String] = ["idle", "ataque", "ataque_proyectil", "ataque_a101"]
	assert_str(ActionFrameCatalog.pick_action("ataque", "a101", "proyectil", disponibles)).is_equal(
		"ataque_a101"
	)
	assert_str(ActionFrameCatalog.pick_action("ataque", "a102", "proyectil", disponibles)).is_equal(
		"ataque_proyectil"
	)
	assert_str(ActionFrameCatalog.pick_action("ataque", "a999", "scatter", disponibles)).is_equal(
		"ataque"
	)
	assert_str(ActionFrameCatalog.pick_action("lanzar", "lanzar", "proyectil", disponibles)).is_equal(
		ActionFrameCatalog.DEFAULT
	)
	assert_str(ActionFrameCatalog.resolve("ataque", "a101", "proyectil")).is_equal("ataque")
	assert_str(ActionFrameCatalog.resolve("lanzar", "lanzar", "proyectil")).is_equal("lanzar")


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
