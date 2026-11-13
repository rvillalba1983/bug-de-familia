class_name SaveSystem
extends RefCounted
## Único espacio de partida, con escritura atómica. Una muerte no se puede revertir.

enum Status { NONE, OK, CORRUPT }

const SCHEMA_VERSION: int = 3
const DEFAULT_PATH: String = "user://partida.json"
## Identificadores de zona de las partidas anteriores al renombrado beta -> despliegue_cero.
const LEGACY_ZONE_IDS: Dictionary = {"beta": "despliegue_cero"}

static var path: String = DEFAULT_PATH


static func write(data: Dictionary) -> bool:
	var payload: Dictionary = data.duplicate()
	payload["version"] = SCHEMA_VERSION
	var temp_path: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo escribir %s" % temp_path)
		return false
	file.store_string(JSON.stringify(payload))
	file.close()
	if DirAccess.rename_absolute(temp_path, path) == OK:
		return true
	DirAccess.remove_absolute(path)
	return DirAccess.rename_absolute(temp_path, path) == OK


## Devuelve { status, data }.
static func read() -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": Status.NONE, "data": {}}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	parsed = _migrated(parsed)
	if not is_valid(parsed):
		return {"status": Status.CORRUPT, "data": {}}
	return {"status": Status.OK, "data": parsed}


static func is_valid(parsed: Variant) -> bool:
	if not parsed is Dictionary:
		return false
	var values: Dictionary = parsed
	if int(values.get("version", -1)) != SCHEMA_VERSION:
		return false
	return values.get("dead") is bool and values.has("body")


## Las partidas anteriores a la fase 8 no tienen mundo vivo: se genera al cargarlas.
## Las de la versión 2 son de una sola zona: el gestor las trata como el despliegue cero.
static func _migrated(parsed: Variant) -> Variant:
	if not parsed is Dictionary:
		return parsed
	var values: Dictionary = parsed
	var version: int = int(values.get("version", -1))
	if version == 1:
		values["world"] = {}
	if version == 1 or version == 2:
		values["version"] = SCHEMA_VERSION
	return values


## Traduce un identificador de zona de una partida anterior al renombrado.
static func migrate_zone_id(zone_id: String) -> String:
	return str(LEGACY_ZONE_IDS.get(zone_id, zone_id))


## La muerte se graba de inmediato y sin vuelta atrás.
static func mark_dead() -> void:
	var loaded: Dictionary = read()
	var data: Dictionary = loaded["data"] if loaded["status"] == Status.OK else {"body": {}}
	data["dead"] = true
	write(data)


## Conserva un archivo dañado aparte y deja libre el único espacio.
static func set_aside_corrupt() -> void:
	DirAccess.rename_absolute(path, path + ".danada")


static func delete_all() -> void:
	for suffix: String in ["", ".tmp", ".danada"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)
