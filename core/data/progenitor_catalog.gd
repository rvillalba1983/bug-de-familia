class_name ProgenitorCatalog
extends RefCounted
## Progenitores presentes en el juego, según data/world/progenitors.json.

const PATH: String = "res://data/world/progenitors.json"
const FIELDS: Array[String] = ["name", "material", "fixed_property"]

static var _entries: Dictionary = {}


static func has(id: String) -> bool:
	return _all().has(id)


static func entry(id: String) -> Dictionary:
	return _all()[id]


static func _all() -> Dictionary:
	if _entries.is_empty():
		_entries = DataFile.load_dictionary(PATH)
		DataFile.require_fields(PATH, _entries, FIELDS)
	return _entries
