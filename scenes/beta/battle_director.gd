class_name BattleDirector
extends Node
## Batallas entre facciones dentro de la zona beta. Todos los valores son provisionales.

signal started
signal finished(winner: String)

enum Phase { NONE, OFFER, RUNNING }

const DATA_PATH: String = "res://data/world/battles.json"
const FRONT: Vector2 = Vector2(2100.0, 1320.0)
const MAX_PER_SIDE: int = 8
const MIN_PER_SIDE: int = 3
const ORDER_INTERVAL: float = 0.5
const STRIKE_RANGE: float = 95.0
const STRIKE_COOLDOWN: float = 1.6
const STRIKE_MIN: float = 10.0
const STRIKE_MAX: float = 20.0
const TIME_LIMIT: float = 150.0
const SHOUT_INTERVAL: float = 9.0
const SHOUT_RANGE: float = 600.0
const WITNESS_RANGE: float = 700.0
const WITNESS_STANDING: float = -10.0
const JOIN_STANDING: float = 8.0
const AGAINST_STANDING: float = -12.0
const RELATION_AFTER: float = -15.0
const NATURAL_CHECK: float = 30.0
const NATURAL_RELATION: float = -55.0
const NATURAL_CHANCE: float = 0.25
const NATURAL_COOLDOWN: float = 600.0
const SPECIES: Array[String] = ["jubilado", "mohocrata"]

## Las pruebas lo apagan: la oferta espera al jugador y pausa el juego.
static var auto_start: bool = true

var level: BetaZone
var phase: Phase = Phase.NONE
var joined: String = ""
var sides: Dictionary = {"jubilado": [], "mohocrata": []}
var fallen: Array[String] = []
var data: Dictionary = {}
var speed: float = 1.0

var _order_time: float = 0.0
var _clock: float = 0.0
var _shout_time: float = SHOUT_INTERVAL
var _natural_time: float = NATURAL_CHECK
var _since_last: float = NATURAL_COOLDOWN
var _strike_ready: Dictionary = {}
var _offer: BattleOffer
var _view: StrategyView


func _ready() -> void:
	data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	_offer = BattleOffer.new()
	_offer.chosen.connect(_on_offer_chosen)
	add_child(_offer)
	_view = StrategyView.new()
	_view.director = self
	add_child(_view)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func is_fighter(id: String) -> bool:
	return phase == Phase.RUNNING and ((sides["jubilado"] as Array).has(id) or (sides["mohocrata"] as Array).has(id))


func strategy_view() -> StrategyView:
	return _view


## Devuelve si la batalla ha podido empezar.
func begin() -> bool:
	if phase != Phase.NONE:
		return false
	var world: LiveWorld = level.live_world
	for species: String in SPECIES:
		sides[species] = []
		for npc: NpcState in world.sim.alive_of(species):
			if (sides[species] as Array).size() < MAX_PER_SIDE and world.citizens.has(npc.id):
				(sides[species] as Array).append(npc.id)
		if (sides[species] as Array).size() < MIN_PER_SIDE:
			sides = {"jubilado": [], "mohocrata": []}
			return false
	phase = Phase.OFFER
	joined = ""
	fallen.clear()
	_strike_ready.clear()
	_clock = 0.0
	_since_last = 0.0
	return true


func choose(option: int) -> void:
	_on_offer_chosen(option)


func set_speed(value: float) -> void:
	speed = value
	Engine.time_scale = value


func close_view() -> void:
	_view.close()
	set_speed(1.0)


func on_converted(entity_id: String) -> void:
	if not fallen.has(entity_id):
		return
	var world: LiveWorld = level.live_world
	var species: String = (world.sim.npcs[entity_id] as NpcState).species
	for npc: NpcState in world.sim.alive_of(species):
		if npc.pos.distance_to(level.player.global_position) <= WITNESS_RANGE:
			world.sim.change_standing(species, WITNESS_STANDING)
			world.say_from(npc, str(data["witness"][species]))
			return


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	_since_last += delta
	match phase:
		Phase.NONE:
			_check_natural(delta)
		Phase.OFFER:
			_offer.open(self)
		Phase.RUNNING:
			_run(delta)


func _check_natural(delta: float) -> void:
	_natural_time -= delta
	if not auto_start or _natural_time > 0.0:
		return
	_natural_time = NATURAL_CHECK
	var sim: WorldSim = level.live_world.sim
	if sim.species_relation <= NATURAL_RELATION and _since_last >= NATURAL_COOLDOWN and level.rng.randf() < NATURAL_CHANCE:
		begin()


