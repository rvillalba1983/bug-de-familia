extends GdUnitTestSuite
## Grafo de 24 zonas: índice, reciprocidad, alcance y niveles por saltos.


func test_index_has_twenty_four_zones() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	assert_int(registry.count()).is_equal(24)
	assert_array(registry.graph.ids()).is_equal(registry.ids())


func test_every_connection_is_reciprocal() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	assert_array(registry.graph.missing_reciprocal()).is_empty()


func test_all_zones_are_reachable() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	assert_array(registry.graph.unreachable_from("beta")).is_empty()


func test_beta_has_five_neighbours() -> void:
	var graph: WorldGraph = ZoneRegistry.load_default().graph
	assert_array(graph.neighbours("beta")).is_equal(
		["asamblea", "cumbre", "desguace", "el_enchufe", "ultima_ruta"]
	)


func test_hops_are_symmetric_and_bounded() -> void:
	var graph: WorldGraph = ZoneRegistry.load_default().graph
	assert_int(graph.hops("beta", "beta")).is_equal(0)
	assert_int(graph.hops("beta", "el_enchufe")).is_equal(1)
	assert_int(graph.hops("el_enchufe", "beta")).is_equal(1)
	assert_int(graph.hops("beta", "cementerio")).is_greater(1)
	assert_int(graph.hops("beta", "no_existe")).is_equal(-1)


func test_corridor_sides_are_opposite_in_both_zones() -> void:
	var registry: ZoneRegistry = ZoneRegistry.load_default()
	var opposites: Dictionary = {
		"north": "south", "south": "north", "west": "east", "east": "west"
	}
	for zone_id: String in registry.ids():
		var zone: ZoneDefinition = registry.zone(zone_id)
		for corridor: Dictionary in zone.corridors():
			var other: ZoneDefinition = registry.zone(str(corridor["to"]))
			var back: Dictionary = other.corridor_to(zone_id)
			assert_bool(not back.is_empty()).override_failure_message(
				"%s -> %s sin vuelta" % [zone_id, corridor["to"]]
			).is_true()
			assert_str(str(back["edge"])).is_equal(str(opposites[corridor["edge"]]))
