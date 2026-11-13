class_name ZoneManager
extends Node
## Gestor multi-zona (ADR 0027): carga la zona actual, simula las demás y
## conserva su estado entre visitas.

signal transition_started(from_zone: String, to_zone: String)
signal transition_finished(zone_id: String)
signal zone_loaded(zone_id: String)

const DESPLEGUE_CERO_SCENE: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"
const ZONE_SCENE: String = "res://scenes/zones/zone.tscn"
## Tiempo mínimo de carga entre zonas (decisión 2).
const MIN_TRANSITION: float = 5.0
## Provisional: segundos de mundo por salto en viaje rápido.
const TRAVEL_SECONDS_PER_HOP: float = 60.0
## Provisional: individuos por segundo que una zona estadística se acerca a su objetivo.
const STATISTICAL_RATE: float = 0.05

var registry: ZoneRegistry = ZoneRegistry.load_default()
var host: Node = null
var current_zone: ZoneBase = null
var current_id: String = ""
var records: Dictionary = {}
var world_seconds: float = 0.0
## Datos globales del protagonista: cuerpo, semilla y muerte. Las zonas no los pisan.
var profile: Dictionary = {}
## Las pruebas lo bajan a 0 para no esperar. En partida vale MIN_TRANSITION.
var min_transition: float = MIN_TRANSITION
## Las pruebas pueden sustituir la fábrica por una escena mínima.
var zone_factory: Callable = Callable()

var loading: bool = false
var transition_target: String = ""
var transition_elapsed: float = 0.0

var _sims: Dictionary = {}


func setup(zone_host: Node) -> void:
	host = zone_host


## Carga la zona guardada o la de inicio. Devuelve si se ha montado.
func start(start_zone_id: String = "despliegue_cero") -> bool:
	var loaded: Dictionary = SaveSystem.read()
	if loaded["status"] == SaveSystem.Status.OK:
		_restore(loaded["data"])
	if profile.is_empty():
		profile = {
			"body": {},
			"seed": Sandbox.forced_seed if Sandbox.forced_seed >= 0 else randi(),
			"dead": false,
		}
	var target: String = current_id if not current_id.is_empty() else start_zone_id
	if not registry.has(target):
		push_error("ZoneManager: la zona de inicio «%s» no existe" % target)
		return false
	var result: bool = _load_zone(target, "")
	if result:
		autosave()
	return result


func _process(delta: float) -> void:
	_advance_world(delta)
	world_seconds += delta
	if not loading:
		return
	transition_elapsed += delta
	if transition_elapsed >= min_transition:
		_complete_transition()


## Cruza a otra zona con pantalla de carga. Falso si no es posible.
func enter(zone_id: String) -> bool:
	if loading or zone_id == current_id or not registry.has(zone_id):
		return false
	transition_target = zone_id
	transition_elapsed = 0.0
	loading = true
	if current_zone != null:
		current_zone.freeze_player(true)
	transition_started.emit(current_id, zone_id)
	if min_transition <= 0.0:
		_complete_transition()
	return true


## Zonas a las que se puede viajar desde un punto de guardado.
func travel_destinations() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for zone_id: String in registry.ids():
		if not can_fast_travel(zone_id):
			continue
		var zone: ZoneDefinition = registry.zone(zone_id)
		result.append({
			"id": zone_id,
			"name": zone.display_name,
			"hops": int(registry.graph.hops(current_id, zone_id)),
		})
	result.sort_custom(_by_distance)
	return result


func _by_distance(a: Dictionary, b: Dictionary) -> bool:
	if int(a["hops"]) != int(b["hops"]):
		return int(a["hops"]) < int(b["hops"])
	return str(a["name"]) < str(b["name"])


func can_fast_travel(zone_id: String) -> bool:
	if loading or not registry.has(zone_id) or zone_id == current_id:
		return false
	var record: ZoneRecord = records.get(zone_id) as ZoneRecord
	if record == null or not record.visited:
		return false
	if registry.graph.hops(current_id, zone_id) < 1:
		return false
	return current_zone == null or not current_zone.is_in_combat()


## El tiempo del mundo avanza y las demás zonas se simulan durante el viaje.
func fast_travel(zone_id: String) -> bool:
	if not can_fast_travel(zone_id):
		return false
	var seconds: float = TRAVEL_SECONDS_PER_HOP * float(registry.graph.hops(current_id, zone_id))
	_advance_world(seconds)
	_persist_sims()
	world_seconds += seconds
	return enter(zone_id)


