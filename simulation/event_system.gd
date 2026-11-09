class_name EventSystem
extends RefCounted
## Acontecimientos del catálogo: su verdad, sus testigos y sus consecuencias.

const PATH: String = "res://data/world/events.json"
## Máximo decidido por el director (P-13). El resto es provisional.
const MAX_CHAIN: int = 4
const STAGE_TIME: float = 12.0
const MIN_INTERVAL: float = 35.0
const MAX_INTERVAL: float = 70.0
const WITNESS_RANGE: float = 420.0
const PAIR_RANGE: float = 1400.0
const SECONDS_PER_DAY: int = 86400
const FIRST_INTERVAL: float = 20.0
const NOBODY: String = "alguien"
const PLAYER_NAME: String = "el Sujeto Sobrante"

var catalog: Dictionary = {}
var staged: Array = []
var pending: Array = []
var last_fired: Dictionary = {}
var timer: float = FIRST_INTERVAL
var moods: Dictionary = {}


func _init() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	for entry: Dictionary in data["events"]:
		catalog[entry["id"]] = entry


func step(sim: WorldSim) -> void:
	_run_pending(sim)
	_resolve_staged(sim)
	timer -= WorldSim.STEP
	if timer <= 0.0:
		timer = sim.rng.randf_range(MIN_INTERVAL, MAX_INTERVAL)
		_stage_random(sim)


## Prepara un suceso: sus protagonistas tienen unos segundos para acudir al lugar.
func stage(sim: WorldSim, type: String, cause: int, depth: int) -> bool:
	if depth > MAX_CHAIN or _on_cooldown(sim, type):
		return false
	var spec: Dictionary = catalog[type]
	var actors: Array = _cast(sim, spec, cause)
	if actors.is_empty():
		return false
	var place: Vector2 = _meeting_point(sim, actors)
	last_fired[type] = sim.elapsed
	var entry: Dictionary = {
		"type": type, "actors": actors, "x": place.x, "y": place.y,
		"at": sim.elapsed + STAGE_TIME, "cause": cause, "depth": depth,
	}
	staged.append(entry)
	sim.event_staged.emit(entry)
	return true


## Un hecho ya ocurrido fuera del catálogo automático, como una muerte a manos del jugador.
func report(sim: WorldSim, type: String, a: String, b: String, place: Vector2) -> Dictionary:
	return _apply(sim, type, [a] if b.is_empty() else [a, b], place, -1, 1)


func text_for(type: String, belief: Dictionary) -> String:
	return _contract((catalog[type]["text"] as String).format(
		{"a": belief["a"], "b": belief["b"], "x": belief["x"], "w": belief["where"]}
	))


func fragment_text(belief: Dictionary) -> String:
	return _contract("Me ha llegado algo de %s, por %s. No sé más." % [belief["x"], belief["where"]])


## Los lugares y objetos llevan artículo: «a el barrio» debe leerse «al barrio».
func _contract(text: String) -> String:
	return text.replace(" a el ", " al ").replace(" de el ", " del ")


func twist_for(sim: WorldSim, belief: Dictionary) -> String:
	var record: Dictionary = sim.truth.get_record(int(belief["event"]))
	var things: Array = catalog[record["type"]]["things"]
	return things[sim.rng.randi_range(0, things.size() - 1)]


func mood_of(species: String) -> String:
	var entry: Variant = moods.get(species)
	if entry is Dictionary and int((entry as Dictionary)["until"]) > WorldCalendar.now_local():
		return (entry as Dictionary)["event"]
	return ""


func to_dict() -> Dictionary:
	return {
		"staged": staged, "pending": pending, "last_fired": last_fired,
		"timer": timer, "moods": moods,
	}


func restore(data: Dictionary) -> void:
	staged = data["staged"]
	pending = data["pending"]
	last_fired = data["last_fired"]
	timer = float(data["timer"])
	moods = data["moods"]


func _on_cooldown(sim: WorldSim, type: String) -> bool:
	if not last_fired.has(type):
		return false
	return sim.elapsed - float(last_fired[type]) < float(catalog[type]["cooldown"])


func _run_pending(sim: WorldSim) -> void:
	var waiting: Array = []
	for entry: Dictionary in pending:
		if float(entry["at"]) <= sim.elapsed:
			stage(sim, entry["type"], int(entry["cause"]), int(entry["depth"]))
		else:
			waiting.append(entry)
	pending = waiting


