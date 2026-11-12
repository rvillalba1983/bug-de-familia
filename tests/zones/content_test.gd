extends GdUnitTestSuite
## Pruebas de contenido: zonas con población generan ciudadanos, homes válidos,
## corredores recíprocos y los 3 niveles de simulación.


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func test_every_zone_with_population_has_homes() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		for species_id: String in zone.active_species():
			assert_bool(zone.home_area(species_id).has_area()).override_failure_message(
				"%s: %s sin área de home" % [zone_id, species_id]
			).is_true()
			assert_bool(zone.home_gate(species_id) != Vector2.ZERO).override_failure_message(
				"%s: %s sin puerta de home" % [zone_id, species_id]
			).is_true()


func test_every_zone_with_population_has_corridors_to_neighbors() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		if zone.active_species().is_empty():
			continue
		assert_int(zone.corridors().size()).is_greater(0).override_failure_message(
			"%s: zona poblada sin corredores" % zone_id
		)


func test_zone_with_population_generates_citizens() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/el_enchufe.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)


func test_zone_with_population_generates_citizens_lonja() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/lonja.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)


func test_all_zones_have_valid_floor_rect() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_bool(zone.floor_rect().has_area()).override_failure_message(
			"%s: floor_rect sin área" % zone_id
		).is_true()


func test_all_zones_have_valid_start_point() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_bool(zone.floor_rect().has_point(zone.start())).override_failure_message(
			"%s: start fuera del floor" % zone_id
		).is_true()


func test_all_zones_have_valid_world_size() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_bool(zone.world_size().x > 0 and zone.world_size().y > 0).override_failure_message(
			"%s: world_size inválido" % zone_id
		).is_true()
