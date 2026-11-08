class_name AiTeam
extends RefCounted
## Quién está activa, cuántos tokens le quedan y a quién se ha perdido.

const DATA_PATH: String = "res://data/ai/personalities.json"
const ACTIVE_COUNT: int = 3
## Valores provisionales: ver docs/adr/0004-ias-e-investigacion.md.
const MAX_TOKENS: float = 100.0
const COST_PER_EFFORT: float = 1.5
const DISCARD_RECHARGE: float = 4.0
const OFFENDED_MUTE_TIME: float = 20.0

var ais: Dictionary = {}
var pairs: Array = []
var active: Array = []
var tokens: Dictionary = {}
var lost: Array = []
var offenses: Dictionary = {}
var muted: Dictionary = {}


func _init() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not data is Dictionary:
		push_error("Datos ilegibles en %s" % DATA_PATH)
		return
	ais = data["ais"]
	pairs = data["pairs"]


func start(rng: RandomNumberGenerator) -> void:
	active.clear()
	lost.clear()
	offenses.clear()
	muted.clear()
	for id: String in ais:
		tokens[id] = MAX_TOKENS
	while active.size() < ACTIVE_COUNT and active.size() < ais.size():
		_activate_random(rng)


func has_active(id: String) -> bool:
	return active.has(id)


func can_speak(id: String) -> bool:
	return active.has(id) and float(muted.get(id, 0.0)) <= 0.0


func speakers() -> Array:
	return active.filter(can_speak)


## Gasta tokens al hablar. Sin tokens se duerme y entra otra.
func spend(id: String, rng: RandomNumberGenerator) -> void:
	tokens[id] = maxf(float(tokens[id]) - COST_PER_EFFORT * float(ais[id]["effort"]), 0.0)
	if float(tokens[id]) <= 0.0:
		active.erase(id)
		_activate_random(rng)


func tick(delta: float) -> void:
	for id: String in muted.keys():
		muted[id] = maxf(float(muted[id]) - delta, 0.0)


## Da un poco de tokens a la IA dormida con menos. Lo que exceda se pierde.
func recharge_sleeping() -> String:
	var best: String = ""
	for id: String in ais:
		if not active.has(id) and not lost.has(id):
			if best.is_empty() or float(tokens[id]) < float(tokens[best]):
				best = id
	if not best.is_empty():
		tokens[best] = minf(float(tokens[best]) + DISCARD_RECHARGE, MAX_TOKENS)
	return best


## Suma un enfado grave. Devuelve true si la IA se pierde para siempre.
func offend(id: String, rng: RandomNumberGenerator) -> bool:
	offenses[id] = int(offenses.get(id, 0)) + 1
	muted[id] = OFFENDED_MUTE_TIME
	if int(offenses[id]) < int(ais[id]["tolerance"]):
		return false
	lose(id, rng)
	return true


## Pérdida definitiva, también por una pelea física con ella.
func lose(id: String, rng: RandomNumberGenerator) -> void:
	if not lost.has(id):
		lost.append(id)
	active.erase(id)
	_activate_random(rng)


func to_dict() -> Dictionary:
	return {"active": active, "tokens": tokens, "lost": lost, "offenses": offenses}


func restore(data: Dictionary, rng: RandomNumberGenerator) -> void:
	if data.is_empty() or not data.get("tokens") is Dictionary:
		start(rng)
		return
	active = (data["active"] as Array).duplicate()
	tokens = (data["tokens"] as Dictionary).duplicate()
	lost = (data["lost"] as Array).duplicate()
	offenses = (data["offenses"] as Dictionary).duplicate()
	muted.clear()


func _activate_random(rng: RandomNumberGenerator) -> void:
	var options: Array = []
	for id: String in ais:
		if not active.has(id) and not lost.has(id) and float(tokens[id]) > 0.0:
			options.append(id)
	if not options.is_empty():
		active.append(options[rng.randi_range(0, options.size() - 1)])
