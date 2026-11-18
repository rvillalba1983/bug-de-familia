extends GdUnitTestSuite

## Fotograma por arma (P-51, rebanada 6) y gesto de conversión.

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


func test_cada_arma_declara_su_tipo_de_gesto() -> void:
	assert_str(str(WeaponCatalog.thrown()["gesture_type"])).is_equal("proyectil")
	assert_str(str(WeaponCatalog.player("a101")["gesture_type"])).is_equal("proyectil")
	assert_str(str(WeaponCatalog.player("a102")["gesture_type"])).is_equal("scatter")
	assert_str(str(WeaponCatalog.player("a104")["gesture_type"])).is_equal("aturdir")


func test_lanzar_chatarra_usa_su_propio_fotograma() -> void:
	var sandbox: Sandbox = _scene()
	var aim: Vector2 = sandbox.player.global_position + Vector2(100.0, 0.0)
	assert_bool(sandbox.combat.throw_at(aim)).is_true()
	assert_str(sandbox.player.action_frames.action).is_equal("lanzar")
	assert_str(sandbox.player.action_frames.current_key()).is_equal("accion_lanzar_0")


func test_atacar_usa_el_fotograma_generico() -> void:
	var sandbox: Sandbox = _scene()
	assert_bool(sandbox.combat.strike(sandbox.guard)).is_true()
	assert_str(sandbox.player.action_frames.action).is_equal("ataque")
	assert_str(sandbox.player.action_frames.current_key()).is_equal("accion_ataque_0")
