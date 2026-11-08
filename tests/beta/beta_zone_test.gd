extends GdUnitTestSuite
## Los cuatro retos de la beta, sus soluciones y sus consecuencias.

const PATH: String = "res://scenes/beta/beta_zone.tscn"

var zone: BetaZone
var runner: GdUnitSceneRunner


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	runner = scene_runner(PATH)
	zone = runner.scene()


func after_test() -> void:
	Engine.time_scale = 1.0
	BetaZone.forced_hour = -1
	get_tree().paused = false


func _case() -> InvestigationDirector:
	return zone.investigation


func _quiet() -> void:
	zone.set_enemies_active(false)


func _teleport(at: Vector2) -> void:
	zone.player.global_position = at
	await await_millis(60)


func _say(text: String) -> void:
	var options: Array = _case().available_options(_case().current_node)
	for index: int in range(options.size()):
		if (options[index]["text"] as String).contains(text):
			_case().choose(index)
			return
	fail("No existe la opción: %s" % text)


func _option_exists(text: String) -> bool:
	for option: Dictionary in _case().available_options(_case().current_node):
		if (option["text"] as String).contains(text):
			return true
	return false


func _walk(points: Array[Vector2]) -> void:
	for point: Vector2 in points:
		zone.player.set_path(PackedVector2Array([point]))
		for _frame: int in range(3000):
			if zone.player.global_position.distance_to(point) < 12.0:
				break
			await await_millis(16)


func test_case_data_is_consistent() -> void:
	assert_array(_case().validate()).is_empty()


func test_every_objective_is_reachable_with_doors_closed() -> void:
	for goal: Vector2 in [
		BetaLayout.CENTRAL_INSIDE.get_center() + Vector2(0.0, 120.0),
		BetaLayout.REEL,
		BetaLayout.CROSSING_GOAL.get_center(),
		BetaLayout.RAMON_ROUTE[1],
		BetaLayout.MINE_PICKUP,
	]:
		var path: PackedVector2Array = zone.nav.find_path(BetaLayout.START, goal)
		assert_bool(path.size() > 1).is_true()
		assert_float(path[path.size() - 1].distance_to(goal)).is_less(40.0)


func test_lookout_is_only_reached_through_no_mans_land() -> void:
	var path: PackedVector2Array = zone.nav.find_path(BetaLayout.START, BetaLayout.CROSSING_GOAL.get_center())
	var through: bool = false
	for point: Vector2 in path:
		if point.x > 2900.0 and point.x < 3100.0:
			through = BetaLayout.NO_MANS_LAND.has_point(point)
	assert_bool(through).is_true()


func test_enter_through_service_duct_opening() -> void:
	_quiet()
	await _teleport(Vector2(2580.0, 590.0))
	await _walk([Vector2(2580.0, 720.0)])
	assert_bool(_case().has_flag(BetaChallenges.ENTER)).is_true()


func test_enter_with_deduced_code() -> void:
	_quiet()
	_case().open_dialogue("panel")
	_say("21:00")
	assert_bool(zone.door.is_open).is_true()
	await _teleport(BetaLayout.CENTRAL_INSIDE.get_center())
	assert_bool(_case().has_flag(BetaChallenges.ENTER)).is_true()


func test_wrong_code_makes_noise_and_keeps_door_closed() -> void:
	_quiet()
	var heard: Array = []
	zone.noise_bus.noise_emitted.connect(func(_at: Vector2, radius: float) -> void: heard.append(radius))
	_case().open_dialogue("panel")
	_say("12:00")
	assert_bool(zone.door.is_open).is_false()
	assert_array(heard).is_not_empty()
	_case().open_dialogue("panel")
	assert_bool(_option_exists("21:00")).is_true()
	_say("Dejarlo")


func test_enter_by_blowing_cracked_wall_needs_a_mine() -> void:
	_quiet()
	(zone.items[BetaZone.ID_CRACK] as Interactable).activate()
	assert_bool(zone.cracked_wall.is_open).is_false()
	(zone.items[BetaZone.ID_MINE] as Interactable).activate()
	(zone.items[BetaZone.ID_CRACK] as Interactable).activate()
	assert_bool(zone.cracked_wall.is_open).is_true()
	var path: PackedVector2Array = zone.nav.find_path(BetaLayout.CRACKED_MARK, Vector2(2400.0, 830.0))
	assert_float(path[path.size() - 1].distance_to(Vector2(2400.0, 830.0))).is_less(40.0)


func test_extract_by_stealing_counts_only_outside_depot() -> void:
	_quiet()
	await _teleport(BetaLayout.REEL + Vector2(-40.0, 0.0))
	(zone.items[BetaZone.ID_REEL] as Interactable).activate()
	await await_millis(60)
	assert_bool(_case().has_flag(BetaChallenges.EXTRACT)).is_false()
	await _teleport(Vector2(2000.0, 1800.0))
	assert_bool(_case().has_flag(BetaChallenges.EXTRACT)).is_true()


