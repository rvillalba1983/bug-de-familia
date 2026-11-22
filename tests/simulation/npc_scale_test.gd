extends GdUnitTestSuite
## Escala visual 30-80 % de toda la población (ADR 0039).

func before_test() -> void:
	TestSupport.reset_session()


func _sim() -> WorldSim:
	var sim: WorldSim = WorldSim.new()
	sim.spawn_areas = {
		"jubilado": Rect2(0.0, 0.0, 300.0, 300.0),
		"mohocrata": Rect2(0.0, 0.0, 300.0, 300.0),
	}
	sim.open_spots = [Vector2(100.0, 100.0), Vector2(200.0, 200.0)]
	sim.gates = {"jubilado": Vector2(5.0, 5.0), "mohocrata": Vector2(6.0, 6.0)}
	sim.start(1234, {})
	return sim


func test_generated_population_stays_within_approved_ranges() -> void:
	var sim: WorldSim = _sim()
	assert_int(sim.npc_ids.size()).is_greater(0)
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		assert_float(npc.visual_scale).is_greater_equal(NpcState.CHILD_SCALE_MIN)
		assert_float(npc.visual_scale).is_less_equal(NpcState.ADULT_SCALE_MAX)
		assert_float(npc.adult_scale).is_greater_equal(NpcState.ADULT_SCALE_MIN)
		assert_float(npc.adult_scale).is_less_equal(NpcState.ADULT_SCALE_MAX)
		if npc.child_grows_at > 0.0:
			assert_float(npc.visual_scale).is_less_equal(NpcState.CHILD_SCALE_MAX)
		else:
			assert_float(npc.visual_scale).is_greater_equal(NpcState.ADULT_SCALE_MIN)


func test_child_reaches_adult_scale_after_child_duration() -> void:
	var sim: WorldSim = _sim()
	var child: NpcState = null
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		if npc.child_grows_at > 0.0:
			child = npc
			break
	assert_bool(child != null).is_true()
	assert_float(child.current_visual_scale(child.child_grows_at - 1.0)) \
		.is_equal(child.visual_scale)
	assert_float(child.current_visual_scale(child.child_grows_at + 1.0)) \
		.is_equal(child.adult_scale)
	sim.tick(NpcState.CHILD_DURATION + 1.0)
	assert_float(child.current_visual_scale(sim.elapsed)).is_equal(child.adult_scale)


func test_to_dict_and_start_preserve_scales() -> void:
	var sim: WorldSim = _sim()
	sim.tick(120.0)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(sim.to_dict()))
	var copy: WorldSim = WorldSim.new()
	copy.start(0, saved)
	assert_int(copy.npc_ids.size()).is_equal(sim.npc_ids.size())
	for id: String in sim.npc_ids:
		var original: NpcState = sim.npcs[id]
		var restored: NpcState = copy.npcs[id]
		## JSON.stringify redondea a seis cifras: la tolerancia evita un falso fallo.
		assert_float(absf(restored.visual_scale - original.visual_scale)) \
			.is_less(0.00001)
		assert_float(absf(restored.adult_scale - original.adult_scale)) \
			.is_less(0.00001)
		assert_float(restored.child_grows_at).is_equal(original.child_grows_at)


func test_stable_adult_scale_is_deterministic_and_in_range() -> void:
	for id: String in ["npc_000001", "progenitor_abuela", "actor_unico", ""]:
		var first: float = NpcState.stable_adult_scale(id)
		assert_float(first).is_greater_equal(NpcState.ADULT_SCALE_MIN)
		assert_float(first).is_less_equal(NpcState.ADULT_SCALE_MAX)
		assert_float(NpcState.stable_adult_scale(id)).is_equal(first)


func test_live_world_propagates_scale_to_citizen_guards() -> void:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	zone.set_definition(ZoneDefinition.load_from("res://data/zones/valle.json"))
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	var world: LiveWorld = zone.live_world
	assert_int(world.citizens.size()).is_greater(0)
	for id: String in world.citizens:
		var guard: Guard = world.citizens[id]
		var npc: NpcState = world.sim.npcs[id]
		assert_float(guard.visual.individual_scale) \
			.is_equal(npc.current_visual_scale(world.sim.elapsed))
	var citizen_guards: Array = world.citizens.values()
	var scripted: int = 0
	for child: Node in zone.actors.get_children():
		if not child is Guard or citizen_guards.has(child):
			continue
		scripted += 1
		var actor_scale: float = (child as Guard).visual.individual_scale
		assert_float(actor_scale).is_greater_equal(NpcState.ADULT_SCALE_MIN)
		assert_float(actor_scale).is_less_equal(NpcState.ADULT_SCALE_MAX)
	assert_int(scripted).is_equal(2)
