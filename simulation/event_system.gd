class_name EventSystem
extends RefCounted
## Provisional: se completa en el bloque 3.


func step(_sim: WorldSim) -> void:
	pass


func text_for(_type: String, belief: Dictionary) -> String:
	return "%s y %s, en %s: %s" % [belief["a"], belief["b"], belief["where"], belief["x"]]


func fragment_text(belief: Dictionary) -> String:
	return "Me ha llegado algo sobre %s." % belief["x"]


func twist_for(_sim: WorldSim, belief: Dictionary) -> String:
	return belief["x"]


func to_dict() -> Dictionary:
	return {}


func restore(_data: Dictionary) -> void:
	pass
