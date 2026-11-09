class_name FestivalSystem
extends RefCounted
## La festividad de hoy y el rastro de las que pasaron con el juego cerrado.

const MAX_TRACES: int = 3
const RUIN_STANDING: float = -6.0
const JOIN_STANDING: float = 2.0

var day: int = -1
var current: Dictionary = {}
var spot: Vector2 = Vector2.ZERO
var ruined: bool = false
var joined: bool = false
## Permanente: las fiestas que el jugador arruinó, por año y día.
var ruined_days: Array = []
var traces: Array = []


func is_running() -> bool:
	return not current.is_empty()


## Calcula la fiesta del día. Sin sitio fijo: va donde esté la gente que la organiza.
func update(sim: WorldSim) -> bool:
	var today: int = WorldCalendar.today()
	if today == day:
		return false
	day = today
	current = sim.calendar.festival_on(today)
	joined = false
	ruined = ruined_days.has(today)
	if is_running():
		spot = _gathering_point(sim, current["host"])
	return true


## Lo que pasó mientras no se jugaba deja restos y nada más.
func collect_traces(sim: WorldSim, last_seen: int) -> Array:
	var added: Array = []
	for entry: Dictionary in sim.calendar.missed_between(last_seen, WorldCalendar.today()):
		traces.append({"id": entry["id"], "name": entry["name"], "text": entry["trace"], "read": false})
		added.append(traces[-1])
	while traces.size() > MAX_TRACES:
		traces.pop_front()
	for index: int in range(traces.size()):
		var at: Vector2 = Vector2.ZERO
		if not sim.open_spots.is_empty():
			at = sim.open_spots[index % sim.open_spots.size()]
		traces[index]["x"] = at.x
		traces[index]["y"] = at.y
	return added.filter(func(t: Dictionary) -> bool: return traces.has(t))


func ruin(sim: WorldSim) -> void:
	if not is_running() or ruined:
		return
	ruined = true
	ruined_days.append(day)
	sim.change_standing(current["host"], RUIN_STANDING)
	sim.events.report(sim, "fiesta_reventada", WorldSim.PLAYER_ID, "", spot)


func join(sim: WorldSim) -> void:
	if is_running() and not joined and not ruined:
		joined = true
		sim.change_standing(current["host"], JOIN_STANDING)


func to_dict() -> Dictionary:
	return {
		"day": day, "x": spot.x, "y": spot.y, "ruined": ruined, "joined": joined,
		"ruined_days": ruined_days, "traces": traces,
	}


func restore(sim: WorldSim, data: Dictionary) -> void:
	day = int(data["day"])
	spot = Vector2(float(data["x"]), float(data["y"]))
	ruined = bool(data["ruined"])
	joined = bool(data["joined"])
	ruined_days = (data["ruined_days"] as Array).map(func(d: Variant) -> int: return int(d))
	traces = data["traces"]
	if day == WorldCalendar.today():
		current = sim.calendar.festival_on(day)


func _gathering_point(sim: WorldSim, host: String) -> Vector2:
	var center: Vector2 = Vector2.ZERO
	var hosts: Array[NpcState] = sim.alive_of(host)
	for npc: NpcState in hosts:
		center += npc.pos
	if not hosts.is_empty():
		center /= float(hosts.size())
	var best: Vector2 = center
	var first: bool = true
	for candidate: Vector2 in sim.open_spots:
		if first or candidate.distance_to(center) < best.distance_to(center):
			best = candidate
			first = false
	return best
