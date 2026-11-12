extends GdUnitTestSuite
## Recorridos completos de la beta con enemigos activos, sin atajos de posición.

const PATH: String = "res://scenes/beta/beta_zone.tscn"
const SPEED: float = 3.0
const ROUTE_TIMEOUT: int = 300000
const FESTIVAL_DAY: int = 1794657600

var zone: BetaZone
var walker: BetaWalker


func _start(route_seed: int = 7) -> void:
	var forced_day: int = WorldCalendar.forced_local_unix
	if forced_day < 0:
		forced_day = 1768474800  # 15 ene 2026, sin festividad: determinismo (P-39)
	TestSupport.reset_session()
	Sandbox.forced_seed = route_seed
	BetaZone.forced_hour = 12
	WorldCalendar.forced_local_unix = forced_day
	BattleDirector.auto_start = true
	Engine.time_scale = SPEED
	get_tree().paused = false
	zone = scene_runner(PATH).scene()
	# Estabilizar en cuanto live_world esté listo (P-39): reintento por si la
	# inicialización es diferida, para que ningún suceso aleatorio se dispare.
	for _attempt: int in range(10):
		if zone.live_world != null and zone.live_world.sim != null:
			break
		await get_tree().physics_frame
	_stabilize_for_routes()
	# Espera determinista en fotogramas de física (P-39).
	for _i: int in range(54):
		await get_tree().physics_frame
	walker = BetaWalker.new(get_tree(), zone)


## Las rutas no dependen de sucesos aleatorios del mundo; se desactivan para evitar
## muertes ajenas al recorrido (P-39, intermitencia por cadencia en Linux).
func _stabilize_for_routes() -> void:
	if zone.live_world == null or zone.live_world.sim == null:
		return
	var events: EventSystem = zone.live_world.sim.events
	events.timer = 1e9
	events.staged.clear()
	events.pending.clear()


func before_test() -> void:
	InputBindings.install()
	get_tree().paused = false


func after_test() -> void:
	Engine.time_scale = 1.0
	BetaZone.forced_hour = -1
	WorldCalendar.forced_local_unix = -1
	Sandbox.forced_seed = 1234
	get_tree().paused = false


func _dump_route() -> void:
	print("=== WALKER LOG (%d) ===" % walker.log_lines.size())
	for line: String in walker.log_lines:
		print(line)
	print("=== FALLEN ===")
	print(zone.fallen_ids)
	print("player_dead=%s challenges=%s" % [str(zone.player.body.is_dead), str(walker.completed_challenges())])


func _assert_all_challenges_without_killing() -> void:
	var no_llega: bool = walker.log_lines.any(
		func(l: String) -> bool: return l.begins_with("NO LLEGA")
	)
	var ok: bool = walker.completed_challenges().size() == BetaChallenges.ALL_CHALLENGES.size() \
		and not zone.player.body.is_dead and zone.fallen_ids.is_empty() and not no_llega
	if not ok:
		_dump_route()
	assert_array(walker.completed_challenges()).contains_exactly_in_any_order(
		BetaChallenges.ALL_CHALLENGES
	)
	assert_bool(zone.player.body.is_dead).is_false()
	assert_int(zone.fallen_ids.size()).is_equal(0)
	assert_bool(no_llega).is_false()


func test_ruta_sigilo_completa_los_cuatro_retos(timeout: int = ROUTE_TIMEOUT) -> void:
	await _start()
	await walker.run("sigilo")
	_assert_all_challenges_without_killing()


func test_ruta_palabra_completa_los_cuatro_retos(timeout: int = ROUTE_TIMEOUT) -> void:
	await _start()
	await walker.run("palabra")
	_assert_all_challenges_without_killing()


func test_ruta_fuerza_completa_los_cuatro_retos(timeout: int = ROUTE_TIMEOUT) -> void:
	await _start()
	await walker.run("fuerza")
	_assert_all_challenges_without_killing()


func test_mision_emergente_se_cierra_con_recompensa(timeout: int = ROUTE_TIMEOUT) -> void:
	await _start()
	var before: int = zone.player.body.spare_count()
	await walker.run("mision")
	assert_bool(walker.log_lines.any(func(l: String) -> bool: return l.contains("resultado devuelto"))).is_true()
	assert_int(zone.player.body.spare_count()).is_greater(before)


func test_reventar_una_fiesta_con_ruido_la_arruina(timeout: int = ROUTE_TIMEOUT) -> void:
	WorldCalendar.forced_local_unix = FESTIVAL_DAY
	await _start()
	assert_bool(zone.live_world.sim.festivals.is_running()).is_true()
	await walker.run("fiesta")
	assert_bool(zone.live_world.sim.festivals.ruined).is_true()


func test_otra_semilla_tambien_se_completa_por_sigilo(timeout: int = ROUTE_TIMEOUT) -> void:
	await _start(21)
	await walker.run("sigilo")
	if walker.completed_challenges().size() != BetaChallenges.ALL_CHALLENGES.size() \
			or zone.player.body.is_dead:
		_dump_route()
	assert_array(walker.completed_challenges()).contains_exactly_in_any_order(
		BetaChallenges.ALL_CHALLENGES
	)
	assert_bool(zone.player.body.is_dead).is_false()
