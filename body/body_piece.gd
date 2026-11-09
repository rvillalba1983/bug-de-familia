class_name BodyPiece
extends RefCounted
## Una pieza del cuerpo con su resistencia.

enum Kind { HEAD, ARM, LEG }

const MAX_DURABILITY: float = 100.0
## Aspectos disponibles en la hoja de diseño para cada tipo de pieza.
const VISUAL_VARIANTS: Dictionary = {Kind.HEAD: 10, Kind.ARM: 20, Kind.LEG: 10}

var kind: Kind
var durability: float = MAX_DURABILITY
## Nombre visible; los valores numéricos nunca se muestran.
var label: String = ""
## Qué hace la pieza, en lenguaje claro.
var description: String = ""
## Efectos ya resueltos por la conversión, ocultos para el jugador.
var effects: Dictionary = {}
## Lista de { id, name, active }.
var actions: Array = []
## La lluvia ácida solo ataca a las piezas metálicas.
var metallic: bool = true
## Qué aspecto tiene al llevarla puesta. El 0 es el de la hoja de diseño.
var visual_variant: int = 0


func _init(new_kind: Kind, new_durability: float = MAX_DURABILITY) -> void:
	kind = new_kind
	durability = new_durability


func to_dict() -> Dictionary:
	return {
		"kind": int(kind),
		"durability": durability,
		"label": label,
		"description": description,
		"effects": effects,
		"actions": actions,
		"metallic": metallic,
		"visual_variant": visual_variant,
	}


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
	var piece: BodyPiece = BodyPiece.new(kind_value as Kind, float(values["durability"]))
	piece.label = str(values.get("label", ""))
	piece.description = str(values.get("description", ""))
	piece.metallic = bool(values.get("metallic", true))
	piece.visual_variant = int(values.get("visual_variant", 0))
	if values.get("effects") is Dictionary:
		piece.effects = values["effects"]
	if values.get("actions") is Array:
		piece.actions = values["actions"]
	return piece


## Elige un aspecto distinto del original a partir de un texto, sin gastar azar de la partida.
func pick_visual_variant(source: String) -> void:
	var count: int = VISUAL_VARIANTS[kind]
	visual_variant = 1 + posmod(hash(source), count - 1)


func has_action(action_id: String) -> bool:
	for action: Dictionary in actions:
		if action["id"] == action_id:
			return true
	return false
