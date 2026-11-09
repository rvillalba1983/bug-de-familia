class_name ZoneDefinition
extends RefCounted
## Una zona del juego: geometría, reparto, objetos y convertibles (data/zones/).

var path: String = ""
var data: Dictionary = {}

var _geometry: Dictionary = {}


static func load_from(file_path: String) -> ZoneDefinition:
	var zone: ZoneDefinition = ZoneDefinition.new()
	zone.path = file_path
	zone.data = DataFile.load_dictionary(file_path)
	zone._geometry = zone.data.get("geometry", {})
	return zone


func species() -> Array[String]:
	var result: Array[String] = []
	result.assign(data["species"])
	return result


func list(section: String) -> Array:
	if not data.has(section):
		push_error("%s: falta la sección «%s»" % [path, section])
		return []
	return data[section]


func point(key: String) -> Vector2:
	return _to_point(_field(key))


func rect(key: String) -> Rect2:
	return _to_rect(_field(key))


func number(key: String) -> float:
	return float(_field(key))


func points(key: String) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for entry: Variant in _field(key):
		result.append(_to_point(entry))
	return result


func rects(key: String) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for entry: Variant in _field(key):
		result.append(_to_rect(entry))
	return result


func _field(key: String) -> Variant:
	if not _geometry.has(key):
		push_error("%s: falta geometry.%s" % [path, key])
	return _geometry.get(key)


func _to_point(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1]))


func _to_rect(value: Array) -> Rect2:
	return Rect2(float(value[0]), float(value[1]), float(value[2]), float(value[3]))
