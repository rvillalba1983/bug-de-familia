class_name RumorEngine
extends RefCounted
## Testigos, transmisión y deformación de lo ocurrido. Rumores de 4 minutos (P-14).

var _told_counts: Dictionary = {}

## Duración decidida por el director; el resto de valores son provisionales.
const WINDOW: float = 7.0
const TALK_RANGE: float = 130.0
const TELL_CHANCE: float = 0.7
const TWIST_CHANCE: float = 0.35
const LIE_HONESTY: float = 25.0
const HEARD_CONFIDENCE: float = 0.8
const COLLECTIVE_SHARE: float = 0.5
const FORGET_STEP: float = 1.0
const LASTING_IMPORTANCE: float = 70.0
const MAX_VERSIONS: int = 3
## Límite duro provisional al reparto de un rumor (P-14): tope de personajes que lo propagan por evento.
const MAX_TELLERS_PER_EVENT: int = 6
const BELIEF_LIFETIME: float = 1800.0
const LASTING_BELIEF: float = 30.0


func witness(sim: WorldSim, record: Dictionary, npc: NpcState) -> void:
	if npc.beliefs.has(str(int(record["id"]))):
		return
	npc.beliefs[str(int(record["id"]))] = {
		"event": int(record["id"]), "a": record["a"], "b": record["b"], "x": record["x"],
		"where": record["where"], "fragment": false, "source": "", "direct": true, "hops": 0,
		"confidence": 1.0, "time": sim.elapsed, "lied": false, "versions": [],
	}
	npc.remember(int(record["id"]), float(record["importance"]), sim.elapsed, record["type"])


func is_fresh(sim: WorldSim, event_id: int) -> bool:
	var record: Dictionary = sim.truth.get_record(event_id)
	if record.is_empty() or bool(record.get("secret", false)):
		return false
	return sim.elapsed - float(record["time"]) <= WINDOW


## Lo más reciente que este personaje aún quiere contar; -1 si nada.
func fresh_news(sim: WorldSim, npc: NpcState) -> int:
	var index: int = sim.truth.records.size() - 1
	while index >= 0:
		var record: Dictionary = sim.truth.records[index]
		if sim.elapsed - float(record["time"]) > WINDOW:
			return -1
		if npc.beliefs.has(str(index)) and not bool(record.get("secret", false)):
			return index
		index -= 1
	return -1


func step(sim: WorldSim) -> void:
	for teller_id: String in sim.npc_ids:
		var teller: NpcState = sim.npcs[teller_id]
		if not teller.alive:
			continue
		var news: int = fresh_news(sim, teller)
		if news < 0:
			continue
		for hearer_id: String in sim.npc_ids:
			var hearer: NpcState = sim.npcs[hearer_id]
			if hearer == teller or not hearer.alive:
				continue
			if hearer.pos.distance_to(teller.pos) > TALK_RANGE:
				continue
			if not hearer.beliefs.has(str(news)):
				if int(_told_counts.get(news, 0)) >= MAX_TELLERS_PER_EVENT:
					break
				if sim.rng.randf() < TELL_CHANCE * teller.trait_value("sociabilidad") / 50.0:
					tell(sim, teller, hearer, news)
					_told_counts[news] = int(_told_counts.get(news, 0)) + 1
				break
			_compare_versions(teller, hearer, news)


## Transmite la versión del que cuenta. La verdad objetiva no se toca.
func tell(sim: WorldSim, teller: NpcState, hearer: NpcState, event_id: int) -> Dictionary:
	var told: Dictionary = (teller.beliefs[str(event_id)] as Dictionary).duplicate(true)
	told["source"] = teller.id
	told["direct"] = false
	told["hops"] = int(told["hops"]) + 1
	told["confidence"] = float(told["confidence"]) * HEARD_CONFIDENCE
	told["time"] = sim.elapsed
	told["versions"] = []
	_deform(sim, teller, told)
	if teller.species != hearer.species:
		told["fragment"] = true
	hearer.beliefs[str(event_id)] = told
	var record: Dictionary = sim.truth.get_record(event_id)
	hearer.remember(event_id, float(record["importance"]) * 0.6, sim.elapsed, record["type"])
	hearer.feel("intriga", 15.0)
	hearer.relate(teller.id, "confianza", 2.0)
	sim.rumor_told.emit(teller.id, hearer.id, event_id)
	return told