func refresh_levels() -> void:
	for zone_id: String in registry.ids():
		var record: ZoneRecord = _record(zone_id)
		if zone_id == current_id:
			record.level = ZoneRecord.Level.FULL
		elif registry.graph.neighbours(current_id).has(zone_id):
			record.level = ZoneRecord.Level.SIMPLIFIED
		else:
			record.level = ZoneRecord.Level.STATISTICAL


func level_of(zone_id: String) -> int:
	return _record(zone_id).level


func is_known(zone_id: String) -> bool:
	var record: ZoneRecord = records.get(zone_id) as ZoneRecord
	return record != null and record.visited


## Guarda la zona actual y el estado de todas las zonas conocidas.
func autosave() -> bool:
	if current_zone == null:
		return false
	_capture_current()
	_persist_sims()
	var record: ZoneRecord = _record(current_id)
	var payload: Dictionary = record.level_state.duplicate(true)
	payload["body"] = profile.get("body", payload.get("body", {}))
	payload["seed"] = int(profile.get("seed", payload.get("seed", 0)))
	payload["dead"] = bool(profile.get("dead", payload.get("dead", false)))
	payload["world_zones"] = {"current": current_id, "records": record_dicts()}
	payload["world_seconds"] = world_seconds
	return SaveSystem.write(payload)


func record_dicts() -> Dictionary:
	var result: Dictionary = {}
	for zone_id: String in registry.ids():
		var record: ZoneRecord = records.get(zone_id) as ZoneRecord
		if record == null:
			continue
		if not record.visited and record.level_state.is_empty() and record.world.is_empty():
			continue
		result[zone_id] = record.to_dict()
	return result


func _load_zone(zone_id: String, from_zone: String) -> bool:
	if host == null:
		push_error("ZoneManager: falta setup(host) antes de cargar «%s»" % zone_id)
		return false
	var zone_definition: ZoneDefinition = registry.zone(zone_id)
	if zone_definition == null:
		push_error("ZoneManager: no existe la zona «%s»" % zone_id)
		return false
	var record: ZoneRecord = _record(zone_id)
	_persist_sim(zone_id)
	_sims.erase(zone_id)
	Sandbox.pending_save = _zone_state(zone_id, record, zone_definition)
	var zone: ZoneBase = _factory(zone_id)
	if zone == null:
		Sandbox.pending_save = {}
		push_error("ZoneManager: no se pudo instanciar la zona «%s»" % zone_id)
		return false
	zone.set_definition(zone_definition)
	zone.zone_manager = self
	zone.world_mode = true
	host.add_child(zone)
	Sandbox.pending_save = {}
	current_zone = zone
	current_id = zone_id
	record.mark_visited(WorldCalendar.today())
	record.visited = true
	zone.transition_requested.connect(_on_transition_requested)
	zone.after_enter(from_zone)
	refresh_levels()
	if record.population.is_empty():
		record.population = zone.population_counts()
	zone_loaded.emit(zone_id)
	return true


func _factory(zone_id: String) -> ZoneBase:
	if zone_factory.is_valid():
		return zone_factory.call(zone_id) as ZoneBase
	var path: String = DESPLEGUE_CERO_SCENE if zone_id == "despliegue_cero" else ZONE_SCENE
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	return packed.instantiate() as ZoneBase


func _on_transition_requested(to_zone: String) -> void:
	enter.call_deferred(to_zone)


func _complete_transition() -> void:
	var from_zone: String = current_id
	var target: String = transition_target
	_capture_current()
	_persist_sims()
	if current_zone != null:
		host.remove_child(current_zone)
		current_zone.queue_free()
		current_zone = null
	loading = false
	transition_elapsed = 0.0
	transition_target = ""
	var moved: bool = _load_zone(target, from_zone)
	if not moved:
		_load_zone(from_zone, "")
	refresh_levels()
	autosave()
	transition_finished.emit(current_id)


func _capture_current() -> void:
	if current_zone == null:
		return
	var record: ZoneRecord = _record(current_id)
	record.level_state = current_zone.snapshot()
	record.world = record.level_state.get("world", {})
	record.population = ZoneRecord.counts_from_world(record.world)
	record.visited = true
	record.last_seen_day = WorldCalendar.today()
	profile["body"] = record.level_state.get("body", {})
	profile["seed"] = int(record.level_state.get("seed", 0))
	profile["dead"] = bool(record.level_state.get("dead", false))