func test_extract_by_vote_needs_the_evidence() -> void:
	_quiet()
	_case().open_dialogue("seta")
	assert_bool(_option_exists("es correo")).is_false()
	_say("Otro día")
	_case().examine("e_etiqueta")
	_case().examine("e_acta")
	_case().open_dialogue("seta")
	_say("es correo")
	_say("Gracias")
	await await_millis(60)
	assert_bool(_case().has_flag("tiene_bobina")).is_true()
	assert_bool(_case().has_flag(BetaChallenges.EXTRACT)).is_true()


func test_war_empties_the_depot() -> void:
	var before: Vector2 = zone.depot_guards()[0].global_position
	assert_bool(BetaLayout.DEPOT.has_point(before)).is_true()
	_case().set_flag("guerra")
	assert_bool(zone.moved_to_war).is_true()
	Engine.time_scale = 6.0
	await await_millis(5000)
	assert_bool(BetaLayout.DEPOT.has_point(zone.depot_guards()[0].global_position)).is_false()


func test_safe_passage_can_be_paid_with_a_spare_and_pacifies_the_strip() -> void:
	var spares_before: int = zone.player.body.to_dict().hash()
	_case().open_dialogue("paca")
	_say("cruzar la tierra")
	_say("repuesto")
	_say("Gracias")
	assert_int(zone.player.body.to_dict().hash()).is_not_equal(spares_before)
	for enemy: Guard in zone.strip_guards():
		assert_bool(enemy.passive).is_true()


func test_crossing_with_safe_passage_avoiding_mines() -> void:
	_quiet()
	_case().set_flag("salvoconducto")
	await _teleport(Vector2(1180.0, 1230.0))
	Engine.time_scale = 6.0
	await _walk([
		Vector2(1450.0, 1385.0), Vector2(1590.0, 1385.0), Vector2(1590.0, 1315.0), Vector2(1640.0, 1315.0),
		Vector2(1720.0, 1315.0), Vector2(1880.0, 1240.0), Vector2(2070.0, 1260.0),
		Vector2(2130.0, 1325.0), Vector2(2200.0, 1330.0), Vector2(2400.0, 1262.0),
		Vector2(2580.0, 1262.0), Vector2(2640.0, 1310.0), Vector2(2720.0, 1310.0),
		Vector2(2840.0, 1365.0), Vector2(2980.0, 1385.0), Vector2(3150.0, 1320.0),
		Vector2(3400.0, 1320.0),
	])
	assert_bool(_case().has_flag(BetaChallenges.CROSS)).is_true()
	var lost: Array = []
	for index: int in range(BetaLayout.MINES.size()):
		if not zone.mines.has("mine_%d" % index):
			lost.append(index)
	assert_array(lost).is_empty()


func test_stepping_on_a_mine_hurts_and_it_is_gone() -> void:
	_quiet()
	var body_before: int = zone.player.body.to_dict().hash()
	await _teleport(BetaLayout.MINES[0])
	await await_millis(100)
	assert_int(zone.mines.size()).is_equal(BetaLayout.MINES.size() - 1)
	assert_int(zone.player.body.to_dict().hash()).is_not_equal(body_before)


func test_noise_on_a_mine_detonates_it_without_hurting() -> void:
	_quiet()
	var body_before: int = zone.player.body.to_dict().hash()
	zone.noise_bus.emit_noise(BetaLayout.MINES[1] + Vector2(10.0, 0.0), 100.0)
	await await_millis(100)
	assert_bool(zone.mines.has("mine_1")).is_false()
	assert_int(zone.player.body.to_dict().hash()).is_equal(body_before)


func test_find_ramon_by_proximity() -> void:
	await _teleport(zone.ramon.global_position + Vector2(100.0, 0.0))
	assert_bool(_case().has_flag(BetaChallenges.FIND)).is_true()


func test_jubilado_tells_ramon_route() -> void:
	_case().open_dialogue("eusebio")
	assert_bool(_option_exists("Don Ramón")).is_true()
	_say("Don Ramón")
	_say("Gracias")


func test_breaking_generator_brings_ramon() -> void:
	(zone.items[BetaZone.ID_GENERATOR] as Interactable).activate()
	assert_int(zone.ramon.state).is_equal(Guard.State.INVESTIGATE)


func test_ramon_only_opens_up_after_arguing() -> void:
	_case().open_dialogue("ramon")
	_say("Perdone")
	assert_str(_case().case_data["dialogue"][_case().current_node]["text"]).contains("Ticket")
	_say("Vale")
	_case().open_dialogue("ramon")
	_say("Sueldas")
	_say("Sigue")
	_say("Gracias")
	assert_bool(_case().has_flag("verdad_ramon")).is_true()


func test_ramon_yields_when_beaten_and_can_die() -> void:
	# El golpe abre la pausa previa a la pelea, así que se avanza a mano.
	zone.ramon.take_damage(45.0)
	zone.challenges._follow_ramon()
	assert_bool(_case().has_flag("ramon_peleado")).is_true()
	zone.ramon.take_damage(100.0)
	assert_bool(_case().has_flag("ramon_muerto")).is_true()
	assert_bool(zone.ramon_item().used).is_true()


