class_name DeathCatalog
extends RefCounted
## Formas de caer de los personajes, según data/combat/deaths.json.

const PATH: String = "res://data/combat/deaths.json"
const DEFAULT_ID: String = "caida"
const FIELDS: Array[String] = ["animation", "shake", "stop", "land_delay", "land_shake", "land_squash", "corpse_time"]

static var _entries: Dictionary = {}


static func entry(id: String) -> Dictionary:
	return _all()[id]


## Con una sola opción no gasta números de la semilla de la partida.
static func pick(ids: Array, rng: RandomNumberGenerator) -> Dictionary:
	if ids.size() == 1:
		return entry(str(ids[0]))
	return entry(str(ids[rng.randi_range(0, ids.size() - 1)]))


static func _all() -> Dictionary:
	if _entries.is_empty():
		_entries = DataFile.load_dictionary(PATH)
		DataFile.require_fields(PATH, _entries, FIELDS)
	return _entries
