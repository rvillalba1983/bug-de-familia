extends GdUnitTestSuite
## Zonas declaradas en data/zones/: esquema, especies activas y accesos.

const DESPLEGUE_CERO_PATH: String = "res://data/zones/despliegue_cero.json"
const EL_ENCHUFE_PATH: String = "res://data/zones/el_enchufe.json"
const LONJA_PATH: String = "res://data/zones/lonja.json"
const CAMARA_PATH: String = "res://data/zones/camara.json"


func before_test() -> void:
	TestSupport.reset_session()


func test_despliegue_cero_keeps_its_reference_geometry() -> void:
	var zone: ZoneDefinition = ZoneDefinition.load_from(DESPLEGUE_CERO_PATH)
	assert_str(zone.id).is_equal("despliegue_cero")
	assert_str(zone.display_name).is_equal("Despliegue Cero")
	assert_vector(zone.world_size()).is_equal(Vector2(3800.0, 2600.0))
	assert_vector(zone.floor_rect().position).is_equal(Vector2(100.0, 100.0))
	assert_vector(zone.start()).is_equal(Vector2(300.0, 1300.0))
	assert_array(zone.species()).is_equal(["jubilado", "mohocrata"])
	assert_array(zone.active_species()).is_equal(["jubilado", "mohocrata"])


func test_zone_with_population_has_active_species() -> void:
	var zone: ZoneDefinition = ZoneDefinition.load_from(EL_ENCHUFE_PATH)
	assert_str(zone.display_name).is_equal("El Enchufe")
	assert_array(zone.active_species()).is_equal(["jubilado", "mohocrata"])
	assert_int(int(zone.population()["jubilado"]["start"])).is_equal(8)


func test_camara_has_eco_and_manada() -> void:
	var zone: ZoneDefinition = ZoneDefinition.load_from(CAMARA_PATH)
	assert_array(zone.species()).is_equal(["eco", "manada"])
	assert_array(zone.planned_species()).is_empty()
	assert_array(zone.active_species()).is_equal(["eco", "manada"])
	assert_int(int(zone.population()["eco"]["start"])).is_equal(8)


func test_lonja_has_jubilado_and_grux() -> void:
	var zone: ZoneDefinition = ZoneDefinition.load_from(LONJA_PATH)
	assert_array(zone.species()).is_equal(["grux", "jubilado"])
	assert_array(zone.active_species()).is_equal(["grux", "jubilado"])
	assert_int(int(zone.population()["jubilado"]["target"])).is_equal(10)
	assert_int(int(zone.population()["grux"]["target"])).is_equal(10)


func test_entry_points_are_inside_the_floor() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		var floor: Rect2 = zone.floor_rect()
		for corridor: Dictionary in zone.corridors():
			var at: Vector2 = zone.entry_point_of(corridor)
			assert_bool(floor.has_point(at)).override_failure_message(
				"%s desde %s: %s fuera de %s" % [zone_id, corridor["to"], at, floor]
			).is_true()


func test_every_corridor_reaches_the_floor_edge() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		for corridor: Dictionary in zone.corridors():
			assert_str(zone.edge_of(corridor["rect"])).override_failure_message(
				"%s hacia %s" % [zone_id, corridor["to"]]
			).is_equal(str(corridor["edge"]))


func test_every_population_species_has_a_home() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		for species_id: String in zone.active_species():
			assert_bool(zone.home_area(species_id).has_area()).override_failure_message(
				"%s: %s sin area" % [zone_id, species_id]
			).is_true()
			assert_bool(zone.home_gate(species_id) != Vector2.ZERO).override_failure_message(
				"%s: %s sin puerta" % [zone_id, species_id]
			).is_true()


func test_shape_blocks_stay_inside_the_world() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		var world: Rect2 = Rect2(Vector2.ZERO, zone.world_size())
		for block: Rect2 in zone.shape_blocks():
			assert_bool(world.encloses(block)).override_failure_message(
				"%s: bloque %s fuera de %s" % [zone_id, block, world]
			).is_true()
