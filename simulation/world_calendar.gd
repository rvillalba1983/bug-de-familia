class_name WorldCalendar
extends RefCounted
## Calendario real del jugador y las 36 festividades fijas. Sin conexión.

const PATH: String = "res://data/world/festivals.json"
const FESTIVALS_PER_MONTH: int = 3
const SECONDS_PER_DAY: int = 86400
## Las pruebas fijan aquí la hora local, en segundos desde 1970.
static var forced_local_unix: int = -1

var festivals: Array[Dictionary] = []


func _init() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not data is Dictionary:
		push_error("Datos ilegibles en %s" % PATH)
		return
	for entry: Variant in (data as Dictionary)["festivals"]:
		festivals.append(entry as Dictionary)
	for problem: String in validate():
		push_error("%s: %s" % [PATH, problem])


static func now_local() -> int:
	if forced_local_unix >= 0:
		return forced_local_unix
	var bias: int = int(Time.get_time_zone_from_system()["bias"])
	return int(Time.get_unix_time_from_system()) + bias * 60


static func day_index(local_unix: int) -> int:
	return floori(float(local_unix) / SECONDS_PER_DAY)


static func today() -> int:
	return day_index(now_local())


func validate() -> Array[String]:
	var problems: Array[String] = []
	var ids: Dictionary = {}
	var dates: Dictionary = {}
	var by_month: Dictionary = {}
	for entry: Dictionary in festivals:
		var id: String = entry["id"]
		var date: String = "%d-%d" % [int(entry["month"]), int(entry["day"])]
		if ids.has(id):
			problems.append("festivals.%s: id repetido" % id)
		if dates.has(date):
			problems.append("festivals.%s: fecha repetida" % id)
		ids[id] = true
		dates[date] = true
		by_month[int(entry["month"])] = int(by_month.get(int(entry["month"]), 0)) + 1
		if (entry["lines"] as Array).is_empty() or str(entry["trace"]).is_empty():
			problems.append("festivals.%s: faltan textos" % id)
	for month: int in range(1, 13):
		if int(by_month.get(month, 0)) != FESTIVALS_PER_MONTH:
			problems.append("mes %d: no tiene tres festividades" % month)
	return problems


func festival_on(day: int) -> Dictionary:
	var date: Dictionary = Time.get_date_dict_from_unix_time(day * SECONDS_PER_DAY)
	for entry: Dictionary in festivals:
		if int(entry["month"]) == int(date["month"]) and int(entry["day"]) == int(date["day"]):
			return entry
	return {}


## Festividades de los días sin jugar: posteriores a `after` y anteriores a `before`.
func missed_between(after: int, before: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var first: int = maxi(after + 1, before - 366)
	for day: int in range(first, before):
		var entry: Dictionary = festival_on(day)
		if not entry.is_empty():
			result.append(entry)
	return result
