class_name ProgenitorDialogues
extends RefCounted
## Árboles de diálogo propios de los quince progenitores (fase post-beta).
## Cada progenitor cuenta su versión del misterio, da una pista y permite seguir
## la conversación o insultarlo. El insulto abre la vía al golpe, que puede matarlo.

const PATH: String = "res://data/conversation/progenitors.json"
const ACTIONS: Array[String] = [
	"", "gift_piece", "hit", "provoke_battle", "praise", "insult",
	"contestador_bobina",
]

static var _entries: Dictionary = {}


static func has(id: String) -> bool:
	return _all().has(id)


static func entry(id: String) -> Dictionary:
	return _all().get(id, {}) as Dictionary


static func tree_for(id: String) -> Dictionary:
	return entry(id).get("nodes", {}) as Dictionary


static func species_for(id: String) -> String:
	return str(entry(id).get("species", ""))


static func death_line(id: String) -> String:
	return str(entry(id).get("death", ""))


static func ids() -> Array:
	return _all().keys()


static func _all() -> Dictionary:
	if _entries.is_empty():
		_entries = DataFile.load_dictionary(PATH)
	return _entries
