extends GdUnitTestSuite
## Escena genérica zone.tscn: geometría, corredores, guardado y mundo vivo.


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func _mount(zone_path: String) -> ZoneBase:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from(zone_path)
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	return zone


func test_generic_zone_mounts_geometry_and_shape_blocks() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	assert_vector(zone.world_size()).is_equal(Vector2(4000.0, 4000.0))
	assert_vector(zone.floor_rect().position).is_equal(Vector2.ZERO)
	assert_int(zone.shape_blocks().size()).is_greater(0)
	assert_int(zone.corridor_rects().size()).is_equal(zone.zone_definition().corridors().size())
	assert_int(zone.save_point_positions().size()).is_equal(4)


func test_generic_zone_nav_blocks_shape_blocks() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var block: Rect2 = zone.shape_blocks()[0]
	assert_bool(zone.nav.is_walkable(block.get_center())).is_false()
	assert_bool(zone.nav.is_walkable(zone.start_point())).is_true()


func test_generic_zone_creates_fast_travel_interactables() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var count: int = 0
	for child: Node in zone.actors.get_children():
		if child is Interactable and str((child as Interactable).item_id).begins_with("fast_travel_"):
			count += 1
	assert_int(count).is_equal(zone.save_point_positions().size())


func test_generic_zone_live_world_starts() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)
	assert_str(zone.objective_key()).is_equal("ZONE_OBJECTIVE")


func test_corridor_triggers_transition() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	var received: Array[String] = []
	zone.transition_requested.connect(func(to: String) -> void: received.append(to))
	zone._on_corridor_entered(zone.player, "cumbre")
	assert_array(received).is_equal(["cumbre"])


## La sección «actors» es opcional: solo tres zonas la declaran. Montar las otras
## no debe quejar ni dejar a nadie sin facción.
func test_zone_without_actors_section_mounts_without_errors() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/camara.json")
	assert_bool(zone.zone_definition().data.has("actors")).is_false()
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)
	## Sin actores guionados, los únicos cuerpos son los ciudadanos del mundo vivo.
	assert_int(zone.guards().size()).is_equal(zone.live_world.citizens.size())


## Los habitantes y los actores guionados llevan su bando: sin él, las acciones
## que filtran por facción no encuentran a nadie en las zonas genéricas.
func test_citizens_and_actors_have_their_faction() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/el_enchufe.json")
	for id: String in zone.live_world.citizens:
		var citizen: Guard = zone.live_world.citizens[id]
		var npc: NpcState = zone.live_world.sim.npcs[id]
		assert_str(citizen.detector.faction).is_equal(npc.species).override_failure_message(
			"El ciudadano %s no lleva su bando" % id
		)
	for enemy: Guard in zone.guards():
		var actor_id: String = zone.id_of_guard(enemy)
		assert_str(enemy.detector.faction).is_not_empty().override_failure_message(
			"El actor %s no lleva bando" % actor_id
		)
