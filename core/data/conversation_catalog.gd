class_name ConversationCatalog
extends RefCounted
## Catálogo de conversaciones por raza (P-42). Cada NPC recibe una conversación
## determinista según su id, para que no repita la misma con dos habitantes.

static var _cache: Dictionary = {}


static func conversations_for(species: String) -> Array:
	if _cache.has(species):
		return _cache[species]
	var path: String = "res://data/conversation/live_%s.json" % species
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary:
		_cache[species] = []
		return []
	var list: Array = (data as Dictionary).get("conversations", [])
	_cache[species] = list
	return list


static func pick(species: String, key: String) -> Dictionary:
	var list: Array = conversations_for(species)
	if list.is_empty():
		return {}
	var index: int = absi(hash(key)) % list.size()
	return list[index] as Dictionary
