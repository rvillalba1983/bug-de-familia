class_name WorldSim
extends RefCounted
## Estado lógico del mundo vivo. No conoce nodos: se puede simular y probar sin escena.

var calendar: WorldCalendar = WorldCalendar.new()
## Segundos jugados. Con el juego cerrado no avanza.
var elapsed: float = 0.0
var last_seen_day: int = -1


func start(seed_value: int, data: Dictionary) -> void:
	var _unused: int = seed_value
	elapsed = float(data.get("elapsed", 0.0))
	last_seen_day = int(data.get("last_seen_day", WorldCalendar.today()))


func tick(delta: float) -> void:
	elapsed += delta


func to_dict() -> Dictionary:
	return {"elapsed": elapsed, "last_seen_day": last_seen_day}
