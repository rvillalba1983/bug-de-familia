extends GdUnitTestSuite
## P-30: el guardia oculta su subárbol de esqueletos cuando sale de la cámara.
##
## `GuardVisual.set_visible` solo toca `rig_root`: no crea esqueletos, no cambia
## el flag `visible` de cada vista y no toca el `AnimationPlayer`. La pausa de la
## animación la lleva `rig.player.active`, que fija `_physics_process`.

const RIG_FOLDER: String = "res://art/shared/rig/jubilado_hierro"
const TICK: float = 0.016
## Dentro de la vista por defecto (1920x1080) y muy lejos de ella.
const IN_VIEW: Vector2 = Vector2(120.0, 120.0)
const FAR_AWAY: Vector2 = Vector2(100000.0, 100000.0)


func before_test() -> void:
	TestSupport.reset_session()


## Guardia dentro del árbol, con patrulla de dos puntos: el primer tick cae en
## cámara y pasa a WAIT, así los siguientes ticks no dependen de un `_patrol`
## vacío. Pasivo para no consultar el detector sin objetivo.
##
## El guardia se registra antes que el suelo porque `Guard._exit_tree` libera el
## cono, que cuelga del suelo: al revés, el cono ya estaría liberado.
func _guard_with_rig(rig_folder: String = RIG_FOLDER) -> Guard:
	var guard: Guard = auto_free(Guard.new())
	var ground: Node2D = auto_free(Node2D.new())
	add_child(guard)
	add_child(ground)
	guard.visual.rig_folder = rig_folder
	guard.passive = true
	var patrol: Array[Vector2] = [IN_VIEW, IN_VIEW + Vector2(64.0, 0.0)]
	guard.setup(patrol, ground)
	return guard


func test_leaving_the_screen_hides_the_rig_and_stops_its_animation() -> void:
	var guard: Guard = _guard_with_rig()
	guard._physics_process(TICK)
	assert_object(guard.visual.rig_root).is_not_null()
	assert_bool(guard.visual.rig_root.visible).is_true()
	assert_object(guard.visual.rig).is_not_null()
	assert_bool(guard.visual.rig.player.active).is_true()

	guard.position = FAR_AWAY
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_false()
	assert_bool(guard.visual.rig.player.active).is_false()


func test_coming_back_to_the_screen_shows_the_rig_and_resumes_its_animation() -> void:
	var guard: Guard = _guard_with_rig()
	guard._physics_process(TICK)
	guard.position = FAR_AWAY
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_false()
	assert_bool(guard.visual.rig.player.active).is_false()

	guard.position = IN_VIEW
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_true()
	assert_bool(guard.visual.rig.player.active).is_true()


## Ocultar no cambia qué vista se dibuja: los flags de los `_rigs` se conservan
## y al volver se sigue mostrando solo la vista activa.
func test_hiding_keeps_the_flag_of_each_view() -> void:
	var guard: Guard = _guard_with_rig()
	guard.detector.facing_angle = Vector2.DOWN.angle()
	guard._physics_process(TICK)
	var south: EnemyRig = guard.visual._rigs[GuardVisual.VIEW_SOUTH]
	assert_object(south).is_not_null()
	assert_bool(south.visible).is_true()

	guard.detector.facing_angle = Vector2.RIGHT.angle()
	guard._physics_process(TICK)
	var east: EnemyRig = guard.visual._rigs[GuardVisual.VIEW_EAST]
	assert_object(east).is_not_null()
	assert_bool(east.visible).is_true()
	assert_bool(south.visible).is_false()

	guard.position = FAR_AWAY
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_false()
	assert_bool(east.visible).is_true()
	assert_bool(south.visible).is_false()

	guard.position = IN_VIEW
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_true()
	assert_int(guard.visual._rig_view).is_equal(GuardVisual.VIEW_EAST)
	assert_bool(east.visible).is_true()
	assert_bool(south.visible).is_false()


## Las especies sin esqueleto (solo vistas planas) no tienen nada que ocultar.
func test_a_species_without_a_rig_survives_the_culling() -> void:
	var guard: Guard = _guard_with_rig("")
	assert_str(guard.visual.rig_folder).is_equal("")
	guard.visual.set_visible(false)
	guard.visual.set_visible(true)
	assert_object(guard.visual.rig_root).is_null()

	guard._physics_process(TICK)
	assert_object(guard.visual.rig).is_null()
	assert_object(guard.visual.rig_root).is_null()

	guard.position = FAR_AWAY
	guard._physics_process(TICK)
	assert_object(guard.visual.rig).is_null()
	assert_object(guard.visual.rig_root).is_null()


## Sin esqueleto montado, `set_visible` no crea nada.
func test_hiding_before_the_first_rig_does_not_create_anything() -> void:
	var guard: Guard = _guard_with_rig()
	assert_object(guard.visual.rig).is_null()
	assert_object(guard.visual.rig_root).is_null()
	guard.visual.set_visible(false)
	guard.visual.set_visible(true)
	assert_object(guard.visual.rig).is_null()
	assert_object(guard.visual.rig_root).is_null()


## El cadáver también se oculta: `set_visible` va antes del `return` de DOWN.
func test_a_corpse_off_screen_also_hides_the_rig() -> void:
	var guard: Guard = _guard_with_rig()
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_true()

	guard.position = FAR_AWAY
	guard.state = Guard.State.DOWN
	guard._physics_process(TICK)
	assert_bool(guard.visual.rig_root.visible).is_false()
	assert_bool(guard.visual.rig.player.active).is_false()
