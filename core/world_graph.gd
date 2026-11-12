class_name WorldGraph
extends RefCounted
## Grafo de zonas: qué zonas están conectadas y a cuántos saltos.
##
## El nivel de simulación se decide por saltos (ADR 0027): la zona actual se
## simula completa, sus vecinas de forma simplificada y el resto, estadística.

var _zones: Dictionary = {}


func _init(zones: Array[ZoneDefinition] = []) -> void:
	for zone: ZoneDefinition in zones:
		add(zone)


func add(zone: ZoneDefinition) -> void:
	_zones[zone.id] = zone


func has(zone_id: String) -> bool:
	return _zones.has(zone_id)


func zone(zone_id: String) -> ZoneDefinition:
	return _zones.get(zone_id) as ZoneDefinition


func ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(_zones.keys())
	result.sort()
	return result


func size() -> int:
	return _zones.size()


## Zonas directamente conectadas, en orden alfabético.
func neighbours(zone_id: String) -> Array[String]:
	var result: Array[String] = []
	var zone: ZoneDefinition = zone(zone_id)
	if zone == null:
		return result
	for corridor: Dictionary in zone.corridors():
		var target: String = str(corridor["to"])
		if target != zone_id and not result.has(target):
			result.append(target)
	result.sort()
	return result


## Saltos mínimos entre dos zonas. Devuelve -1 si no hay camino.
func hops(from_id: String, to_id: String) -> int:
	var distances: Dictionary = distances_from(from_id)
	return int(distances.get(to_id, -1))


func distances_from(from_id: String) -> Dictionary:
	var result: Dictionary = {}
	if not has(from_id):
		return result
	var queue: Array[String] = [from_id]
	result[from_id] = 0
	while not queue.is_empty():
		var current: String = queue.pop_front()
		var next_distance: int = int(result[current]) + 1
		for target: String in neighbours(current):
			if result.has(target):
				continue
			result[target] = next_distance
			queue.append(target)
	return result


## Conexiones declaradas que la otra zona no devuelve. Debe estar vacío.
func missing_reciprocal() -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in ids():
		for target: String in neighbours(zone_id):
			if not has(target):
				result.append("%s->%s" % [zone_id, target])
			elif not neighbours(target).has(zone_id):
				result.append("%s->%s" % [zone_id, target])
	return result


## Zonas que no se alcanzan desde el nodo indicado.
func unreachable_from(from_id: String) -> Array[String]:
	var reached: Dictionary = distances_from(from_id)
	var result: Array[String] = []
	for zone_id: String in ids():
		if not reached.has(zone_id):
			result.append(zone_id)
	return result
