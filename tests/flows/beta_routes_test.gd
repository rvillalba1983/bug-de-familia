extends GdUnitTestSuite
## Recorridos completos de la beta con enemigos activos, sin atajos de posición.

const PATH: String = "res://scenes/beta/beta_zone.tscn"
const SPEED: float = 3.0
const ROUTE_TIMEOUT: int = 300000
const FESTIVAL_DAY: int = 1794657600

var zone: BetaZone
var walker: BetaWalker


func _start(route_seed: int = 7) -> void:
	TestSupport.reset_session()
	Sandbox.forced_seed = route_seed
	BetaZone.forced_hour = 12
	zone = scene_runner(PATH).scene()
	await await_millis(300)
	walker = BetaWalker.new(get_tree(), zone)
	Engine.time_scale = SPEED


func before_test() -> void:
	InputBindings.install()
	get_tree().paused = false


func after_test() -> void:
	Engine.time_scale = 1.0
	BetaZone.forced_hour = -1
	WorldCalendar.forced_local_unix = -1
	Sandbox.forced_seed = 1234
	get_tree().paused = false


func _assert_all_challenges_without_killing() -> void:
	assert_array(walker.completed_challenges()).contains_exactly_in_any_order(BetaChallenges.ALL_CHALLENGES)
	assert_bool(zone.player.body.is_dead).is_false()
	assert_int(zone.fallen_ids.size()).is_equal(0)
	assert_bool(walker.log_lines.any(func(l: String) -> bool: return l.begins_with("NO LLEGA"))).is_false()


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
	assert_array(walker.completed_challenges()).contains_exactly_in_any_order(BetaChallenges.ALL_CHALLENGES)
	assert_bool(zone.player.body.is_dead).is_false()
