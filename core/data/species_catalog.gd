class_name SpeciesCatalog
extends RefCounted
## Aspecto y bando de cada raza, según data/world/species.json.

const PATH: String = "res://data/world/species.json"
const ACTOR_FIELDS: Array[String] = ["color", "map_color", "art", "material", "plural", "doll", "deaths"]

static var _entries: Dictionary = {}


static func has(species: String) -> bool:
	return _all().has(species)


static func rival(species: String) -> String:
	return str(_all()[species]["rival"])


static func color(species: String) -> Color:
	return Color(str(_actor(species)["color"]))


static func map_color(species: String) -> Color:
	return Color(str(_actor(species)["map_color"]))


static func art(species: String) -> String:
	return str(_actor(species)["art"])


static func material(species: String) -> String:
	return str(_actor(species)["material"])


static func plural(species: String) -> String:
	return str(_actor(species)["plural"])


## Qué muñequito dibuja la vista de estrategia.
static func doll(species: String) -> String:
	return str(_actor(species)["doll"])


static func deaths(species: String) -> Array:
	return _actor(species)["deaths"]


static func _actor(species: String) -> Dictionary:
	return _all()[species]["actor"]


static func _all() -> Dictionary:
	if _entries.is_empty():
		_entries = DataFile.load_dictionary(PATH)
		for id: String in _entries:
			var actor: Dictionary = {id: (_entries[id] as Dictionary).get("actor", {})}
			DataFile.require_fields(PATH, actor, ACTOR_FIELDS)
	return _entries
