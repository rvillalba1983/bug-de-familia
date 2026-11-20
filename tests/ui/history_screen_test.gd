extends GdUnitTestSuite
## La pantalla «Conoce la historia» usa carteles de menú y una imagen grande.

func test_la_imagen_es_grande_y_no_se_distorsiona() -> void:
	var screen: HistoryScreen = HistoryScreen.new()
	add_child(screen)
	assert_int(HistoryScreen.FACTS.size()).is_equal(20)
	assert_object(screen._image_rect).is_not_null()
	assert_float(screen._image_rect.size.x).is_greater_equal(1100.0)
	assert_float(screen._image_rect.size.y).is_greater_equal(800.0)
	assert_int(screen._image_rect.stretch_mode).is_equal(
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	assert_object(screen._image_rect.texture).is_not_null()


func test_los_tres_botones_son_carteles_con_estilo() -> void:
	var screen: HistoryScreen = HistoryScreen.new()
	add_child(screen)
	var found: Array[Node] = screen.find_children("*", "Button", true, false)
	assert_int(found.size()).is_equal(3)
	for node: Node in found:
		var btn: Button = node as Button
		assert_bool(btn.has_theme_font_override(&"font")).is_true()
		assert_bool(btn.has_theme_stylebox_override(&"normal")).is_true()
		assert_bool(btn.has_theme_stylebox_override(&"hover")).is_true()
		assert_bool(btn.has_theme_stylebox_override(&"pressed")).is_true()
		assert_object(btn.icon).is_not_null()
	assert_object(screen._prev_button).is_not_null()
	assert_object(screen._next_button).is_not_null()


func test_navegacion_y_estados_disabled() -> void:
	var screen: HistoryScreen = HistoryScreen.new()
	add_child(screen)
	assert_bool(screen._prev_button.disabled).is_true()
	assert_bool(screen._next_button.disabled).is_false()
	screen._next()
	assert_int(screen._index).is_equal(1)
	screen._prev()
	assert_int(screen._index).is_equal(0)
	assert_object(screen._image_rect.texture).is_not_null()


func test_los_veinte_hechos_tienen_imagen_titulo_y_texto() -> void:
	var imagenes: Dictionary = {}
	for fact: Dictionary in HistoryScreen.FACTS:
		var ruta: String = str(fact["image"])
		assert_bool(imagenes.has(ruta)).is_false().override_failure_message(
			"Imagen repetida en la pantalla de historia: %s" % ruta
		)
		imagenes[ruta] = true
		assert_bool(ResourceLoader.exists(ruta)).is_true().override_failure_message(
			"Falta la imagen %s" % ruta
		)
		assert_str(str(fact["title"]).strip_edges()).is_not_empty()
		assert_str(str(fact["text"]).strip_edges()).is_not_empty()
	assert_int(imagenes.size()).is_equal(HistoryScreen.FACTS.size())
