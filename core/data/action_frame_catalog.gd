class_name ActionFrameCatalog
extends RefCounted
## Catálogo de fotogramas por acción (P-25 y P-51). Valores provisionales.
## Las claves apuntan a entradas del atlas generadas por tools/art/piece_atlas_gen.gd.
## Las acciones con `rig_only` no tienen fotograma: el gesto se hace con el rig.

const PATH: String = "res://data/art/action_frames.json"
const DEFAULT: String = "idle"
## Duración por defecto de una acción sin campo `duration`: sostenida.
const SUSTAINED: float = -1.0

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


## Prioridad del gesto: gana el número mayor (tabla de P-51, §1.4).
static func priority(id: String) -> int:
	_ensure_loaded()
	if not _data.has(id):
		return 0
	return int(_data[id].get("priority", 0))


## Segundos que dura el clip; `SUSTAINED` si no termina solo (agacharse, idle).
static func duration(id: String) -> float:
	_ensure_loaded()
	if not _data.has(id):
		return SUSTAINED
	return float(_data[id].get("duration", SUSTAINED))


## Los clips que frenan al jugador mientras duran (P-51: lanzar).
static func holds_movement(id: String) -> bool:
	_ensure_loaded()
	if not _data.has(id):
		return false
	return bool(_data[id].get("holds_movement", false))


## Estado terminal (morir): no vuelve a idle ni lo interrumpe nada.
static func is_terminal(id: String) -> bool:
	_ensure_loaded()
	if not _data.has(id):
		return false
	return bool(_data[id].get("terminal", false))


## Gesto sin fotograma de atlas: se dibuja solo con transformaciones del rig.
static func is_rig_only(id: String) -> bool:
	_ensure_loaded()
	if not _data.has(id):
		return false
	return bool(_data[id].get("rig_only", false))


## Cadena de búsqueda de P-51 §3.3: `base_<arma>`, `base_<tipo>` y `base`.
## Es pura para poder probarla con catálogos inventados.
static func pick_action(
	base: String, weapon_id: String, gesture: String, available: Array[String]
) -> String:
	if not weapon_id.is_empty() and available.has("%s_%s" % [base, weapon_id]):
		return "%s_%s" % [base, weapon_id]
	if not gesture.is_empty() and available.has("%s_%s" % [base, gesture]):
		return "%s_%s" % [base, gesture]
	if available.has(base):
		return base
	return DEFAULT if available.has(DEFAULT) else ""


## La misma cadena, contra el catálogo real. `weapon_id` y `gesture` pueden ir vacíos.
static func resolve(base: String, weapon_id: String = "", gesture: String = "") -> String:
	var found: String = pick_action(base, weapon_id, gesture, actions())
	return DEFAULT if found.is_empty() else found


static func _ensure_loaded() -> void:
	if not _data.is_empty():
		return
	_data = DataFile.load_dictionary(PATH).get("acciones", {})
	if _data.is_empty():
		push_error("Sin acciones de fotogramas en %s" % PATH)
