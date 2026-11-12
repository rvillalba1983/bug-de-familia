class_name ZoneRecord
extends RefCounted
## Estado persistente de una zona entre visitas (ADR 0027, decisión 3).
##
## La zona actual guarda entidades completas; las visitadas que no son actuales
## guardan la simulación de sus individuos (nivel simplificado) o solo el
## agregado de población (nivel estadístico). Al guardar se serializa todo.

enum Level { FULL, SIMPLIFIED, STATISTICAL, UNKNOWN }

var zone_id: String = ""
var visited: bool = false
var level: int = Level.UNKNOWN
## Estado completo del nivel (LevelSaveState) de la última visita.
var level_state: Dictionary = {}
## Estado del mundo vivo de la zona (WorldSim.to_dict).
var world: Dictionary = {}
## Población agregada por especie, para el nivel estadístico.
var population: Dictionary = {}
## Cambios persistentes de la zona: puentes, inundaciones, misiones cerradas.
var changes: Dictionary = {}
var last_seen_day: int = -1


static func create(id: String) -> ZoneRecord:
	var record: ZoneRecord = ZoneRecord.new()
	record.zone_id = id
	return record


static func from_dict(data: Dictionary) -> ZoneRecord:
	var record: ZoneRecord = ZoneRecord.new()
	record.zone_id = str(data.get("zone_id", ""))
	record.visited = bool(data.get("visited", false))
	record.level = int(data.get("level", Level.UNKNOWN))
	record.level_state = data.get("level_state", {})
	record.world = data.get("world", {})
	record.population = data.get("population", {})
	record.changes = data.get("changes", {})
	record.last_seen_day = int(data.get("last_seen_day", -1))
	return record


func to_dict() -> Dictionary:
	return {
		"zone_id": zone_id,
		"visited": visited,
		"level": int(level),
		"level_state": level_state,
		"world": world,
		"population": population,
		"changes": changes,
		"last_seen_day": last_seen_day,
	}


func mark_visited(day: int) -> void:
	visited = true
	last_seen_day = day


func is_known() -> bool:
	return visited


func has_state() -> bool:
	return not level_state.is_empty() or not world.is_empty()


func alive_count(species_id: String) -> int:
	return int(population.get(species_id, 0))


## Agregado por especie a partir de una simulación completa.
static func aggregate(sim: WorldSim) -> Dictionary:
	var counts: Dictionary = {}
	for id: String in sim.npc_ids:
		var npc: NpcState = sim.npcs[id]
		if npc.alive:
			counts[npc.species] = int(counts.get(npc.species, 0)) + 1
	return counts


## El mismo agregado, desde un WorldSim.to_dict() ya serializado.
static func counts_from_world(world: Dictionary) -> Dictionary:
	var counts: Dictionary = {}
	for entry: Variant in world.get("npcs", []):
		var npc: Dictionary = entry
		if bool(npc.get("alive", true)):
			var species: String = str(npc.get("species", ""))
			counts[species] = int(counts.get(species, 0)) + 1
	return counts
