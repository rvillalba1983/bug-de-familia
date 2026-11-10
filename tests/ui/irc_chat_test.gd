extends GdUnitTestSuite

var _motion_anterior: bool = false


func before_test() -> void:
	_motion_anterior = GameSettings.reduce_motion
	GameSettings.reduce_motion = false


func after_test() -> void:
	GameSettings.reduce_motion = _motion_anterior


func test_solo_quedan_los_cuatro_ultimos_mensajes() -> void:
	var team: AiTeam = AiTeam.new()
	var ids: Array = team.ais.keys()
	team.active = [ids[0], ids[1], ids[2]]
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	for index: int in range(9):
		chat.add_message(ids[0], "mensaje %d" % index)
	chat.add_system("alguien ha entrado")
	assert_int(chat.lines().size()).is_equal(IrcChat.VISIBLE_MESSAGES)
	assert_str(chat.lines()[0]).contains("mensaje 5")
	assert_bool(chat.log_view.scroll_active).is_false()


func test_la_lista_marca_activas_y_quita_perdidas() -> void:
	var team: AiTeam = AiTeam.new()
	var ids: Array = team.ais.keys()
	team.active = [ids[0]]
	team.lost.append(ids[1])
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	var rows: PackedStringArray = chat.user_rows()
	assert_int(rows.size()).is_equal(ids.size() - 1)
	assert_str(rows[0]).contains("@")
	assert_str(rows[1]).contains("+")


func test_efectos_personalizados_registrados_en_el_log() -> void:
	var team: AiTeam = AiTeam.new()
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	var etiquetas: Array[String] = []
	for efecto: RichTextEffect in chat.log_view.custom_effects:
		etiquetas.append(str(efecto.get("bbcode")))
	assert_int(etiquetas.size()).is_equal(4)
	for etiqueta: String in ["tartamuda", "enamorada", "enfadada", "corrupto"]:
		assert_bool(etiquetas.has(etiqueta)).is_true()


func test_cada_ia_lleva_su_efecto_y_la_tartamuda_repite() -> void:
	var team: AiTeam = AiTeam.new()
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	chat.add_message("matriz", "mensaje de prueba")
	assert_bool(chat.lines()[0].contains("[tartamuda]")).is_true()
	assert_bool(chat.lines()[0].contains("m-m")).is_true()
	chat.add_message("cupido", "te quiero")
	assert_bool(chat.lines()[1].contains("[enamorada]")).is_true()
	chat.add_message("sargento_bit", "fuera")
	assert_bool(chat.lines()[2].contains("[enfadada]")).is_true()
	chat.add_message("siestaware", "zzz")
	assert_bool(chat.lines()[3].contains("[corrupto]")).is_true()
	assert_int(chat.lines().size()).is_equal(IrcChat.VISIBLE_MESSAGES)


func test_con_movimiento_reducido_el_texto_queda_plano() -> void:
	GameSettings.reduce_motion = true
	var team: AiTeam = AiTeam.new()
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	chat.add_message("matriz", "mensaje de prueba")
	assert_bool(chat.lines()[0].contains("[tartamuda]")).is_false()
	assert_bool(chat.lines()[0].contains("m-m")).is_false()
	assert_str(chat.lines()[0]).contains("mensaje de prueba")


func test_el_destello_es_un_marco_y_no_un_relleno() -> void:
	var team: AiTeam = AiTeam.new()
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	chat.add_message("panico", "aviso")
	assert_float(chat.flash_level()).is_greater(0.0)
	var pintura: Dictionary = chat.flash_paint()
	assert_bool((pintura["relleno"] as Color) == Color.TRANSPARENT).is_true()
	assert_float(float(pintura["grosor"])).is_greater(0.0)


func test_con_movimiento_reducido_no_hay_destello() -> void:
	GameSettings.reduce_motion = true
	var team: AiTeam = AiTeam.new()
	var chat: IrcChat = auto_free(IrcChat.new())
	chat.team = team
	add_child(chat)
	chat.add_message("panico", "aviso")
	assert_float(chat.flash_level()).is_equal(0.0)
