class_name BodyPiece
extends RefCounted
## Una pieza del cuerpo con su resistencia.

enum Kind { HEAD, ARM, LEG }

const MAX_DURABILITY: float = 100.0

var kind: Kind
var durability: float = MAX_DURABILITY


func _init(new_kind: Kind, new_durability: float = MAX_DURABILITY) -> void:
	kind = new_kind
	durability = new_durability


func to_dict() -> Dictionary:
	return {"kind": int(kind), "durability": durability}


## Devuelve null si los datos no son válidos.
static func from_dict(data: Variant) -> BodyPiece:
	if not data is Dictionary:
		return null
	var values: Dictionary = data
	if not (values.has("kind") and values.has("durability")):
		return null
	var kind_value: int = int(values["kind"])
	if kind_value < 0 or kind_value >= Kind.size():
		return null
	return BodyPiece.new(kind_value as Kind, float(values["durability"]))
