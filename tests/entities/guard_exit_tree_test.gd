extends GdUnitTestSuite
## P-57: `Guard._exit_tree()` no debe liberar dos veces el cono de visión.
##
## El cono cuelga del suelo (ground). Si el suelo se libera antes que el
## guardia, `_view` ya no es válido y llamar `queue_free()` sobre él daba
## `SCRIPT ERROR: Cannot call method 'queue_free' on a previously freed
## instance` (P-57). El guardia se registra DESPUÉS del suelo para forzar
## ese orden de liberación y comprobar que no hay error.

const RIG_FOLDER: String = "res://art/shared/rig/jubilado_hierro"
const TICK: float = 0.016
const IN_VIEW: Vector2 = Vector2(120.0, 120.0)


func before_test() -> void:
	TestSupport.reset_session()


## Suelo primero, guardia después: el suelo se libera primero. Con el código
## antiguo esto abría un bucle `debug>` en headless con `-d`.
func _guard_after_ground() -> Guard:
	var ground: Node2D = auto_free(Node2D.new())
	add_child(ground)
	var guard: Guard = auto_free(Guard.new())
	add_child(guard)
	guard.visual.rig_folder = RIG_FOLDER
	guard.passive = true
	var patrol: Array[Vector2] = [IN_VIEW, IN_VIEW + Vector2(64.0, 0.0)]
	guard.setup(patrol, ground)
	return guard


func test_guard_frees_cleanly_when_ground_is_freed_first() -> void:
	var guard: Guard = _guard_after_ground()
	guard._physics_process(TICK)
	assert_object(guard.visual.rig_root).is_not_null()
	# Si llegamos aquí sin colgarnos en `debug>`, el fix funciona.
	assert_bool(is_instance_valid(guard)).is_true()