func phrase(sim: WorldSim, belief: Dictionary) -> String:
	var record: Dictionary = sim.truth.get_record(int(belief["event"]))
	if bool(belief["fragment"]):
		return sim.events.fragment_text(belief)
	return sim.events.text_for(record["type"], belief)


func forget_step(sim: WorldSim) -> void:
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		var kept: Array = []
		for memory: Dictionary in npc.memories:
			if float(memory["importance"]) < LASTING_IMPORTANCE:
				memory["importance"] = float(memory["importance"]) - FORGET_STEP
			if float(memory["importance"]) > 0.0:
				kept.append(memory)
			else:
				_forget_source(npc, int(memory["event"]))
		npc.memories = kept


## Lo cotidiano se olvida del todo; lo importante dura toda la partida.
func drop_old_beliefs(sim: WorldSim) -> void:
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		for key: String in npc.beliefs.keys():
			var record: Dictionary = sim.truth.get_record(key.to_int())
			var old: bool = sim.elapsed - float(record["time"]) > BELIEF_LIFETIME
			if old and float(record["importance"]) < LASTING_BELIEF:
				npc.beliefs.erase(key)


func _forget_source(npc: NpcState, event_id: int) -> void:
	var belief: Variant = npc.beliefs.get(str(event_id))
	if belief is Dictionary:
		(belief as Dictionary)["source"] = ""


func _deform(sim: WorldSim, teller: NpcState, told: Dictionary) -> void:
	var lies: bool = teller.trait_value("honestidad") < LIE_HONESTY
	if lies:
		told["lied"] = true
	if lies or sim.rng.randf() < TWIST_CHANCE:
		var other: NpcState = sim.random_alive(sim.rng)
		match sim.rng.randi_range(0, 2):
			0:
				if other != null:
					told["a"] = other.name
			1:
				told["where"] = sim.place_names[sim.rng.randi_range(0, sim.place_names.size() - 1)]
			2:
				told["x"] = sim.events.twist_for(sim, told)


## Dos versiones distintas conviven en el mismo personaje: no es un error.
func _compare_versions(teller: NpcState, hearer: NpcState, event_id: int) -> void:
	var theirs: Dictionary = teller.beliefs[str(event_id)]
	var mine: Dictionary = hearer.beliefs[str(event_id)]
	if theirs["a"] == mine["a"] and theirs["x"] == mine["x"] and theirs["where"] == mine["where"]:
		return
	var versions: Array = mine["versions"]
	var version: String = "%s|%s|%s" % [theirs["a"], theirs["x"], theirs["where"]]
	if not versions.has(version) and versions.size() < MAX_VERSIONS:
		versions.append(version)
		if bool(mine["direct"]):
			hearer.relate(teller.id, "confianza", -6.0)


func update_collective(sim: WorldSim) -> void:
	var members: Dictionary = {}
	var counts: Dictionary = {}
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		if not npc.alive:
			continue
		members[npc.group] = int(members.get(npc.group, 0)) + 1
		for key: String in npc.beliefs:
			if bool(npc.beliefs[key]["fragment"]):
				continue
			var group_counts: Dictionary = counts.get(npc.group, {})
			group_counts[key] = int(group_counts.get(key, 0)) + 1
			counts[npc.group] = group_counts
	for group: String in counts:
		var known: Dictionary = sim.group_beliefs.get(group, {})
		for key: String in counts[group]:
			if float(counts[group][key]) >= float(members[group]) * COLLECTIVE_SHARE:
				known[key] = true
		sim.group_beliefs[group] = known
