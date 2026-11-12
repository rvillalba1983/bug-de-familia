class_name PopulationSystem
extends RefCounted
## Nacimientos y llegadas, también con el jugador delante. Los muertos no vuelven.

## Provisionales.
const INTERVAL: int = 20
const BIRTH_CHANCE: float = 0.12
const ARRIVAL_CHANCE: float = 0.25
const BIRTH_OFFSET: float = 50.0


func step(sim: WorldSim) -> void:
	for species: String in sim.species_ids():
		var alive: Array[NpcState] = sim.alive_of(species)
		if alive.size() >= sim.limit_of(species, "max"):
			continue
		var below: bool = alive.size() < sim.limit_of(species, "target")
		if alive.size() >= 2 and sim.rng.randf() < BIRTH_CHANCE * (1.0 if below else 0.3):
			_birth(sim, species, alive)
		elif below and sim.rng.randf() < ARRIVAL_CHANCE:
			var npc: NpcState = sim.spawn(species, sim.gates.get(species, Vector2.ZERO), "llegado")
			sim.events.report(sim, "llegada", npc.id, "", npc.pos)


func _birth(sim: WorldSim, species: String, alive: Array[NpcState]) -> void:
	var parent: NpcState = alive[sim.rng.randi_range(0, alive.size() - 1)]
	var area: Rect2 = sim.spawn_areas.get(species, Rect2())
	var at: Vector2 = parent.pos + Vector2(BIRTH_OFFSET, 0.0)
	if area.has_area():
		at = at.clamp(area.position, area.end)
	var npc: NpcState = sim.spawn(species, at, "nacido")
	sim.events.report(sim, "nacimiento", npc.id, "", npc.pos)
