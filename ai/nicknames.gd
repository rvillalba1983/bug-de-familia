class_name Nicknames
extends RefCounted
## Motes con los que cada IA y cada progenitor llaman al protagonista.

const DATA_PATH: String = "res://data/ai/nicknames.json"
const TOKEN: String = "{mote}"
const FALLBACK: String = "Sobrante"

var by_owner: Dictionary = {}


func _init() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not data is Dictionary:
		push_error("Datos ilegibles en %s" % DATA_PATH)
		return
	by_owner.merge(data["ais"])
	by_owner.merge(data["progenitors"])


func pick(owner_id: String, rng: RandomNumberGenerator) -> String:
	var options: Array = by_owner.get(owner_id, [])
	if options.is_empty():
		return FALLBACK
	return options[rng.randi_range(0, options.size() - 1)]


## Sustituye la marca del mote; el texto sin marca no cambia.
func resolve(text: String, owner_id: String, rng: RandomNumberGenerator) -> String:
	if not text.contains(TOKEN):
		return text
	return text.replace(TOKEN, pick(owner_id, rng))
