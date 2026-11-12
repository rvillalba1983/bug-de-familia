class_name ZoneRegistry
extends RefCounted
## Catálogo de zonas conocidas y su grafo de conexiones (data/world/zones.json).
##
## El índice decide qué zonas existen en la partida. Cada zona vive en
## data/zones/<id>.json y su identificador debe coincidir con el del índice.

const INDEX_PATH: String = "res://data/world/zones.json"
const ZONES_FOLDER: String = "res://data/zones/"

var index_path: String = INDEX_PATH
var zones: Dictionary = {}
var graph: WorldGraph = WorldGraph.new()


static func load_default() -> ZoneRegistry:
	return load_from(INDEX_PATH)


static func load_from(path: String) -> ZoneRegistry:
	var registry: ZoneRegistry = ZoneRegistry.new()
	registry.index_path = path
	registry._load()
	return registry


func ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(zones.keys())
	result.sort()
	return result


func has(zone_id: String) -> bool:
	return zones.has(zone_id)


func zone(zone_id: String) -> ZoneDefinition:
	return zones.get(zone_id) as ZoneDefinition


func count() -> int:
	return zones.size()


func _load() -> void:
	var index: Dictionary = DataFile.load_dictionary(index_path)
	var listed: Array = index.get("zones", [])
	if listed.is_empty():
		push_error("%s: no declara ninguna zona en «zones»" % index_path)
		return
	for entry: Variant in listed:
		var zone_id: String = str(entry)
		var file_path: String = ZONES_FOLDER + zone_id + ".json"
		if not ResourceLoader.exists(file_path) and not FileAccess.file_exists(file_path):
			push_error("%s: la zona «%s» no tiene %s" % [index_path, zone_id, file_path])
			continue
		var zone: ZoneDefinition = ZoneDefinition.load_from(file_path)
		if zone.id != zone_id:
			push_error("%s: la zona «%s» declara el id «%s»" % [file_path, zone_id, zone.id])
			continue
		zones[zone_id] = zone
		graph.add(zone)