func _restore(data: Dictionary) -> void:
	world_seconds = float(data.get("world_seconds", 0.0))
	profile = {
		"body": data.get("body", {}),
		"seed": int(data.get("seed", 0)),
		"dead": bool(data.get("dead", false)),
	}
	var zones: Dictionary = data.get("world_zones", {})
	if zones.is_empty():
		## Partida de la despliegue cero de antes del gestor multi-zona.
		var record: ZoneRecord = _record("despliegue_cero")
		record.level_state = data
		record.visited = true
		record.last_seen_day = WorldCalendar.today()
		current_id = "despliegue_cero"
		return
	current_id = SaveSystem.migrate_zone_id(str(zones.get("current", "")))
	var stored: Dictionary = zones.get("records", {})
	for zone_id: Variant in stored:
		var entry: Dictionary = stored[zone_id]
		var migrated: String = SaveSystem.migrate_zone_id(str(zone_id))
		var record: ZoneRecord = ZoneRecord.from_dict(entry)
		record.zone_id = migrated
		records[migrated] = record


func _record(zone_id: String) -> ZoneRecord:
	var record: ZoneRecord = records.get(zone_id) as ZoneRecord
	if record == null:
		record = ZoneRecord.create(zone_id)
		records[zone_id] = record
	return record


## Guardado que recibe la escena: cuerpo global y estado propio de la zona.
func _zone_state(zone_id: String, record: ZoneRecord, zone: ZoneDefinition) -> Dictionary:
	var state: Dictionary
	if record.level_state.is_empty():
		state = LevelSaveState.fresh(zone.start(), _zone_seed(zone_id), _profile_body())
		if not record.world.is_empty():
			state["world"] = record.world.duplicate(true)
	else:
		state = record.level_state.duplicate(true)
	state["body"] = profile.get("body", state.get("body", {}))
	state["dead"] = bool(profile.get("dead", state.get("dead", false)))
	return state


func _profile_body() -> ModularBody:
	var body: ModularBody = ModularBody.from_dict(profile.get("body", {}))
	if body == null:
		body = Sandbox.default_body()
	return body


## Semilla estable por zona, derivada de la semilla global de la partida.
func _zone_seed(zone_id: String) -> int:
	var base: int = int(profile.get("seed", 0))
	if zone_id == "despliegue_cero":
		return base
	return hash("zona_%s_%d" % [zone_id, base])


func _advance_world(seconds: float) -> void:
	for zone_id: String in registry.ids():
		if zone_id == current_id:
			continue
		var record: ZoneRecord = records.get(zone_id) as ZoneRecord
		if record == null or not record.visited:
			continue
		if record.level == ZoneRecord.Level.SIMPLIFIED:
			_tick_simplified(record, seconds)
		elif record.level == ZoneRecord.Level.STATISTICAL:
			_advance_statistical(record, seconds)


func _tick_simplified(record: ZoneRecord, seconds: float) -> void:
	var zone: ZoneDefinition = registry.zone(record.zone_id)
	if zone == null or zone.species().is_empty():
		return
	var sim: WorldSim = _sims.get(record.zone_id) as WorldSim
	if sim == null:
		sim = WorldSim.new()
		_configure_sim(sim, zone)
		sim.start(0, record.world)
		_sims[record.zone_id] = sim
	sim.tick(seconds)
	record.population = ZoneRecord.aggregate(sim)


func _configure_sim(sim: WorldSim, zone: ZoneDefinition) -> void:
	var active: Array[String] = zone.active_species()
	sim.active_species = active
	sim.species_declared = true
	sim.species_limits = zone.population()
	for species_id: String in active:
		sim.spawn_areas[species_id] = zone.home_area(species_id)
		sim.gates[species_id] = zone.home_gate(species_id)
	sim.open_spots = zone.points("open_spots") if zone.has("open_spots") else [zone.start()]


func _advance_statistical(record: ZoneRecord, seconds: float) -> void:
	var zone: ZoneDefinition = registry.zone(record.zone_id)
	if zone == null:
		return
	for species_id: String in zone.species():
		var limits: Dictionary = zone.population().get(species_id, {})
		if limits.is_empty():
			continue
		var count: float = float(record.population.get(species_id, int(limits.get("start", 0))))
		var target: float = float(limits.get("target", count))
		var maximum: int = int(limits.get("max", int(maxf(count, target))))
		var next: float = move_toward(count, target, STATISTICAL_RATE * seconds)
		record.population[species_id] = clampi(int(round(next)), 0, maximum)


func _persist_sims() -> void:
	for zone_id: String in _sims.keys():
		_persist_sim(zone_id)


func _persist_sim(zone_id: String) -> void:
	var sim: WorldSim = _sims.get(zone_id) as WorldSim
	if sim == null:
		return
	var record: ZoneRecord = _record(zone_id)
	record.world = sim.to_dict()
	record.population = ZoneRecord.aggregate(sim)
