class_name PieceAtlas
extends RefCounted
## Hoja única con las piezas de todos los personajes: al compartir textura se dibujan juntas.
## La genera tools/art/piece_atlas_gen.gd a partir de art/beta/rig/.

const IMAGE_PATH: String = "res://art/beta/atlas/piezas.png"
const INDEX_PATH: String = "res://data/art/atlas_piezas.json"
const SHADOW: String = "sombra"

static var _texture: Texture2D
static var _entries: Dictionary = {}


static func has_entry(key: String) -> bool:
	_ensure_loaded()
	return _entries.has(key)


static func texture() -> Texture2D:
	_ensure_loaded()
	return _texture


static func region(key: String) -> Rect2:
	var entry: Array = _entries[key]
	return Rect2(float(entry[0]), float(entry[1]), float(entry[2]), float(entry[3]))


## Esquina recortada dentro de la imagen original, en píxeles de la hoja.
static func trim_offset(key: String) -> Vector2:
	var entry: Array = _entries[key]
	return Vector2(float(entry[4]), float(entry[5]))


## Ancho de la imagen original antes de recortarla, en píxeles de la hoja.
static func full_width(key: String) -> float:
	return float((_entries[key] as Array)[6])


static func _ensure_loaded() -> void:
	if _texture != null:
		return
	_texture = load(IMAGE_PATH) as Texture2D
	_entries = DataFile.load_dictionary(INDEX_PATH)
