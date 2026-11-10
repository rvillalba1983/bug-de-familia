class_name ActionFrameCatalog
extends RefCounted
## Catálogo de fotogramas por acción (P-25). Valores provisionales.
## Las claves apuntan a entradas del atlas generadas por tools/art/piece_atlas_gen.gd.

const PATH: String = "res://data/art/action_frames.json"
const DEFAULT: String = "idle"

static var _data: Dictionary = {}


static func has_action(id: String) -> bool:
	_ensure_loaded()
	return _data.has(id)


static func actions() -> Array[String]:
	_ensure_loaded()
	var out: Array[String] = []
	for id: String in _data:
		out.append(id)
	return out


static func frames(id: String) -> Array[String]:
	_ensure_loaded()
	var out: Array[String] = []
	for clave: String in (_data[id]["frames"] as Array):
		out.append(clave)
	return out


static func fps(id: String) -> float:
	_ensure_loaded()
	return float(_data[id]["fps"])


static func _ensure_loaded() -> void:
	if not _data.is_empty():
		return
	_data = DataFile.load_dictionary(PATH).get("acciones", {})
	if _data.is_empty():
		push_error("Sin acciones de fotogramas en %s" % PATH)
