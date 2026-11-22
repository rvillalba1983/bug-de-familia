extends GdUnitTestSuite
## P-59: señales que alimentan los avisos de las IAs. Un rumor nace una sola vez
## y una migración se avisa cuando la población estadística cambia de verdad.


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


func test_rumor_born_fires_once_for_the_first_witness() -> void:
	var sim: WorldSim = _sim()
	var born: Array[int] = []
	sim.rumor_born.connect(func(event_id: int) -> void: born.append(event_id))
	var record: Dictionary = _record(sim)
	for index: int in range(4):
		sim.rumors.witness(sim, record, sim.npcs[sim.npc_ids[index]])
	assert_array(born).is_equal([int(record["id"])])


func test_same_rumor_is_not_announced_twice_after_reload() -> void:
	var sim: WorldSim = _sim()
	var born: Array[int] = []
	sim.rumor_born.connect(func(event_id: int) -> void: born.append(event_id))
	var record: Dictionary = _record(sim)
	sim.rumors.witness(sim, record, sim.npcs[sim.npc_ids[0]])
	sim.rumors.witness(sim, record, sim.npcs[sim.npc_ids[1]])
	assert_int(born.size()).is_equal(1)
