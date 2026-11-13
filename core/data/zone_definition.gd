class_name ZoneDefinition
extends RefCounted
## Una zona del juego: geometría, reparto, objetos y convertibles (data/zones/).
##
## La geometría fija se declara en `geometry`. Las formas no rectangulares se
## tallan con `shape_blocks` (rectángulos bloqueados) y las conexiones con otras
## zonas se declaran en `corridors` (rectángulos caminables que llegan al borde).

const EDGES: Array[String] = ["north", "south", "west", "east"]
const ENTRY_INSET: float = 48.0

var path: String = ""
var id: String = ""
var display_name: String = ""
var data: Dictionary = {}

var _geometry: Dictionary = {}


static func load_from(file_path: String) -> ZoneDefinition:
	var zone: ZoneDefinition = ZoneDefinition.new()
	zone.path = file_path
	zone.data = DataFile.load_dictionary(file_path)
	zone._geometry = zone.data.get("geometry", {})
	zone.id = str(zone.data.get("id", file_path.get_file().get_basename()))
	zone.display_name = str(zone.data.get("name", zone.id))
	return zone


func species() -> Array[String]:
	return _strings("species")


## Especies asignadas por el lore que todavía no tienen catálogo jugable.
func planned_species() -> Array[String]:
	return _strings("planned_species")


## Especies que se simulan ahora: las declaradas con límites de población.
## Una zona sin población (esqueleto pendiente) no genera habitantes.
func active_species() -> Array[String]:
	var result: Array[String] = []
	var limits: Dictionary = population()
	if limits.is_empty():
		return result
	for species_id: String in species():
		if limits.has(species_id):
			result.append(species_id)
	return result


## Límites de población por especie: {especie: {start, target, max}}.
func population() -> Dictionary:
	return data.get("population", {})


func list(section: String) -> Array:
	if not data.has(section):
		push_error("%s: falta la sección «%s»" % [path, section])
		return []
	return data[section]


## Lista de una sección opcional: si no está, no es un error y devuelve vacía.
## La usan las secciones que solo algunas zonas declaran (los actores guionados).
func list_optional(section: String) -> Array:
	return data.get(section, [])


func has(key: String) -> bool:
	return _geometry.has(key)


func point(key: String) -> Vector2:
	return _to_point(_field(key))


func rect(key: String) -> Rect2:
	return _to_rect(_field(key))


func number(key: String) -> float:
	return float(_field(key))


func points(key: String) -> Array[Vector2]:
	var result: Array[Vector2] = []
	for entry: Variant in _field(key):
		result.append(_to_point(entry))
	return result


func rects(key: String) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for entry: Variant in _field(key):
		result.append(_to_rect(entry))
	return result


func floor_rect() -> Rect2:
	return rect("floor_rect")


func world_size() -> Vector2:
	return point("world_size")


func start() -> Vector2:
	if has("start"):
		return point("start")
	var floor: Rect2 = floor_rect()
	return floor.position + floor.size * 0.5


func home_area(species_id: String) -> Rect2:
	var home: Dictionary = _home(species_id)
	if home.is_empty():
		return Rect2()
	return rect(str(home["area"]))


func home_gate(species_id: String) -> Vector2:
	var home: Dictionary = _home(species_id)
	if home.is_empty():
		return Vector2.ZERO
	return point(str(home["gate"]))


## Rectángulos fuera de la forma jugable. Puede no haber ninguno.
func shape_blocks() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for entry: Variant in _geometry.get("shape_blocks", []):
		result.append(_to_rect(entry))
	return result


## Conexiones normalizadas: {to, edge, rect}.
func corridors() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Variant in _geometry.get("corridors", []):
		var corridor: Dictionary = entry
		result.append({
			"to": str(corridor.get("to", "")),
			"edge": str(corridor.get("edge", "")),
			"rect": _to_rect(corridor.get("rect", [0.0, 0.0, 0.0, 0.0])),
		})
	return result


func corridor_to(zone_id: String) -> Dictionary:
	for corridor: Dictionary in corridors():
		if str(corridor["to"]) == zone_id:
			return corridor
	return {}


## Punto de entrada al llegar desde el corredor de una zona vecina.
func entry_point(zone_id: String) -> Vector2:
	var corridor: Dictionary = corridor_to(zone_id)
	if corridor.is_empty():
		return start()
	return entry_point_of(corridor)


func entry_point_of(corridor: Dictionary) -> Vector2:
	var box: Rect2 = corridor["rect"]
	var at: Vector2 = box.get_center()
	match str(corridor["edge"]):
		"north":
			at.y = box.end.y + ENTRY_INSET
		"south":
			at.y = box.position.y - ENTRY_INSET
		"west":
			at.x = box.end.x + ENTRY_INSET
		"east":
			at.x = box.position.x - ENTRY_INSET
		_:
			push_error("%s: corredor sin borde válido hacia «%s»" % [path, corridor["to"]])
	return at.clamp(floor_rect().position, floor_rect().end)


## Borde del mapa que toca un corredor.
func edge_of(box: Rect2) -> String:
	var floor: Rect2 = floor_rect()
	if is_zero_approx(box.position.y - floor.position.y):
		return "north"
	if is_equal_approx(box.end.y, floor.end.y):
		return "south"
	if is_zero_approx(box.position.x - floor.position.x):
		return "west"
	if is_equal_approx(box.end.x, floor.end.x):
		return "east"
	push_error("%s: el corredor %s no llega a ningún borde" % [path, box])
	return ""


func _strings(section: String) -> Array[String]:
	var result: Array[String] = []
	if not data.has(section):
		return result
	result.assign(data[section])
	return result


func _home(species_id: String) -> Dictionary:
	var homes: Dictionary = data.get("homes", {})
	if not homes.has(species_id):
		push_error("%s: falta homes.%s" % [path, species_id])
		return {}
	return homes[species_id]


func _field(key: String) -> Variant:
	if not _geometry.has(key):
		push_error("%s: falta geometry.%s" % [path, key])
	return _geometry.get(key)


func _to_point(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1]))


func _to_rect(value: Array) -> Rect2:
	return Rect2(float(value[0]), float(value[1]), float(value[2]), float(value[3]))
