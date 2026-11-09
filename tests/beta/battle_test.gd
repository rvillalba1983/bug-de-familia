extends GdUnitTestSuite
## Batallas entre facciones y vista de estrategia, en la zona beta real.

const PATH: String = "res://scenes/beta/beta_zone.tscn"

var zone: BetaZone


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	zone = scene_runner(PATH).scene()
	zone.set_enemies_active(false)


func after_test() -> void:
	BetaZone.forced_hour = -1
	Engine.time_scale = 1.0
	get_tree().paused = false


func _start() -> BattleDirector:
	assert_bool(zone.battles.begin()).is_true()
	return zone.battles


func test_no_hay_duplicados_ni_nadie_en_dos_bandos() -> void:
	var battles: BattleDirector = _start()
	for id: String in battles.sides["jubilado"]:
		assert_bool((battles.sides["mohocrata"] as Array).has(id)).is_false()
	assert_int((battles.sides["jubilado"] as Array).size()).is_less_equal(BattleDirector.MAX_PER_SIDE)


func test_unirse_cambia_la_reputacion() -> void:
	var sim: WorldSim = zone.live_world.sim
	var before: float = float(sim.player_standing.get("jubilado", 0.0))
	var battles: BattleDirector = _start()
	battles.choose(0)
	assert_str(battles.joined).is_equal("jubilado")
	assert_float(float(sim.player_standing["jubilado"])).is_greater(before)


func test_las_bajas_no_se_culpan_al_jugador_y_acaba_con_ganador() -> void:
	var battles: BattleDirector = _start()
	battles.choose(3)
	var sim: WorldSim = zone.live_world.sim
	var winner: Array[String] = []
	battles.finished.connect(func(id: String) -> void: winner.append(id))
	for id: String in battles.sides["mohocrata"]:
		var guard: Guard = zone.live_world.citizens[id]
		battles._strike(guard)
		guard.health = 1.0
		battles._strike(guard)
	battles._run(0.1)
	assert_array(winner).is_equal(["jubilado"] as Array[String])
	assert_int(battles.phase).is_equal(BattleDirector.Phase.NONE)
	assert_int(battles.fallen.size()).is_greater(2)
	var blamed: Array = sim.truth.to_list().filter(
		func(record: Dictionary) -> bool: return record["type"] == "el_sobrante_mata"
	)
	assert_array(blamed).is_empty()
	assert_array(ConsistencyChecker.check(sim)).is_empty()


func test_vista_de_estrategia_cambia_velocidad_y_la_restaura() -> void:
	var battles: BattleDirector = _start()
	battles.choose(2)
	assert_bool(battles.strategy_view().is_open).is_true()
	assert_bool(zone.player.controls_locked).is_true()
	battles.set_speed(4.0)
	assert_float(Engine.time_scale).is_equal(4.0)
	battles.close_view()
	assert_float(Engine.time_scale).is_equal(1.0)
	assert_bool(zone.player.controls_locked).is_false()


func test_convertir_un_caido_ante_testigos_se_recuerda() -> void:
	var battles: BattleDirector = _start()
	battles.choose(3)
	var sim: WorldSim = zone.live_world.sim
	var victim: String = battles.sides["mohocrata"][0]
	var witness: NpcState = sim.npcs[battles.sides["mohocrata"][1]]
	witness.pos = zone.player.global_position
	battles.fallen.append(victim)
	var before: float = float(sim.player_standing.get("mohocrata", 0.0))
	battles.on_converted(victim)
	assert_float(float(sim.player_standing["mohocrata"])).is_less(before)
