class_name PropArt
extends RefCounted
## Qué dibujo lleva cada objeto de la zona: [archivo, ancho, alto y, opcional, copias].

const FOLDER: String = "res://art/beta/props/"
const BY_ID: Dictionary = {
	"paca": ["res://art/beta/jubilado_hierro.svg", 96.0, 96.0],
	"eusebio": ["res://art/beta/jubilado_hierro.svg", 96.0, 96.0],
	"seta": ["res://art/beta/mohocrata.svg", 96.0, 96.0],
	"anselmo": ["res://art/beta/mohocrata.svg", 96.0, 96.0],
	"cuadrilla_moho": ["res://art/beta/mohocrata.svg", 96.0, 96.0, 3],
	"patrulla_jub": ["res://art/beta/jubilado_hierro.svg", 96.0, 96.0, 3],
	"panel": ["panel", 72.0, 96.0],
	"contestador": ["contestador", 96.0, 112.0],
	"mina_suelta": ["res://art/beta/mina_petanca.svg", 44.0, 44.0],
	"muro_agrietado": ["grieta", 70.0, 70.0],
	"generador": ["generador", 96.0, 96.0],
	"e_sombrero": ["sombrero", 60.0, 46.0],
	"e_acta": ["acta", 48.0, 55.0],
	"e_aceite": ["aceite", 100.0, 42.0],
	"e_manolo": ["robot_apagado", 105.0, 90.0],
	"e_placa": ["placa", 48.0, 48.0],
	"e_etiqueta": ["etiqueta", 48.0, 48.0],
	"e_soldadura_1": ["soldadura", 65.0, 55.0],
	"e_soldadura_2": ["soldadura", 65.0, 55.0],
}
const BY_KIND: Dictionary = {
	Interactable.Kind.CRATE: ["caja", 65.0, 60.0],
	Interactable.Kind.TERMINAL: ["terminal", 56.0, 84.0],
	Interactable.Kind.PICKUP_LEG: ["pierna", 60.0, 60.0],
	Interactable.Kind.PICKUP_ARM: ["brazo", 60.0, 60.0],
	Interactable.Kind.EVIDENCE: ["objeto_perdido", 60.0, 56.0],
	Interactable.Kind.NPC: ["objeto_perdido", 60.0, 56.0],
}
const COPY_OFFSET: Vector2 = Vector2(46.0, 16.0)

static var _cache: Dictionary = {}


static func texture(name_or_path: String) -> Texture2D:
	var path: String = name_or_path
	if not path.begins_with("res://"):
		path = "%s%s.svg" % [FOLDER, name_or_path]
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


static func entry_for(item_id: String, kind: Interactable.Kind) -> Array:
	if item_id.begins_with("rastro_"):
		return ["restos_fiesta", 90.0, 60.0]
	return BY_ID.get(item_id, BY_KIND[kind])


## Dibuja el objeto con los pies en el origen del nodo.
static func draw_entry(node: CanvasItem, entry: Array) -> void:
	var size: Vector2 = Vector2(float(entry[1]), float(entry[2]))
	var copies: int = int(entry[3]) if entry.size() > 3 else 1
	for index: int in range(copies):
		var shift: Vector2 = COPY_OFFSET * Vector2(float(index) - float(copies - 1) * 0.5, float(index % 2))
		node.draw_texture_rect(texture(entry[0]), Rect2(shift - Vector2(size.x * 0.5, size.y), size), false)