func _resolve_staged(sim: WorldSim) -> void:
	var waiting: Array = []
	for entry: Dictionary in staged:
		if float(entry["at"]) > sim.elapsed:
			waiting.append(entry)
		elif _cast_is_alive(sim, entry["actors"]):
			var place: Vector2 = Vector2(float(entry["x"]), float(entry["y"]))
			_apply(sim, entry["type"], entry["actors"], place, int(entry["cause"]), int(entry["depth"]))
	staged = waiting


func _cast_is_alive(sim: WorldSim, actors: Array) -> bool:
	for id: String in actors:
		if sim.npcs.has(id) and not (sim.npcs[id] as NpcState).alive:
			return false
	return true


func _stage_random(sim: WorldSim) -> void:
	var options: Array = []
	var total: float = 0.0
	for type: String in catalog:
		if float(catalog[type]["weight"]) > 0.0 and not _on_cooldown(sim, type):
			options.append(type)
			total += float(catalog[type]["weight"])
	var roll: float = sim.rng.randf() * total
	for type: String in options:
		roll -= float(catalog[type]["weight"])
		if roll <= 0.0:
			stage(sim, type, -1, 1)
			return


func _cast(sim: WorldSim, spec: Dictionary, cause: int) -> Array:
	match spec["cast"]:
		"solo":
			var pool: Array[NpcState] = _pool(sim, spec.get("species", ""))
			return [] if pool.is_empty() else [pool[sim.rng.randi_range(0, pool.size() - 1)].id]
		"pair_same":
			return _pair(sim, spec, false)
		"pair_rival":
			return _pair(sim, spec, true)
		"chain_same":
			return _previous_pair(sim, cause)
		"chain_mourner":
			return _mourners(sim, cause, false)
		"chain_avenger":
			return _mourners(sim, cause, true)
	return []


func _pool(sim: WorldSim, species: String) -> Array[NpcState]:
	var pool: Array[NpcState] = []
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		if npc.alive and (species.is_empty() or npc.species == species):
			pool.append(npc)
	return pool


func _pair(sim: WorldSim, spec: Dictionary, rivals: bool) -> Array:
	var pool: Array[NpcState] = _pool(sim, spec.get("species", ""))
	if pool.size() < 2:
		return []
	var first: NpcState = pool[sim.rng.randi_range(0, pool.size() - 1)]
	var best: NpcState = null
	for other: NpcState in pool:
		if other == first or (other.species != first.species) != rivals:
			continue
		if first.pos.distance_to(other.pos) > PAIR_RANGE:
			continue
		if best == null or first.pos.distance_to(other.pos) < first.pos.distance_to(best.pos):
			best = other
	return [] if best == null else [first.id, best.id]


func _previous_pair(sim: WorldSim, cause: int) -> Array:
	var record: Dictionary = sim.truth.get_record(cause)
	if record.is_empty() or (record["actors"] as Array).size() < 2:
		return []
	var actors: Array = record["actors"]
	return actors.duplicate() if _cast_is_alive(sim, actors) else []


## Quien llora al muerto; para vengarlo, además hace falta un culpable vivo.
func _mourners(sim: WorldSim, cause: int, avenge: bool) -> Array:
	var record: Dictionary = sim.truth.get_record(cause)
	if record.is_empty() or str(record.get("victim", "")).is_empty():
		return []
	var victim: NpcState = sim.npcs.get(record["victim"])
	if victim == null:
		return []
	var mourner: NpcState = null
	for other: NpcState in _pool(sim, victim.species):
		if str(record.get("killer", "")) == other.id:
			continue
		if mourner == null or victim.pos.distance_to(other.pos) < victim.pos.distance_to(mourner.pos):
			mourner = other
	if mourner == null:
		return []
	if not avenge:
		return [mourner.id]
	var killer: String = str(record.get("killer", ""))
	if not sim.npcs.has(killer) or not (sim.npcs[killer] as NpcState).alive:
		return []
	return [mourner.id, killer]


func _meeting_point(sim: WorldSim, actors: Array) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	for id: String in actors:
		center += (sim.npcs[id] as NpcState).pos
	center /= float(actors.size())
	var best: Vector2 = center
	for spot: Vector2 in sim.open_spots:
		if best == center or spot.distance_to(center) < best.distance_to(center):
			best = spot
	return best


