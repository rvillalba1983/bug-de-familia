class_name TruthLog
extends RefCounted
## Lo que ocurrió de verdad. Solo se añade: ninguna conversación puede cambiarlo.

var records: Array = []


func add(fields: Dictionary) -> Dictionary:
	var record: Dictionary = fields.duplicate(true)
	record["id"] = records.size()
	records.append(record)
	return record


func get_record(id: int) -> Dictionary:
	return records[id] if id >= 0 and id < records.size() else {}


## Huella de lo registrado, para comprobar que la historia no se ha tocado.
func digest() -> int:
	var parts: PackedStringArray = PackedStringArray()
	for record: Dictionary in records:
		parts.append("%d|%s|%s|%d" % [
			int(record["id"]), record["type"], str(record["actors"]), int(record["cause"])
		])
	return "\n".join(parts).hash()


func to_list() -> Array:
	return records


func restore(data: Array) -> void:
	records = data
