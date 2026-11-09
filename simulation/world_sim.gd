class_name WorldSim
extends RefCounted
## Estado lógico del mundo vivo. No conoce nodos: se puede simular y probar sin escena.

signal npc_added(npc: NpcState)
signal npc_died(npc: NpcState)
signal event_happened(record: Dictionary)
signal event_staged(entry: Dictionary)
signal rumor_told(teller: String, hearer: String, event_id: int)

const SPECIES_PATH: String = "res://data/world/species.json"
const STEP: float = 1.0
const FORGET_INTERVAL: int = 30
const CALM_PER_STEP: float = 1.5
const TRAIT_SPREAD: float = 30.0
const PLAYER_ID: String = "protagonista"

var calendar: WorldCalendar = WorldCalendar.new()
var truth: TruthLog = TruthLog.new()
var rumors: RumorEngine = RumorEngine.new()
var events: EventSystem = EventSystem.new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var species_data: Dictionary = {}
var npcs: Dictionary = {}
## Orden de creación: hace la simulación determinista.
var npc_ids: Array = []
var next_npc: int = 1
var group_beliefs: Dictionary = {}
## Cada sociedad recuerda lo que le hizo el protagonista. No hay reputación universal.
var player_standing: Dictionary = {}
## Tensión entre Mohócratas y Jubilados. Empieza tensa por la chatarra (P-10) y cambia en cada partida.
var species_relation: float = -30.0
## Segundos jugados. Con el juego cerrado no avanza.
var elapsed: float = 0.0
var last_seen_day: int = -1
var place_names: Array[String] = ["el barrio norte", "el barrio sur", "la tierra de nadie", "el bosque"]
## Puntos de la zona donde se puede estar. Los pone la zona.
var spawn_areas: Dictionary = {}
var open_spots: Array[Vector2] = []

var _accumulated: float = 0.0
var _steps: int = 0


func _init() -> void:
	species_data = JSON.parse_string(FileAccess.get_file_as_string(SPECIES_PATH))


func start(seed_value: int, data: Dictionary) -> void:
	if data.is_empty():
		_generate(seed_value)
		return
	rng.seed = int(data["seed"])
	rng.state = int(str(data["rng_state"]))
	elapsed = float(data["elapsed"])
	last_seen_day = int(data["last_seen_day"])
	next_npc = int(data["next_npc"])
	group_beliefs = data["group_beliefs"]
	player_standing = data["player_standing"]
	species_relation = float(data["species_relation"])
	truth.restore(data["truth"])
	events.restore(data["events"])
	for entry: Dictionary in data["npcs"]:
		var npc: NpcState = NpcState.from_dict(entry)
		npcs[npc.id] = npc
		npc_ids.append(npc.id)


func tick(delta: float) -> void:
	_accumulated += delta
	while _accumulated >= STEP:
		_accumulated -= STEP
		elapsed += STEP
		_step()


func alive_of(species: String) -> Array[NpcState]:
	var result: Array[NpcState] = []
	for id: String in npc_ids:
		var npc: NpcState = npcs[id]
		if npc.alive and npc.species == species:
			result.append(npc)
	return result


func random_alive(source: RandomNumberGenerator) -> NpcState:
	var pool: Array[NpcState] = []
	for id: String in npc_ids:
		if (npcs[id] as NpcState).alive:
			pool.append(npcs[id])
	return null if pool.is_empty() else pool[source.randi_range(0, pool.size() - 1)]


func place_name(at: Vector2) -> String:
	if at.y < 1150.0 and at.x > 1100.0:
		return place_names[0]
	if at.y > 1490.0 and at.x > 1100.0:
		return place_names[1]
	return place_names[2] if at.x > 1100.0 else place_names[3]


func spawn(species: String, at: Vector2, origin: String) -> NpcState:
	var info: Dictionary = species_data[species]
	var npc: NpcState = NpcState.new()
	npc.id = "npc_%06d" % next_npc
	next_npc += 1
	npc.species = species
	npc.name = _pick_name(info)
	npc.role = _needed_role(species)
	npc.group = species
	npc.origin = origin
	npc.born = elapsed
	npc.pos = at
	for key: String in NpcState.TRAITS:
		npc.personality[key] = clampf(50.0 + rng.randfn(0.0, TRAIT_SPREAD), 0.0, 100.0)
	for key: String in NpcState.EMOTIONS:
		npc.emotions[key] = 0.0
	var lore: Array = info["lore"]
	for index: int in range(2):
		var fact: int = rng.randi_range(0, lore.size() - 1)
		if not npc.lore.has(fact):
			npc.lore.append(fact)
	npcs[npc.id] = npc
	npc_ids.append(npc.id)
	npc_added.emit(npc)
	return npc


func kill(npc_id: String) -> void:
	var npc: NpcState = npcs[npc_id]
	if npc.alive:
		npc.alive = false
		npc.activity = "muerto"
		npc_died.emit(npc)


func change_standing(species: String, amount: float) -> void:
	player_standing[species] = float(player_standing.get(species, 0.0)) + amount


func change_species_relation(amount: float) -> void:
	species_relation = clampf(species_relation + amount, -100.0, 100.0)


func to_dict() -> Dictionary:
	var list: Array = []
	for id: String in npc_ids:
		list.append((npcs[id] as NpcState).to_dict())
	return {
		"seed": rng.seed, "rng_state": str(rng.state), "elapsed": elapsed,
		"last_seen_day": last_seen_day, "next_npc": next_npc, "group_beliefs": group_beliefs,
		"player_standing": player_standing, "species_relation": species_relation,
		"truth": truth.to_list(), "events": events.to_dict(), "npcs": list,
	}


func _generate(seed_value: int) -> void:
	rng.seed = hash("mundo_%d" % seed_value)
	last_seen_day = WorldCalendar.today()
	for species: String in species_data:
		var area: Rect2 = spawn_areas.get(species, Rect2(0.0, 0.0, 100.0, 100.0))
		for index: int in range(int(species_data[species]["start"])):
			var at: Vector2 = Vector2(
				rng.randf_range(area.position.x, area.end.x),
				rng.randf_range(area.position.y, area.end.y)
			)
			spawn(species, at, "inicial")


func _step() -> void:
	_steps += 1
	for id: String in npc_ids:
		(npcs[id] as NpcState).calm_down(CALM_PER_STEP)
	rumors.step(self)
	events.step(self)
	if _steps % FORGET_INTERVAL == 0:
		rumors.forget_step(self)


func _pick_name(info: Dictionary) -> String:
	var first: Array = info["names"]
	var last: Array = info["surnames"]
	return "%s %s" % [first[rng.randi_range(0, first.size() - 1)], last[rng.randi_range(0, last.size() - 1)]]


## El rol es fijo y se asigna al nacer según lo que necesite su grupo.
func _needed_role(species: String) -> String:
	var roles: Array = species_data[species]["roles"]
	var counts: Dictionary = {}
	for npc: NpcState in alive_of(species):
		counts[npc.role] = int(counts.get(npc.role, 0)) + 1
	var best: String = roles[0]
	for role: String in roles:
		if int(counts.get(role, 0)) < int(counts.get(best, 0)):
			best = role
	return best
