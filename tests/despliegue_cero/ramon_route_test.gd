extends GdUnitTestSuite
## P-60: la ruta de Don Ramón no puede cruzar muros ni fachadas y la patrulla
## tiene que avanzar de verdad. La patrulla anda en línea recta sin NavGrid, así
## que cada tramo se comprueba punto a punto sobre la rejilla.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"
const SAMPLE_STEP: float = 8.0

var zone: DespliegueCeroZone


func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	zone = scene_runner(PATH).scene()


func after_test() -> void:
	Engine.time_scale = 1.0
	DespliegueCeroZone.forced_hour = -1
	get_tree().paused = false


func _point_or_label(index: int, point: Vector2) -> String:
	return "ramon_route[%d] = %s" % [index, str(point)]


func test_ramon_route_has_walkable_segments() -> void:
	var route: Array[Vector2] = DespliegueCeroLayout.ramon_route
	assert_int(route.size()).is_greater_equal(2)
	for index: int in range(route.size()):
		assert_bool(zone.nav.is_walkable(route[index])).is_true().override_failure_message(
			"El punto %s no es caminable" % _point_or_label(index, route[index])
		)
	for index: int in range(route.size() - 1):
		var from: Vector2 = route[index]
		var to: Vector2 = route[index + 1]
		var length: float = from.distance_to(to)
		var steps: int = maxi(1, int(ceil(length / SAMPLE_STEP)))
		for step: int in range(steps + 1):
			var point: Vector2 = from.lerp(to, float(step) / float(steps))
			assert_bool(zone.nav.is_walkable(point)).is_true().override_failure_message(
				"El tramo %s -> %s cruza un obstáculo en %s" % [
					_point_or_label(index, from), _point_or_label(index + 1, to), str(point)
				]
			)


## El fallo original dejaba al guardia empujando contra la fachada del corredor
## norte (x≈1740) y nunca alcanzaba el segundo punto de la ruta. Se coloca justo
## antes del obstáculo para que la prueba sea rápida pero siga detectando el caso.
func test_ramon_patrol_advances_past_the_north_facade() -> void:
	zone.ramon.global_position = Vector2(1600.0, 300.0)
	zone.ramon._patrol_index = 1
	Engine.time_scale = 6.0
	await await_millis(4000)
	Engine.time_scale = 1.0
	assert_int(zone.ramon._patrol_index).is_greater_equal(2).override_failure_message(
		"Don Ramón sigue atascado en la fachada norte: índice %d, posición %s" % [
			zone.ramon._patrol_index, str(zone.ramon.global_position)
		]
	)
