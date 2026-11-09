extends GdUnitTestSuite
## Acontecimientos: verdad objetiva, cadenas y enfriamiento.


func _sim(seed_value: int = 7) -> WorldSim:
	var sim: WorldSim = WorldSim.new()
	sim.spawn_areas = {"jubilado": Rect2(0, 0, 200, 200), "mohocrata": Rect2(0, 0, 200, 200)}
	sim.open_spots = [Vector2(100, 100)]
	sim.start(seed_value, {})
	return sim


func test_chains_never_exceed_four_steps() -> void:
	for seed_value: int in range(6):
		var sim: WorldSim = _sim(seed_value)
		sim.tick(3000.0)
		assert_int(sim.truth.records.size()).is_greater(10)
		for record: Dictionary in sim.truth.records:
			assert_int(int(record["depth"])).is_less_equal(EventSystem.MAX_CHAIN)
			if int(record["cause"]) >= 0:
				var parent: Dictionary = sim.truth.get_record(int(record["cause"]))
				assert_int(int(record["depth"])).is_equal(int(parent["depth"]) + 1)


func test_same_event_respects_cooldown() -> void:
	var sim: WorldSim = _sim()
	sim.tick(3000.0)
	var last: Dictionary = {}
	for record: Dictionary in sim.truth.records:
		var type: String = record["type"]
		if last.has(type):
			var gap: float = float(record["time"]) - float(last[type])
			assert_float(gap + 0.5).is_greater_equal(float(sim.events.catalog[type]["cooldown"]))
		last[type] = record["time"]


func test_dead_never_act_and_witnesses_were_present() -> void:
	var sim: WorldSim = _sim(3)
	var died_at: Dictionary = {}
	sim.npc_died.connect(func(npc: NpcState) -> void: died_at[npc.id] = sim.elapsed)
	sim.tick(4000.0)
	for record: Dictionary in sim.truth.records:
		var main: String = record["actors"][0]
		if died_at.has(main) and record["victim"] != main:
			assert_float(float(record["time"])).is_less_equal(float(died_at[main]))


func test_player_killing_is_remembered_by_that_society_only() -> void:
	var sim: WorldSim = _sim()
	var victim: NpcState = sim.alive_of("jubilado")[0]
	sim.kill(victim.id)
	sim.events.report(sim, "el_sobrante_mata", WorldSim.PLAYER_ID, victim.id, victim.pos)
	assert_float(float(sim.player_standing["jubilado"])).is_less(0.0)
	assert_bool(sim.player_standing.has("mohocrata")).is_false()


func test_world_runs_the_same_with_the_same_seed() -> void:
	var a: WorldSim = _sim(9)
	var b: WorldSim = _sim(9)
	a.tick(900.0)
	b.tick(900.0)
	assert_int(a.truth.digest()).is_equal(b.truth.digest())


func test_place_names_contract_in_spanish() -> void:
	var sim: WorldSim = _sim()
	var belief: Dictionary = {"a": "Paco", "b": "Encarna", "x": "sin avisar", "where": "el barrio sur"}
	assert_str(sim.events.text_for("llegada", belief)).is_equal("Paco ha llegado al barrio sur, sin avisar")
	belief["x"] = "el sombrero"
	assert_str(sim.events.fragment_text(belief)).is_equal("Me ha llegado algo del sombrero, por el barrio sur. No sé más.")
