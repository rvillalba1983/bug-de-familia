extends GdUnitTestSuite


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
