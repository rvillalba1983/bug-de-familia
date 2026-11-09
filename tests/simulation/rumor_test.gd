extends GdUnitTestSuite
## Conocimiento con procedencia y rumores de 4 minutos.


func _sim() -> WorldSim:
	var sim: WorldSim = WorldSim.new()
	sim.spawn_areas = {"jubilado": Rect2(0, 0, 10, 10), "mohocrata": Rect2(0, 0, 10, 10)}
	sim.start(5, {})
	return sim


func _record(sim: WorldSim) -> Dictionary:
	return sim.truth.add({
		"type": "trueque", "actors": [], "cause": -1, "time": sim.elapsed, "importance": 40.0,
		"a": "Paco", "b": "Espora", "x": "un tornillo", "where": "el bosque",
	})


func test_generates_population_without_duplicates() -> void:
	var sim: WorldSim = _sim()
	assert_int(sim.npc_ids.size()).is_equal(16)
	var unique: Dictionary = {}
	for id: String in sim.npc_ids:
		unique[id] = true
	assert_int(unique.size()).is_equal(16)


func test_same_seed_same_world() -> void:
	assert_dict(_sim().to_dict()).is_equal(_sim().to_dict())


func test_rumor_keeps_provenance_and_truth_is_untouched() -> void:
	var sim: WorldSim = _sim()
	var record: Dictionary = _record(sim)
	var digest: int = sim.truth.digest()
	var a: NpcState = sim.npcs[sim.npc_ids[0]]
	var b: NpcState = sim.npcs[sim.npc_ids[1]]
	sim.rumors.witness(sim, record, a)
	sim.rumors.tell(sim, a, b, 0)
	var belief: Dictionary = b.beliefs["0"]
	assert_str(belief["source"]).is_equal(a.id)
	assert_bool(belief["direct"]).is_false()
	assert_int(sim.truth.digest()).is_equal(digest)
	assert_str(sim.truth.get_record(0)["a"]).is_equal("Paco")


func test_cross_species_gets_only_fragment() -> void:
	var sim: WorldSim = _sim()
	var record: Dictionary = _record(sim)
	var a: NpcState = sim.alive_of("jubilado")[0]
	var b: NpcState = sim.alive_of("mohocrata")[0]
	sim.rumors.witness(sim, record, a)
	assert_bool(sim.rumors.tell(sim, a, b, 0)["fragment"]).is_true()


func test_spreads_by_contact_only_within_four_minutes() -> void:
	var sim: WorldSim = _sim()
	var near: Array[NpcState] = sim.alive_of("jubilado")
	for npc: NpcState in near:
		npc.pos = Vector2.ZERO
		npc.personality["sociabilidad"] = 100.0
	var far: NpcState = sim.alive_of("mohocrata")[0]
	for npc: NpcState in sim.alive_of("mohocrata"):
		npc.pos = Vector2(5000, 5000)
	sim.rumors.witness(sim, _record(sim), near[0])
	sim.tick(30.0)
	assert_bool(near[1].beliefs.has("0")).is_true()
	assert_bool(far.beliefs.has("0")).is_false()
	far.pos = Vector2.ZERO
	sim.elapsed += RumorEngine.WINDOW
	sim.tick(30.0)
	assert_bool(far.beliefs.has("0")).is_false()


func test_save_roundtrip_is_identical() -> void:
	var sim: WorldSim = _sim()
	sim.rumors.witness(sim, _record(sim), sim.npcs[sim.npc_ids[0]])
	sim.tick(5.0)
	var saved: Dictionary = JSON.parse_string(JSON.stringify(sim.to_dict()))
	var copy: WorldSim = WorldSim.new()
	copy.start(0, saved)
	assert_array(copy.npc_ids).is_equal(sim.npc_ids)
	assert_int(copy.rng.state).is_equal(sim.rng.state)
	assert_int(copy.truth.digest()).is_equal(sim.truth.digest())


func test_citizens_appear_in_the_zone_and_can_be_talked_to() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/beta/beta_zone.tscn")
	var zone: BetaZone = runner.scene()
	await await_millis(100)
	var world: LiveWorld = zone.live_world
	assert_int(world.citizens.size()).is_equal(16)
	var id: String = world.sim.npc_ids[0]
	world.dialogue.open(world.sim.npcs[id])
	assert_int(world.dialogue.options().size()).is_greater(2)
	world.dialogue.close()
	var guard: Guard = world.citizens[id]
	guard.take_damage(999.0)
	assert_bool((world.sim.npcs[id] as NpcState).alive).is_false()
	BetaZone.forced_hour = -1
