extends GdUnitTestSuite

## El gesto de conversión (P-51): solo visual, no cambia el flujo de la conversión.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _target(id: String) -> Convertible:
	for node: Node in get_tree().get_nodes_in_group(Convertible.GROUP):
		if (node as Convertible).entity_id == id:
			return node as Convertible
	return null


func test_convertir_levanta_las_manos_al_empezar() -> void:
	var sandbox: Sandbox = _scene()
	var target: Convertible = _target(Sandbox.ID_CRATE)
	assert_object(target).is_not_null()
	sandbox.conversion.begin_on(target)
	assert_str(sandbox.player.action_frames.action).is_equal("convertir")
	assert_str(sandbox.player.action_frames.current_key()).is_equal("accion_convertir_0")
