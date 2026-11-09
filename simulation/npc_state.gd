class_name NpcState
extends RefCounted
## Estado individual de un habitante. La lógica no depende de su representación gráfica.

const TRAITS: Array[String] = [
	"agresividad", "curiosidad", "sociabilidad", "egoismo", "generosidad",
	"cobardia", "ambicion", "honestidad", "suspicacia", "empatia", "rareza",
]
const EMOTIONS: Array[String] = [
	"miedo", "ira", "alegria", "confianza", "tristeza", "frustracion", "intriga", "ansiedad",
]
const MAX_VALUE: float = 100.0

var id: String = ""
var species: String = ""
var name: String = ""
var role: String = ""
var group: String = ""
var origin: String = "inicial"
var born: float = 0.0
var alive: bool = true
var pos: Vector2 = Vector2.ZERO
var activity: String = "trabajar"
var personality: Dictionary = {}
var emotions: Dictionary = {}
## Asimétricas: lo que este personaje siente por otro.
var relations: Dictionary = {}
var memories: Array = []
## event_id (texto) -> creencia. Nunca se confunde con la verdad objetiva.
var beliefs: Dictionary = {}
var lore: Array = []


func feel(key: String, amount: float) -> void:
	emotions[key] = clampf(float(emotions.get(key, 0.0)) + amount, 0.0, MAX_VALUE)


func emotion(key: String) -> float:
	return float(emotions.get(key, 0.0))


func trait_value(key: String) -> float:
	return float(personality.get(key, 50.0))


func calm_down(amount: float) -> void:
	for key: String in emotions:
		emotions[key] = maxf(float(emotions[key]) - amount, 0.0)


func relate(other: String, key: String, amount: float) -> void:
	var entry: Dictionary = relations.get(other, {"confianza": 50.0, "afecto": 50.0, "miedo": 0.0})
	entry[key] = clampf(float(entry.get(key, 0.0)) + amount, 0.0, MAX_VALUE)
	relations[other] = entry


func relation(other: String, key: String) -> float:
	var fallback: float = 0.0 if key == "miedo" else 50.0
	return float((relations.get(other, {}) as Dictionary).get(key, fallback))


func remember(event_id: int, importance: float, time: float, summary: String) -> void:
	memories.append({
		"event": event_id, "importance": importance, "time": time, "summary": summary,
	})


func to_dict() -> Dictionary:
	return {
		"id": id, "species": species, "name": name, "role": role, "group": group,
		"origin": origin, "born": born, "alive": alive, "x": pos.x, "y": pos.y,
		"activity": activity, "personality": personality, "emotions": emotions,
		"relations": relations, "memories": memories, "beliefs": beliefs, "lore": lore,
	}


static func from_dict(data: Dictionary) -> NpcState:
	var npc: NpcState = NpcState.new()
	npc.id = data["id"]
	npc.species = data["species"]
	npc.name = data["name"]
	npc.role = data["role"]
	npc.group = data["group"]
	npc.origin = data["origin"]
	npc.born = float(data["born"])
	npc.alive = bool(data["alive"])
	npc.pos = Vector2(float(data["x"]), float(data["y"]))
	npc.activity = data["activity"]
	npc.personality = data["personality"]
	npc.emotions = data["emotions"]
	npc.relations = data["relations"]
	npc.memories = data["memories"]
	npc.beliefs = data["beliefs"]
	npc.lore = data["lore"]
	return npc
