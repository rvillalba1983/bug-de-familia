class_name ConsistencyChecker
extends RefCounted
## Comprueba que el mundo no contiene imposibles. Las creencias contradictorias son válidas.


static func check(sim: WorldSim) -> Array[String]:
	var problems: Array[String] = []
	_check_ids(sim, problems)
	_check_truth(sim, problems)
	_check_beliefs(sim, problems)
	_check_population(sim, problems)
	_check_missions(sim, problems)
	return problems


static func _check_ids(sim: WorldSim, problems: Array[String]) -> void:
	var seen: Dictionary = {}
	for id: String in sim.npc_ids:
		if seen.has(id):
			problems.append("%s: identificador duplicado" % id)
		seen[id] = true
		if not sim.npcs.has(id):
			problems.append("%s: sin estado" % id)
	if sim.npcs.size() != sim.npc_ids.size():
		problems.append("npcs: el registro no coincide con la lista")


static func _check_truth(sim: WorldSim, problems: Array[String]) -> void:
	for index: int in range(sim.truth.records.size()):
		var record: Dictionary = sim.truth.records[index]
		var id: int = int(record["id"])
		if id != index:
			problems.append("verdad %d: id desordenado" % index)
		if float(record["time"]) > sim.elapsed + 0.01:
			problems.append("verdad %d: ocurre en el futuro" % id)
		if int(record["depth"]) > EventSystem.MAX_CHAIN:
			problems.append("verdad %d: cadena demasiado larga" % id)
		var cause: int = int(record["cause"])
		if cause >= id:
			problems.append("verdad %d: causa posterior" % id)


static func _check_beliefs(sim: WorldSim, problems: Array[String]) -> void:
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		for key: String in npc.beliefs:
			var belief: Dictionary = npc.beliefs[key]
			var record: Dictionary = sim.truth.get_record(key.to_int())
			if record.is_empty():
				problems.append("%s: cree algo que no existe (%s)" % [id, key])
				continue
			if float(belief["time"]) + 0.01 < float(record["time"]):
				problems.append("%s: lo supo antes de ocurrir (%s)" % [id, key])
			var source: String = belief["source"]
			if not bool(belief["direct"]) and not source.is_empty() and not sim.npcs.has(source):
				problems.append("%s: fuente inexistente (%s)" % [id, key])


static func _check_population(sim: WorldSim, problems: Array[String]) -> void:
	for species: String in sim.species_data:
		var count: int = sim.alive_of(species).size()
		var limit: int = int(sim.species_data[species]["max"])
		if count > limit:
			problems.append("%s: %d vivos, máximo %d" % [species, count, limit])


static func _check_missions(sim: WorldSim, problems: Array[String]) -> void:
	for mission: Dictionary in sim.missions.open_missions():
		var teller: NpcState = sim.npcs.get(mission["teller"])
		if teller == null or not teller.alive:
			problems.append("misión %d: quien la cuenta no está vivo" % int(mission["id"]))
