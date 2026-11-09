class_name LiveWorld
extends Node
## Une la simulación lógica con la escena de la zona.

var level: BetaZone
var sim: WorldSim = WorldSim.new()


func start(data: Dictionary) -> void:
	sim.start(level.rng.seed, data)


func _physics_process(delta: float) -> void:
	sim.tick(delta)


func to_dict() -> Dictionary:
	return sim.to_dict()
