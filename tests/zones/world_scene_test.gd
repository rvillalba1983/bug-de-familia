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


## Las IAs fantasma se dibujaban encima del título y del nombre de la zona destino.
## Los textos de la pantalla de carga tienen que quedar por encima de los fantasmas.
func test_loading_texts_draw_above_the_ghosts() -> void:
	var world: GameWorld = scene_runner("res://scenes/world/world.tscn").scene()
	world._on_transition_started("despliegue_cero", "el_enchufe")
	var ghosts: AiSpectres = world.loading.get_node_or_null("Ghosts") as AiSpectres
	assert_object(ghosts).is_not_null()
	if ghosts == null:
		return
	assert_bool(ghosts.visible).is_true()
	var labels: Array[Label] = []
	for key: String in ["Title", "ZoneName", "Hint"]:
		var label: Label = world.loading.get_node_or_null(key) as Label
		assert_object(label).is_not_null().override_failure_message(
			"Falta el texto %s de la pantalla de carga" % key)
		if label != null:
			labels.append(label)
	assert_int(labels.size()).is_equal(3)
	for label: Label in labels:
		assert_int(label.z_index).is_greater(ghosts.z_index).override_failure_message(
			"El texto %s queda detrás de los fantasmas" % label.name)
	world._on_transition_finished("el_enchufe")
