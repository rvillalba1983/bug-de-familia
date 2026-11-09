class_name MissionSystem
extends RefCounted
## Misiones emergentes: nacen de sucesos, sin lista ni marcadores (P-11).

const PATH: String = "res://data/world/missions.json"
const MAX_ACTIVE: int = 2
const REACH_RANGE: float = 140.0
const ITEM_OFFSET: Vector2 = Vector2(90.0, 40.0)

var templates: Dictionary = {}
var missions: Array = []
var next_id: int = 1


func _init() -> void:
	templates = JSON.parse_string(FileAccess.get_file_as_string(PATH))


func open_missions() -> Array:
	return missions.filter(func(m: Dictionary) -> bool: return m["state"] == "abierta")


func on_event(sim: WorldSim, record: Dictionary) -> void:
	var spec: Dictionary = sim.events.catalog[record["type"]]
	if not spec.has("mission") or open_missions().size() >= MAX_ACTIVE:
		return
	var actors: Array = record["actors"]
	if not _is_alive(sim, actors[0]) or str(record["victim"]) == actors[0]:
		return
	var template: String = spec["mission"]
	var mission: Dictionary = {
		"id": next_id, "template": template, "event": int(record["id"]), "teller": actors[0],
		"target": actors[1] if actors.size() > 1 else "", "stage": "sin_contar", "state": "abierta",
		"deadline": sim.elapsed + float(templates[template]["deadline"]), "result": "",
		"x": float(record["px"]) + ITEM_OFFSET.x, "y": float(record["py"]) + ITEM_OFFSET.y,
		"a": record["a"], "b": record["b"], "thing": record["x"], "where": record["where"],
	}
	if template == "recado" and not _is_alive(sim, mission["target"]):
		return
	next_id += 1
	missions.append(mission)
	sim.mission_changed.emit(mission)


func step(sim: WorldSim) -> void:
	for mission: Dictionary in open_missions():
		if not _is_alive(sim, mission["teller"]):
			_finish(sim, mission, "sin_nadie")
		elif sim.elapsed >= float(mission["deadline"]):
			_finish(sim, mission, "ignorada")
			var teller: NpcState = sim.npcs[mission["teller"]]
			sim.events.report(sim, "oportunidad_perdida", teller.id, "", teller.pos)


func hint(mission: Dictionary) -> String:
	return templates[mission["template"]]["hint"]


## Opciones de conversación según el estado de cada misión. Cada una es [texto, id, acción].
func options_for(npc: NpcState) -> Array:
	var result: Array = []
	for mission: Dictionary in open_missions():
		var info: Dictionary = templates[mission["template"]]
		if mission["teller"] == npc.id and mission["stage"] == "sin_contar":
			result.append([info["ask"], int(mission["id"]), "contar"])
		elif mission["teller"] == npc.id and mission["stage"] == "recogido":
			result.append([info["deliver"], int(mission["id"]), "entregar"])
		elif mission["target"] == npc.id and mission["stage"] == "contada":
			if mission["template"] == "recado":
				result.append([_fill(info["peace"], mission), int(mission["id"]), "paz"])
				result.append([_fill(info["war"], mission), int(mission["id"]), "bronca"])
	return result


## Devuelve lo que responde el personaje.
func perform(sim: WorldSim, id: int, action: String) -> String:
	var mission: Dictionary = _by_id(id)
	var info: Dictionary = templates[mission["template"]]
	match action:
		"contar":
			mission["stage"] = "contada"
			return _fill(info["told"], mission)
		"entregar":
			_finish(sim, mission, "devuelto")
			sim.change_standing((sim.npcs[mission["teller"]] as NpcState).species, 3.0)
			return _fill(info["done"], mission)
		"paz":
			_relate(sim, mission, 12.0)
			_finish(sim, mission, "paz")
			return _fill(info["peace_done"], mission)
		"bronca":
			_relate(sim, mission, -20.0)
			_finish(sim, mission, "bronca")
			return _fill(info["war_done"], mission)
	return ""


func item_taken(sim: WorldSim, id: int) -> void:
	var mission: Dictionary = _by_id(id)
	if mission["state"] == "abierta" and mission["template"] == "pertenencia":
		mission["stage"] = "recogido"
		sim.mission_changed.emit(mission)


## Llegar al sitio cierra los avisos ya contados.
func player_at(sim: WorldSim, at: Vector2) -> Dictionary:
	for mission: Dictionary in open_missions():
		var place: Vector2 = Vector2(float(mission["x"]), float(mission["y"]))
		var told: bool = mission["stage"] == "contada"
		if mission["template"] == "aviso" and told and at.distance_to(place) <= REACH_RANGE:
			_finish(sim, mission, "comprobado")
			sim.change_standing((sim.npcs[mission["teller"]] as NpcState).species, 2.0)
			return mission
	return {}


func done_text(mission: Dictionary) -> String:
	return _fill(templates[mission["template"]]["done"], mission)


func to_dict() -> Dictionary:
	return {"missions": missions, "next_id": next_id}


func restore(data: Dictionary) -> void:
	missions = data["missions"]
	next_id = int(data["next_id"])


func _fill(text: String, mission: Dictionary) -> String:
	return text.format({
		"a": mission["a"], "b": mission["b"], "x": mission["thing"], "w": mission["where"],
	})


func _by_id(id: int) -> Dictionary:
	for mission: Dictionary in missions:
		if int(mission["id"]) == id:
			return mission
	return {}


func _is_alive(sim: WorldSim, id: String) -> bool:
	return sim.npcs.has(id) and (sim.npcs[id] as NpcState).alive


func _finish(sim: WorldSim, mission: Dictionary, result: String) -> void:
	mission["state"] = "cerrada"
	mission["result"] = result
	sim.mission_changed.emit(mission)


func _relate(sim: WorldSim, mission: Dictionary, amount: float) -> void:
	var teller: NpcState = sim.npcs[mission["teller"]]
	var target: NpcState = sim.npcs[mission["target"]]
	target.relate(teller.id, "afecto", amount)
	teller.relate(target.id, "afecto", amount)
	if teller.species != target.species:
		sim.change_species_relation(amount * 0.5)
