class_name DataFile
extends RefCounted
## Lectura validada de archivos de contenido: los errores señalan archivo y campo.


static func load_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("%s: no existe" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		push_error("%s: no es un objeto JSON válido" % path)
		return {}
	return parsed


## Comprueba que cada entrada tiene los campos obligatorios.
static func require_fields(path: String, entries: Dictionary, fields: Array[String]) -> void:
	for id: String in entries:
		for field: String in fields:
			if not (entries[id] as Dictionary).has(field):
				push_error("%s: a «%s» le falta el campo «%s»" % [path, id, field])
