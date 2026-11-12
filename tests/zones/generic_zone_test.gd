extends GdUnitTestSuite
## Escena genérica zone.tscn: geometría, corredores, guardado y mundo vivo.


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func test_generic_zone_mounts_geometry_and_shape_blocks() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/el_enchufe.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_vector(zone.world_size()).is_equal(Vector2(4000.0, 4000.0))
	assert_vector(zone.floor_rect().position).is_equal(Vector2.ZERO)
	assert_int(zone.shape_blocks().size()).is_greater(0)
	assert_int(zone.corridor_rects().size()).is_equal(definition.corridors().size())
	assert_int(zone.save_point_positions().size()).is_equal(4)


func test_generic_zone_nav_blocks_shape_blocks() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/el_enchufe.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	var block: Rect2 = zone.shape_blocks()[0]
	assert_bool(zone.nav.is_walkable(block.get_center())).is_false()
	assert_bool(zone.nav.is_walkable(zone.start_point())).is_true()


func test_generic_zone_creates_fast_travel_interactables() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/el_enchufe.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	var count: int = 0
	for child: Node in zone.actors.get_children():
		if child is Interactable and str((child as Interactable).item_id).begins_with("fast_travel_"):
			count += 1
	assert_int(count).is_equal(zone.save_point_positions().size())


func test_generic_zone_live_world_starts() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/el_enchufe.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	assert_bool(zone.live_world.started).is_true()
	assert_int(zone.live_world.citizens.size()).is_greater(0)
	assert_str(zone.objective_key()).is_equal("ZONE_OBJECTIVE")


func test_corridor_triggers_transition() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from("res://data/zones/el_enchufe.json")
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	var received: Array[String] = []
	zone.transition_requested.connect(func(to: String) -> void: received.append(to))
	zone._on_corridor_entered(zone.player, "cumbre")
	assert_array(received).is_equal(["cumbre"])