func test_contestador_gives_cut_messages_and_more_with_reel() -> void:
	_case().open_dialogue("contestador")
	assert_bool(_option_exists("Meter la bobina")).is_false()
	_say("Colgar")
	_case().set_flag("tiene_bobina")
	_case().open_dialogue("contestador")
	_say("Meter la bobina")
	assert_str(_case().case_data["dialogue"][_case().current_node]["text"]).contains("sobrante")
	_say("Colgar")


func test_rain_wears_only_metal_and_not_under_shelter() -> void:
	_quiet()
	var body: ModularBody = zone.player.body
	var leg: BodyPiece = body.equipped(ModularBody.Slot.LEG_LEFT)
	var arm: BodyPiece = body.equipped(ModularBody.Slot.ARM_MAIN_LEFT)
	arm.metallic = false
	var leg_before: float = leg.durability
	var arm_before: float = arm.durability
	zone.rain.wear(10.0)
	assert_float(leg.durability).is_less(leg_before)
	assert_float(arm.durability).is_equal(arm_before)
	await _teleport(BetaLayout.SHELTERS[0].get_center())
	assert_bool(zone.rain.is_sheltered()).is_true()


func test_power_off_at_night_is_only_an_advantage() -> void:
	zone.challenges.hour_source = func() -> int: return 22
	assert_bool(zone.challenges.is_power_off_hour()).is_true()
	await await_millis(2300)
	assert_int(zone.jubilado_guards()[0].state).is_equal(Guard.State.STUNNED)
	assert_int(zone.strip_mohocrata.state).is_not_equal(Guard.State.STUNNED)


func test_no_power_off_at_noon() -> void:
	assert_bool(zone.challenges.is_power_off_hour()).is_false()


func test_encounter_interrupts_and_silence_is_an_answer() -> void:
	_quiet()
	var group: Interactable = _case().npc_nodes["cuadrilla_moho"]
	zone.player.global_position = group.global_position + Vector2(100.0, 0.0)
	zone.challenges._check_encounters()
	assert_str(_case().current_node).is_equal("moho_alto")
	_case()._tick_answer_limit(9.0)
	assert_str(_case().current_node).is_empty()
	assert_bool(_case().has_flag("moho_bronca")).is_true()


func test_crouching_avoids_the_encounter() -> void:
	_quiet()
	zone.player.set_crouching(true)
	var group: Interactable = _case().npc_nodes["patrulla_jub"]
	await _teleport(group.global_position + Vector2(100.0, 0.0))
	assert_str(_case().current_node).is_empty()


func test_redirected_group_leaves() -> void:
	_quiet()
	_case().open_dialogue("patrulla_jub")
	_say("sombreros")
	assert_bool((_case().npc_nodes["patrulla_jub"] as Interactable).used).is_true()


func test_contestador_can_be_lost_for_good() -> void:
	zone._on_converted(BetaZone.ID_CONTESTADOR)
	await await_millis(60)
	assert_bool(is_instance_valid(_case().npc_nodes[BetaZone.ID_CONTESTADOR])).is_false()
	_case().set_flag("paz")
	assert_bool(_case().is_resolved()).is_true()


func test_all_four_without_killing_and_state_survives_reload() -> void:
	_quiet()
	var fallen: Array = []
	for enemy: Guard in zone.guards():
		enemy.fell.connect(func(who: Guard) -> void: fallen.append(who))
	_case().open_dialogue("panel")
	_say("21:00")
	await _teleport(BetaLayout.CENTRAL_INSIDE.get_center())
	_case().set_flag("voto_bobina")
	await _teleport(BetaLayout.CROSSING_GOAL.get_center())
	await _teleport(zone.ramon.global_position + Vector2(50.0, 0.0))
	await await_millis(60)
	assert_bool(_case().has_flag("beta_completa")).is_true()
	assert_array(fallen).is_empty()
	zone.autosave()
	var second: GdUnitSceneRunner = scene_runner(PATH)
	var restored: BetaZone = second.scene()
	assert_bool(restored.investigation.has_flag("beta_completa")).is_true()
	assert_bool(restored.door.is_open).is_true()
	assert_bool(restored.investigation.has_flag("tiene_bobina")).is_true()
	assert_bool((restored.items[BetaZone.ID_REEL] as Interactable).used).is_true()


func test_war_positions_and_mines_persist() -> void:
	_quiet()
	_case().set_flag("guerra")
	zone.noise_bus.emit_noise(BetaLayout.MINES[2], 100.0)
	await await_millis(100)
	zone.autosave()
	var second: GdUnitSceneRunner = scene_runner(PATH)
	var restored: BetaZone = second.scene()
	assert_bool(restored.moved_to_war).is_true()
	assert_bool(restored.mines.has("mine_2")).is_false()