func _name_of(sim: WorldSim, id: String) -> String:
	if id == WorldSim.PLAYER_ID:
		return PLAYER_NAME
	return (sim.npcs[id] as NpcState).name if sim.npcs.has(id) else NOBODY


func _apply(
	sim: WorldSim, type: String, actors: Array, place: Vector2, cause: int, depth: int
) -> Dictionary:
	var spec: Dictionary = catalog[type]
	var things: Array = spec["things"]
	for id: String in actors:
		if sim.npcs.has(id) and (sim.npcs[id] as NpcState).alive:
			(sim.npcs[id] as NpcState).pos = place
	var record: Dictionary = sim.truth.add({
		"type": type, "category": spec["category"], "actors": actors, "cause": cause,
		"depth": depth, "time": sim.elapsed, "px": place.x, "py": place.y,
		"importance": float(spec["importance"]), "where": sim.place_name(place),
		"a": _name_of(sim, actors[0]), "b": _name_of(sim, actors[1]) if actors.size() > 1 else NOBODY,
		"x": things[sim.rng.randi_range(0, things.size() - 1)],
		"witnesses": [], "victim": "", "killer": "",
	})
	_apply_victim(sim, spec, record, actors)
	_notify_witnesses(sim, spec, record, place)
	_apply_social(sim, spec, actors)
	_schedule_next(sim, spec, record, depth)
	sim.missions.on_event(sim, record)
	sim.event_happened.emit(record)
	return sim.truth.get_record(int(record["id"]))


func _apply_victim(sim: WorldSim, spec: Dictionary, record: Dictionary, actors: Array) -> void:
	if spec["cast"] == "reported":
		record["victim"] = actors[1]
		record["killer"] = actors[0]
		return
	if spec.has("kill") and actors.size() > 1 and sim.rng.randf() < float(spec["kill"]):
		record["victim"] = actors[1]
		record["killer"] = actors[0]
		sim.kill(actors[1])
	elif spec.has("kill_a") and sim.rng.randf() < float(spec["kill_a"]):
		record["victim"] = actors[0]
		sim.kill(actors[0])


func _notify_witnesses(sim: WorldSim, spec: Dictionary, record: Dictionary, place: Vector2) -> void:
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		if not npc.alive or npc.pos.distance_to(place) > WITNESS_RANGE:
			continue
		(record["witnesses"] as Array).append(id)
		sim.rumors.witness(sim, record, npc)
		var feelings: Dictionary = spec.get("feel_all", {})
		for key: String in feelings:
			npc.feel(key, float(feelings[key]))


func _apply_social(sim: WorldSim, spec: Dictionary, actors: Array) -> void:
	_feel(sim, actors[0], spec.get("feel_a", {}))
	if actors.size() > 1:
		_feel(sim, actors[1], spec.get("feel_b", {}))
	if spec.has("relation") and actors.size() > 1:
		var amount: float = float(spec["relation"])
		var first: NpcState = sim.npcs.get(actors[0])
		var second: NpcState = sim.npcs.get(actors[1])
		if first != null and second != null:
			first.relate(second.id, "afecto", amount)
			second.relate(first.id, "afecto", amount)
			if first.species != second.species:
				sim.change_species_relation(amount)
	if spec.has("standing"):
		var victim: NpcState = sim.npcs.get(actors[1])
		if victim != null:
			sim.change_standing(victim.species, float(spec["standing"]))
	if spec.has("mood_days"):
		var until: int = WorldCalendar.now_local() + int(spec["mood_days"]) * SECONDS_PER_DAY
		for species: String in sim.species_data:
			moods[species] = {"event": spec["id"], "until": until}


func _feel(sim: WorldSim, id: String, feelings: Dictionary) -> void:
	if not sim.npcs.has(id):
		return
	for key: String in feelings:
		(sim.npcs[id] as NpcState).feel(key, float(feelings[key]))


func _schedule_next(sim: WorldSim, spec: Dictionary, record: Dictionary, depth: int) -> void:
	if depth >= MAX_CHAIN:
		return
	for option: Dictionary in spec.get("next", []):
		if sim.rng.randf() < float(option["chance"]):
			pending.append({
				"type": option["event"], "at": sim.elapsed + float(option["delay"]),
				"cause": int(record["id"]), "depth": depth + 1,
			})
