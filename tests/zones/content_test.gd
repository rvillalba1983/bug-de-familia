extends GdUnitTestSuite
## Pruebas de contenido: zonas con poblaciÃ³n generan ciudadanos, homes vÃ¡lidos,
## corredores recÃ­procos y los 3 niveles de simulaciÃ³n.

## Zonas con contenido completo: objetos, decorado y actores guionados.
const ZONAS_CON_CONTENIDO: Array[String] = [
	"el_enchufe", "lonja", "antecamara", "camara", "camino", "canon",
	"instalacion", "sendero", "ultima_ruta", "valle",
]


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func test_every_zone_with_population_has_homes() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		for species_id: String in zone.active_species():
			assert_bool(zone.home_area(species_id).has_area()).override_failure_message(
				"%s: %s sin Ã¡rea de home" % [zone_id, species_id]
			).is_equal(true)
			assert_bool(zone.home_gate(species_id) != Vector2.ZERO).override_failure_message(
				"%s: %s sin puerta de home" % [zone_id, species_id]
			).is_equal(true)


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
	assert_bool(zone.live_world.started).is_equal(true)
	assert_int(zone.live_world.citizens.size()).is_greater(0)


func test_zone_with_population_generates_citizens_lonja() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/lonja.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_bool(zone.live_world.started).is_equal(true)
	assert_int(zone.live_world.citizens.size()).is_greater(0)


func test_all_zones_have_valid_floor_rect() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_bool(zone.floor_rect().has_area()).override_failure_message(
			"%s: floor_rect sin Ã¡rea" % zone_id
		).is_equal(true)


func test_all_zones_have_valid_start_point() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_bool(zone.floor_rect().has_point(zone.start())).override_failure_message(
			"%s: start fuera del floor" % zone_id
		).is_equal(true)


func test_all_zones_have_valid_world_size() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_bool(zone.world_size().x > 0 and zone.world_size().y > 0).override_failure_message(
			"%s: world_size invÃ¡lido" % zone_id
		).is_equal(true)


func test_filled_zones_have_objects_decor_and_scripted_actors() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in ZONAS_CON_CONTENIDO:
		var zone: ZoneDefinition = registry.zone(zone_id)
		assert_int(zone.list("props").size()).is_greater(0).override_failure_message(
			"%s: sin decorado" % zone_id
		).is_equal(true)
		assert_int(zone.list("items").size()).is_greater_equal(2).override_failure_message(
			"%s: sin objetos" % zone_id
		).is_equal(true)
		assert_int(zone.list("convertibles").size()).is_greater(0).override_failure_message(
			"%s: sin convertibles" % zone_id
		).is_equal(true)
		assert_int(zone.list_optional("actors").size()).is_equal(2).override_failure_message(
			"%s: sin actores guionados" % zone_id
		).is_equal(true)


func test_filled_zones_place_objects_and_actors_inside_the_floor() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	for zone_id: String in ZONAS_CON_CONTENIDO:
		var zone: ZoneDefinition = registry.zone(zone_id)
		for item: Dictionary in zone.list("items"):
			assert_bool(zone.floor_rect().has_point(zone.point(str(item["at"])))).override_failure_message(
				"%s: el objeto %s estÃ¡ fuera del suelo" % [zone_id, str(item["id"])]
			).is_equal(true)
		for prop: Dictionary in zone.list("props"):
			for punto: Vector2 in zone.points(str(prop["at"])):
				assert_bool(zone.floor_rect().has_point(punto)).is_equal(true).override_failure_message(
					"%s: el decorado %s estÃ¡ fuera del suelo" % [zone_id, str(prop["id_prefix"])]
				)
		for actor: Dictionary in zone.list_optional("actors"):
			var ruta: String = str(actor["route"])
			assert_bool(zone.has(ruta)).is_equal(true).override_failure_message(
				"%s: el actor %s no tiene la ruta %s" % [zone_id, str(actor["id"]), ruta]
			)
			assert_int(zone.points(ruta).size()).is_greater_equal(3).override_failure_message(
				"%s: la ruta %s es demasiado corta" % [zone_id, ruta]
			)
			assert_bool(SpeciesCatalog.has(str(actor["species"]))).is_equal(true).override_failure_message(
				"%s: el actor %s no tiene especie conocida" % [zone_id, str(actor["id"])]
			)
