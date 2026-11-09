extends GdUnitTestSuite
## Población, misiones, festividades y coherencia del mundo completo.

const NOV_14_2026: int = 1794657600
const DAY: int = 86400


func after_test() -> void:
	WorldCalendar.forced_local_unix = -1


func _sim(seed_value: int = 11) -> WorldSim:
	var sim: WorldSim = WorldSim.new()
	sim.spawn_areas = {"jubilado": Rect2(0, 0, 300, 300), "mohocrata": Rect2(0, 0, 300, 300)}
	sim.open_spots = [Vector2(100, 100), Vector2(200, 200)]
	sim.gates = {"jubilado": Vector2(5, 5), "mohocrata": Vector2(6, 6)}
	sim.start(seed_value, {})
	return sim


func test_long_run_has_no_incoherent_state() -> void:
	for seed_value: int in range(4):
		var sim: WorldSim = _sim(seed_value)
		for step: int in range(20):
			sim.tick(300.0)
			assert_array(ConsistencyChecker.check(sim)).is_empty()


func test_save_and_reload_many_times_never_duplicates() -> void:
	var sim: WorldSim = _sim()
	for step: int in range(12):
		sim.tick(200.0)
		var copy: WorldSim = WorldSim.new()
		copy.spawn_areas = sim.spawn_areas
		copy.open_spots = sim.open_spots
		copy.gates = sim.gates
		copy.start(0, JSON.parse_string(JSON.stringify(sim.to_dict())))
		assert_array(copy.npc_ids).is_equal(sim.npc_ids)
		assert_int(copy.next_npc).is_equal(sim.next_npc)
		assert_int(copy.truth.digest()).is_equal(sim.truth.digest())
		assert_array(ConsistencyChecker.check(copy)).is_empty()
		sim = copy


func test_dead_do_not_come_back_and_population_recovers_with_new_ids() -> void:
	var sim: WorldSim = _sim()
	var dead: Array = []
	for npc: NpcState in sim.alive_of("jubilado"):
		dead.append(npc.id)
		sim.kill(npc.id)
	sim.tick(1500.0)
	for id: String in dead:
		assert_bool((sim.npcs[id] as NpcState).alive).is_false()
	assert_int(sim.alive_of("jubilado").size()).is_greater(0)
	for npc: NpcState in sim.alive_of("jubilado"):
		assert_array(dead).not_contains([npc.id])
		assert_str(npc.origin).is_not_equal("inicial")


func test_population_never_exceeds_limit() -> void:
	var sim: WorldSim = _sim()
	for step: int in range(30):
		sim.tick(200.0)
		for species: String in sim.species_data:
			assert_int(sim.alive_of(species).size()).is_less_equal(int(sim.species_data[species]["max"]))


func _mission(sim: WorldSim, type: String) -> Dictionary:
	var pair: Array[NpcState] = sim.alive_of("jubilado")
	var record: Dictionary = sim.events.report(sim, type, pair[0].id, pair[1].id, Vector2(50, 50))
	assert_int(record["id"]).is_not_null()
	return sim.missions.open_missions().back()


func test_lost_object_mission_full_flow() -> void:
	var sim: WorldSim = _sim()
	var mission: Dictionary = _mission(sim, "sombrero_perdido")
	var teller: NpcState = sim.npcs[mission["teller"]]
	var option: Array = sim.missions.options_for(teller)[0]
	assert_str(sim.missions.perform(sim, option[1], "contar")).is_not_empty()
	sim.missions.item_taken(sim, option[1])
	assert_str(mission["stage"]).is_equal("recogido")
	sim.missions.perform(sim, option[1], "entregar")
	assert_str(mission["result"]).is_equal("devuelto")
	assert_array(sim.missions.open_missions()).is_empty()


func test_ignored_mission_becomes_a_rumor() -> void:
	var sim: WorldSim = _sim()
	var mission: Dictionary = _mission(sim, "sombrero_perdido")
	var count_before: int = sim.truth.records.size()
	sim.tick(float(sim.missions.templates["pertenencia"]["deadline"]) + 2.0)
	assert_str(mission["result"]).is_equal("ignorada")
	var types: Array = sim.truth.records.slice(count_before).map(func(r: Dictionary) -> String: return r["type"])
	assert_array(types).contains(["oportunidad_perdida"])


func test_festival_today_and_ruin_is_permanent() -> void:
	WorldCalendar.forced_local_unix = NOV_14_2026
	var sim: WorldSim = _sim()
	sim.festivals.update(sim)
	assert_str(sim.festivals.current["id"]).is_equal("referendum_niebla")
	sim.festivals.ruin(sim)
	assert_bool(sim.festivals.ruined).is_true()
	assert_float(float(sim.player_standing["mohocrata"])).is_less(0.0)
	var copy: WorldSim = WorldSim.new()
	copy.start(0, JSON.parse_string(JSON.stringify(sim.to_dict())))
	assert_bool(copy.festivals.ruined).is_true()


func test_closed_game_freezes_world_but_leaves_traces() -> void:
	WorldCalendar.forced_local_unix = NOV_14_2026
	var sim: WorldSim = _sim()
	var elapsed: float = sim.elapsed
	var count: int = sim.truth.records.size()
	WorldCalendar.forced_local_unix = NOV_14_2026 + DAY * 20
	var added: Array = sim.festivals.collect_traces(sim, WorldCalendar.day_index(NOV_14_2026))
	assert_array(added).is_not_empty()
	assert_int(sim.festivals.traces.size()).is_less_equal(FestivalSystem.MAX_TRACES)
	assert_float(sim.elapsed).is_equal(elapsed)
	assert_int(sim.truth.records.size()).is_equal(count)


func test_birth_in_scene_appears_live_once() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/beta/beta_zone.tscn")
	var zone: BetaZone = runner.scene()
	await await_millis(100)
	var world: LiveWorld = zone.live_world
	var count_before: int = world.citizens.size()
	var npc: NpcState = world.sim.spawn("jubilado", BetaLayout.JUB_GATE, "llegado")
	assert_int(world.citizens.size()).is_equal(count_before + 1)
	assert_bool(is_instance_valid(world.citizens[npc.id])).is_true()
	assert_array(ConsistencyChecker.check(world.sim)).is_empty()
	BetaZone.forced_hour = -1


func test_save_and_reload_scene_keeps_same_people() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	var runner: GdUnitSceneRunner = scene_runner("res://scenes/beta/beta_zone.tscn")
	var zone: BetaZone = runner.scene()
	await await_millis(100)
	var world: LiveWorld = zone.live_world
	var victim: String = world.sim.npc_ids[2]
	(world.citizens[victim] as Guard).take_damage(999.0)
	zone.autosave()
	var ids: Array = world.sim.npc_ids.duplicate()
	var runner2: GdUnitSceneRunner = scene_runner("res://scenes/beta/beta_zone.tscn")
	var zone2: BetaZone = runner2.scene()
	await await_millis(100)
	assert_array(zone2.live_world.sim.npc_ids).is_equal(ids)
	assert_bool(zone2.live_world.citizens.has(victim)).is_false()
	assert_bool((zone2.live_world.sim.npcs[victim] as NpcState).alive).is_false()
	BetaZone.forced_hour = -1
