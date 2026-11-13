extends GdUnitTestSuite
## Escena raíz world.tscn: gestor montado y pantalla de carga.


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func test_world_mounts_zone_manager_and_despliegue_cero() -> void:
	var world: GameWorld = scene_runner("res://scenes/world/world.tscn").scene()
	assert_object(world.manager).is_not_null()
	assert_str(world.manager.current_id).is_equal("despliegue_cero")
	assert_bool(world.loading.visible).is_false()


func test_loading_screen_shows_destination_name() -> void:
	var world: GameWorld = scene_runner("res://scenes/world/world.tscn").scene()
	world._on_transition_started("despliegue_cero", "el_enchufe")
	assert_str(world._zone_label.text).is_equal("El Enchufe")
	assert_bool(world.loading.visible).is_true()
	assert_bool(world.ghosts.visible).is_true()
	world._on_transition_finished("el_enchufe")
	assert_bool(world.loading.visible).is_false()