func _on_offer_chosen(option: int) -> void:
	if phase != Phase.OFFER:
		return
	_offer.close()
	phase = Phase.RUNNING
	var world: LiveWorld = level.live_world
	if option < SPECIES.size():
		joined = SPECIES[option]
		var other: String = _rival(joined)
		world.sim.change_standing(joined, JOIN_STANDING)
		world.sim.change_standing(other, AGAINST_STANDING)
		for id: String in sides[other]:
			(world.citizens[id] as Guard).set_passive(false)
	elif option == SPECIES.size():
		_view.open()
	started.emit()


func _run(delta: float) -> void:
	_clock += delta
	for id: String in _strike_ready.keys():
		_strike_ready[id] = maxf(float(_strike_ready[id]) - delta, 0.0)
	_order_time -= delta
	if _order_time <= 0.0:
		_order_time = ORDER_INTERVAL
		_give_orders()
	if not joined.is_empty():
		_shout(delta)
	var alive_a: int = alive_in("jubilado").size()
	var alive_b: int = alive_in("mohocrata").size()
	if alive_a == 0 or alive_b == 0 or _clock >= TIME_LIMIT:
		_finish(alive_a, alive_b)


func alive_in(species: String) -> Array[Guard]:
	var result: Array[Guard] = []
	for id: String in sides[species]:
		var guard: Variant = level.live_world.citizens.get(id)
		if is_instance_valid(guard) and not (guard as Guard).is_down():
			result.append(guard as Guard)
	return result


func _give_orders() -> void:
	for species: String in SPECIES:
		var foes: Array[Guard] = alive_in(_rival(species))
		if foes.is_empty():
			return
		for id: String in sides[species]:
			var guard: Variant = level.live_world.citizens.get(id)
			if not is_instance_valid(guard) or (guard as Guard).is_down() or (guard as Guard).is_alert():
				continue
			_order(id, guard as Guard, foes)


func _order(id: String, guard: Guard, foes: Array[Guard]) -> void:
	var nearest: Guard = foes[0]
	for foe: Guard in foes:
		if guard.global_position.distance_squared_to(foe.global_position) < guard.global_position.distance_squared_to(nearest.global_position):
			nearest = foe
	if guard.global_position.distance_to(nearest.global_position) > STRIKE_RANGE:
		guard.investigate(nearest.global_position)
	elif float(_strike_ready.get(id, 0.0)) <= 0.0:
		_strike_ready[id] = STRIKE_COOLDOWN
		_strike(nearest)


func _strike(foe: Guard) -> void:
	var was_alive: bool = not foe.is_down()
	level.live_world.battle_casualty = true
	foe.take_battle_hit(level.rng.randf_range(STRIKE_MIN, STRIKE_MAX))
	level.live_world.battle_casualty = false
	if was_alive and foe.is_down():
		var id: String = level.id_of_guard(foe)
		fallen.append(id)


func _shout(delta: float) -> void:
	_shout_time -= delta
	if _shout_time > 0.0:
		return
	_shout_time = SHOUT_INTERVAL
	var feet: Vector2 = level.player.global_position
	var world: LiveWorld = level.live_world
	for guard: Guard in alive_in(joined):
		if guard.global_position.distance_to(feet) <= SHOUT_RANGE:
			var lines: Array = data["orders"][joined]
			var roles: Array = data["roles"]
			var text: String = str(lines[level.rng.randi_range(0, lines.size() - 1)]).format({
				"dir": _compass(FRONT - feet), "rol": roles[level.rng.randi_range(0, roles.size() - 1)]
			})
			world.say_from(world.sim.npcs[level.id_of_guard(guard)], text)
			return


func _compass(to: Vector2) -> String:
	if absf(to.x) > absf(to.y):
		return "este" if to.x > 0.0 else "oeste"
	return "sur" if to.y > 0.0 else "norte"


func _finish(alive_a: int, alive_b: int) -> void:
	var winner: String = ""
	if alive_a != alive_b and (alive_a == 0 or alive_b == 0):
		winner = "jubilado" if alive_a > 0 else "mohocrata"
	var world: LiveWorld = level.live_world
	if not joined.is_empty():
		for id: String in sides[_rival(joined)]:
			var guard: Variant = world.citizens.get(id)
			if is_instance_valid(guard) and not (guard as Guard).is_down():
				(guard as Guard).set_passive(true)
	world.sim.change_species_relation(RELATION_AFTER)
	var text: String = str(data["draw"]) if winner.is_empty() else str(data["won"]) % str(data["names"][winner])
	level.ai.say_custom(text)
	world.sim.events.report(world.sim, "batalla_faccion", _any_id(winner), "", FRONT)
	phase = Phase.NONE
	close_view()
	finished.emit(winner)
	if level.fight.phase == FightDirector.Phase.CALM:
		level.autosave()


func _any_id(winner: String) -> String:
	var species: String = winner if not winner.is_empty() else "jubilado"
	return (sides[species] as Array)[0]


func _rival(species: String) -> String:
	return "mohocrata" if species == "jubilado" else "jubilado"
