extends GdUnitTestSuite
## Batallas entre facciones y vista de estrategia, en la zona beta real.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"

var zone: DespliegueCeroZone


func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	zone = scene_runner(PATH).scene()
	zone.set_enemies_active(false)


func after_test() -> void:
	DespliegueCeroZone.forced_hour = -1
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


func test_m_abre_la_vista_y_esc_la_cierra() -> void:
	InputBindings.install()
	var battles: BattleDirector = _start()
	battles.choose(0)
	var vista: StrategyView = battles.strategy_view()
	assert_bool(vista.is_open).is_false()
	var tecla_m: InputEventKey = _tecla(KEY_M)
	vista._unhandled_input(tecla_m)
	assert_bool(vista.is_open).is_true()
	# M solo abre: con la vista ya abierta no hace nada (decisión del 9-nov).
	vista._unhandled_input(_tecla(KEY_M))
	assert_bool(vista.is_open).is_true()
	vista._unhandled_input(_tecla(KEY_ESCAPE))
	assert_bool(vista.is_open).is_false()


func test_al_elegir_solo_mirar_la_vista_ya_esta_abierta_y_m_no_hace_nada() -> void:
	InputBindings.install()
	var battles: BattleDirector = _start()
	battles.choose(2)
	var vista: StrategyView = battles.strategy_view()
	assert_bool(vista.is_open).is_true()
	vista._unhandled_input(_tecla(KEY_M))
	assert_bool(vista.is_open).is_true()


func _tecla(codigo: Key) -> InputEventKey:
	var evento: InputEventKey = InputEventKey.new()
	evento.physical_keycode = codigo
	evento.pressed = true
	return evento


func test_al_caer_un_guardia_la_vista_recibe_un_alejazo() -> void:
	var battles: BattleDirector = _start()
	battles.choose(2)
	var vista: StrategyView = battles.strategy_view()
	vista.tick_pulse(1.0)
	assert_float(vista.pulse_level()).is_equal(0.0)
	var guard: Guard = battles.alive_in("mohocrata")[0]
	guard.health = 1.0
	battles._strike(guard)
	assert_bool(vista.pulse_level() > 0.0).is_true()


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


func test_la_vista_oculta_lo_que_tapa_y_lo_devuelve_al_salir() -> void:
	zone.battles.begin()
	zone.battles.choose(2)
	await await_idle_frame()
	assert_bool(zone.visible).is_false()
	assert_bool(zone.hud.visible).is_false()
	zone.battles.close_view()
	assert_bool(zone.visible).is_true()
	assert_bool(zone.hud.visible).is_true()
