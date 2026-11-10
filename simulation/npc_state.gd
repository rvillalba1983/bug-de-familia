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

const CHILD_DURATION: float = 300.0
const ADULT_SCALE_MIN: float = 0.55
const ADULT_SCALE_MAX: float = 0.8
const CHILD_SCALE_MIN: float = 0.3
const CHILD_SCALE_MAX: float = 0.5
const ADULT_CHANCE: float = 0.8

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
## Escala visual del habitante (30 %-80 %). Solo visual.
var visual_scale: float = 0.7
var adult_scale: float = 0.7
var child_grows_at: float = -1.0
## Duelo junto a los muertos: permanece en el lugar hasta este instante simulado.
var mourn_until: float = 0.0
var mourn_at: Vector2 = Vector2.ZERO


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


func is_child(now: float) -> bool:
	return child_grows_at > 0.0 and now < child_grows_at


func current_visual_scale(now: float) -> float:
	return visual_scale if is_child(now) else adult_scale


func to_dict() -> Dictionary:
	return {
		"id": id, "species": species, "name": name, "role": role, "group": group,
		"origin": origin, "born": born, "alive": alive, "x": pos.x, "y": pos.y,
		"activity": activity, "personality": personality, "emotions": emotions,
		"relations": relations, "memories": memories, "beliefs": beliefs, "lore": lore,
		"visual_scale": visual_scale, "adult_scale": adult_scale, "child_grows_at": child_grows_at,
		"mourn_until": mourn_until, "mourn_x": mourn_at.x, "mourn_y": mourn_at.y,
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
	npc.adult_scale = float(data.get("adult_scale", 0.7))
	npc.visual_scale = float(data.get("visual_scale", npc.adult_scale))
	npc.child_grows_at = float(data.get("child_grows_at", -1.0))
	npc.mourn_until = float(data.get("mourn_until", 0.0))
	npc.mourn_at = Vector2(float(data.get("mourn_x", 0.0)), float(data.get("mourn_y", 0.0)))
	return npc
