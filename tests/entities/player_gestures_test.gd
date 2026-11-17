extends GdUnitTestSuite

## Máquina de estados de gestos del protagonista (P-51).


func _player() -> Player:
	var player: Player = auto_free(Player.new())
	player.bind_body()
	return player


func test_un_clip_de_prioridad_alta_interrumpe_al_bajo() -> void:
	var player: Player = _player()
	assert_bool(player.set_action("ataque")).is_true()
	assert_bool(player.set_action("daño")).is_true()
	assert_str(player.action_frames.action).is_equal("daño")


func test_un_gesto_social_no_interrumpe_un_clip_de_prioridad_cinco() -> void:
	var player: Player = _player()
	player.set_action("ataque")
	assert_bool(player.set_action("saludar")).is_false()
	assert_str(player.action_frames.action).is_equal("ataque")


func test_los_clips_de_igual_prioridad_se_encolan() -> void:
	var player: Player = _player()
	player.set_action("ataque")
	assert_bool(player.set_action("recarga")).is_false()
	player.tick_action(0.31)
	assert_str(player.action_frames.action).is_equal("recarga")
	player.tick_action(0.51)
	assert_str(player.action_frames.action).is_equal(ActionFrameCatalog.DEFAULT)


func test_el_gesto_terminal_no_se_puede_interrumpir() -> void:
	var player: Player = _player()
	assert_bool(player.set_action("morir")).is_true()
	assert_bool(player.set_action("celebrar")).is_false()
	assert_str(player.action_frames.action).is_equal("morir")
	player.tick_action(Player.DEATH_TIME + 0.1)
	assert_str(player.action_frames.action).is_equal("morir")


func test_lanzar_frena_al_jugador_y_atacar_no() -> void:
	var player: Player = _player()
	assert_bool(player.movement_held()).is_false()
	player.set_action("lanzar")
	assert_bool(player.movement_held()).is_true()
	player.tick_action(0.5)
	assert_bool(player.movement_held()).is_false()
	player.set_action("ataque")
	assert_bool(player.movement_held()).is_false()


func test_perder_una_pieza_lanza_el_tambaleo() -> void:
	var player: Player = _player()
	player.body.wear_piece(ModularBody.Slot.ARM_EXTRA_LEFT, 999.0)
	assert_str(player.action_frames.action).is_equal("perdida")


func test_la_muerte_bloquea_los_controles_para_siempre() -> void:
	var player: Player = _player()
	player.body.wear_piece(ModularBody.Slot.HEAD, 999.0)
	assert_bool(player.body.is_dead).is_true()
	assert_str(player.action_frames.action).is_equal("morir")
	assert_bool(player.controls_locked).is_true()
	assert_int(player.process_mode).is_equal(Node.PROCESS_MODE_ALWAYS)
	assert_bool(player.set_action("celebrar")).is_false()


func test_si_se_mueve_se_levanta_y_el_reloj_de_idle_vuelve_a_cero() -> void:
	var player: Player = _player()
	for step: int in range(31):
		player.tick_idle(1.0)
	assert_bool(player.sitting).is_true()
	player.velocity = Vector2(1.0, 0.0)
	player.tick_idle(0.1)
	assert_bool(player.sitting).is_false()


func test_a_los_treinta_segundos_todavia_no_se_ha_sentado() -> void:
	var player: Player = _player()
	for step: int in range(29):
		player.tick_idle(1.0)
	assert_bool(player.sitting).is_false()
	player.tick_idle(1.5)
	assert_bool(player.sitting).is_true()


func test_rascarse_salta_solo_estando_quieto() -> void:
	var player: Player = _player()
	player.tick_idle(0.5)
	assert_str(player.action_frames.action).is_equal(ActionFrameCatalog.DEFAULT)
	for step: int in range(int(Player.SCRATCH_MAX_TIME) + 1):
		player.tick_idle(1.0)
		if player.action_frames.action == "rascar":
			break
	assert_str(player.action_frames.action).is_equal("rascar")
	assert_bool(player.sitting).is_false()


func test_los_gestos_de_idle_no_consumen_la_semilla_global() -> void:
	var first: Player = _player()
	var second: Player = _player()
	var first_time: int = -1
	var second_time: int = -1
	for step: int in range(int(Player.SIT_IDLE_TIME) + 1):
		first.tick_idle(1.0)
		second.tick_idle(1.0)
		if first_time < 0 and first.action_frames.action == "rascar":
			first_time = step
		if second_time < 0 and second.action_frames.action == "rascar":
			second_time = step
	assert_int(first_time).is_greater(-1)
	assert_int(second_time).is_equal(first_time)


func test_saludar_solo_la_primera_vez_y_senalar_lo_examinable() -> void:
	var player: Player = _player()
	player.gesture_for(Interactable.Kind.EVIDENCE, "prueba_1")
	assert_str(player.action_frames.action).is_equal("señalar")
	player.tick_action(1.0)
	assert_str(player.action_frames.action).is_equal(ActionFrameCatalog.DEFAULT)
	player.gesture_for(Interactable.Kind.NPC, "npc_1")
	assert_str(player.action_frames.action).is_equal("saludar")
	player.tick_action(1.0)
	player.gesture_for(Interactable.Kind.NPC, "npc_1")
	assert_str(player.action_frames.action).is_equal(ActionFrameCatalog.DEFAULT)
	player.gesture_for(Interactable.Kind.NPC, "npc_2")
	assert_str(player.action_frames.action).is_equal("saludar")


func test_la_pose_del_jugador_sale_de_su_estado_real() -> void:
	var player: Player = _player()
	player.set_crouching(true)
	var state: Dictionary = player.pose_state()
	assert_bool(state["crouching"]).is_true()
	assert_bool(state["dead"]).is_false()
	assert_bool(state["sitting"]).is_false()
	assert_str(state["action"]).is_equal(ActionFrameCatalog.DEFAULT)
