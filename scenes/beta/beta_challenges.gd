class_name BetaChallenges
extends Node
## Reglas de la beta: los cuatro retos, los dos progenitores y los bandos.
## Todo el estado vive en las marcas de la investigación, que se guardan con la partida.

signal challenge_completed(id: String)

const ENTER: String = "reto_entrar"
const EXTRACT: String = "reto_sacar"
const CROSS: String = "reto_cruzar"
const FIND: String = "reto_encontrar"
const ALL_CHALLENGES: Array[String] = [ENTER, EXTRACT, CROSS, FIND]

## Valores provisionales, a ajustar al probar.
const FIND_RANGE: float = 150.0
const ENCOUNTER_RANGE: float = 170.0
const GROUP_SPEED: float = 70.0
const RAMON_YIELD_HEALTH: float = 30.0
const RAMON_YIELD_STUN: float = 6.0
const WRONG_CODE_NOISE: float = 900.0
const BRAWL_ALERT_RANGE: float = 900.0
const BLOWN_WALL_NOISE: float = 1400.0
const BLOWN_WALL_STUN_RADIUS: float = 220.0
const BLOWN_WALL_STUN_TIME: float = 4.0
const OFFLINE_REFRESH: float = 2.0
const OFFLINE_STUN: float = 5.0
const POWER_OFF_HOUR: int = 21
const POWER_ON_HOUR: int = 8
const GROUPS: Dictionary = {
	"cuadrilla_moho": {"prefix": "moho", "route": BetaLayout.MOHO_GROUP_ROUTE},
	"patrulla_jub": {"prefix": "jub", "route": BetaLayout.JUB_GROUP_ROUTE},
}

const ROUTE_GOALS: Dictionary = {
	ENTER: {"name": "la ce-centralita", "at": Vector2(2570.0, 1040.0)},
	EXTRACT: {"name": "el de-depósito", "at": Vector2(2500.0, 1815.0)},
	CROSS: {"name": "el fi-final de la tierra de nadie", "at": Vector2(3525.0, 1320.0)},
}

var level: BetaZone
var hour_source: Callable = _system_hour

var _group_index: Dictionary = {}
var _offline_time: float = 0.0
var _announced_complete: bool = false


## El primer reto sin hacer y hacia dónde queda, para Ma-Ma-Matriz.
func next_route() -> Dictionary:
	for id: String in ALL_CHALLENGES:
		if not flag(id) and ROUTE_GOALS.has(id):
			var goal: Dictionary = ROUTE_GOALS[id]
			var to: Vector2 = (goal["at"] as Vector2) - level.player.global_position
			return {"meta": goal["name"], "dir": _compass(to)}
	return {}


func _compass(to: Vector2) -> String:
	if absf(to.x) > absf(to.y):
		return "este" if to.x > 0.0 else "oeste"
	return "sur" if to.y > 0.0 else "norte"


func flag(id: String) -> bool:
	return level.investigation.has_flag(id)


func is_power_off_hour() -> bool:
	var hour: int = hour_source.call()
	return hour >= POWER_OFF_HOUR or hour < POWER_ON_HOUR


## Aplica al mundo lo que dicen las marcas. Se puede repetir sin efectos dobles.
func apply_flags() -> void:
	var case: InvestigationDirector = level.investigation
	if flag("clave_mal"):
		case.clear_flag("clave_mal")
		level.noise_bus.emit_noise(BetaLayout.CENTRAL_DOOR.get_center(), WRONG_CODE_NOISE)
		level.show_notice(tr("BETA_WRONG_CODE"))
	if flag("clave_ok") and not level.door.is_open:
		level.open_central_door()
	if flag("muro_volado") and not level.cracked_wall.is_open:
		level.open_cracked_wall()
	if flag("voto_bobina") and not flag("tiene_bobina"):
		case.flags["tiene_bobina"] = true
	_hide_taken_items()
	_apply_conflict()
	for id: String in GROUPS:
		_apply_group(id)


func _physics_process(delta: float) -> void:
	_check_challenges()
	_follow_ramon()
	_move_groups(delta)
	_check_encounters()
	_offline_time -= delta
	if _offline_time <= 0.0:
		_offline_time = OFFLINE_REFRESH
		_apply_power_off()


func take_mine() -> void:
	level.investigation.set_flag("tiene_mina")
	level.ai.say_custom(tr("BETA_AI_MINE"))


func use_cracked_wall() -> void:
	if not flag("tiene_mina"):
		level.show_notice(tr("BETA_WALL_NEEDS_MINE"))
		return
	level.investigation.clear_flag("tiene_mina")
	level.investigation.set_flag("muro_volado")
	var at: Vector2 = BetaLayout.CRACKED_WALL.get_center()
	for enemy: Guard in level.guards():
		if enemy.global_position.distance_to(at) <= BLOWN_WALL_STUN_RADIUS:
			enemy.stun(BLOWN_WALL_STUN_TIME)
	level.noise_bus.emit_noise(at, BLOWN_WALL_NOISE)


func take_reel() -> void:
	level.investigation.set_flag("tiene_bobina")
	level.ai.say_custom(tr("BETA_AI_REEL"))


func break_generator() -> void:
	level.noise_bus.emit_noise(BetaLayout.GENERATOR, SandboxLayout.CRATE_NOISE_RADIUS)
	if is_instance_valid(level.ramon) and not level.ramon.is_down():
		level.ramon.investigate(BetaLayout.GENERATOR)


func on_ramon_fell() -> void:
	level.investigation.set_flag("ramon_muerto")
	_retire_ramon_item()


func _system_hour() -> int:
	return int(Time.get_time_dict_from_system()["hour"])


func _check_challenges() -> void:
	var feet: Vector2 = level.player.global_position
	if BetaLayout.CENTRAL_INSIDE.has_point(feet):
		_complete(ENTER)
	if flag("tiene_bobina") and not BetaLayout.DEPOT.has_point(feet):
		_complete(EXTRACT)
	if BetaLayout.CROSSING_GOAL.has_point(feet):
		_complete(CROSS)
	if is_instance_valid(level.ramon) and not level.ramon.is_down():
		if level.ramon.global_position.distance_to(feet) <= FIND_RANGE:
			_complete(FIND)


func _complete(id: String) -> void:
	if flag(id):
		return
	level.investigation.set_flag(id)
	level.show_notice(tr("BETA_DONE_%s" % id))
	level.ai.say_custom(tr("BETA_AI_%s" % id))
	challenge_completed.emit(id)
	_check_all_complete()
	if level.fight.phase == FightDirector.Phase.CALM:
		level.autosave()


func _check_all_complete() -> void:
	for id: String in ALL_CHALLENGES:
		if not flag(id):
			return
	if flag("beta_completa"):
		return
	level.investigation.set_flag("beta_completa")
	level.show_notice(tr("BETA_ALL_DONE"))
	for index: int in range(3):
		level.ai.say_custom(tr("BETA_AI_ALL_%d" % index))


func _follow_ramon() -> void:
	var item: Interactable = level.ramon_item()
	if item == null:
		return
	if not is_instance_valid(level.ramon) or level.ramon.is_down():
		_retire_ramon_item()
		return
	item.global_position = level.ramon.global_position
	if level.ramon.health < RAMON_YIELD_HEALTH and not flag("ramon_peleado"):
		level.investigation.set_flag("ramon_peleado")
		level.ramon.stun(RAMON_YIELD_STUN)
		level.show_notice(tr("BETA_RAMON_YIELDS"))


func _retire_ramon_item() -> void:
	var item: Interactable = level.ramon_item()
	if item != null and not item.used:
		item.reusable = false
		item.mark_used()


func _hide_taken_items() -> void:
	var taken: Dictionary = {
		BetaZone.ID_MINE: flag("tiene_mina") or flag("muro_volado"),
		BetaZone.ID_REEL: flag("tiene_bobina"),
		BetaZone.ID_CRACK: flag("muro_volado"),
	}
	for id: String in taken:
		if taken[id] and level.items.has(id):
			(level.items[id] as Interactable).visible = false
			(level.items[id] as Interactable).mark_used()


## El estado del conflicto recoloca a los bandos, también al cargar la partida.
func _apply_conflict() -> void:
	var strip: Array[Guard] = level.strip_guards()
	var safe_passage: bool = flag("salvoconducto") or flag("paz") or flag("tregua")
	for enemy: Guard in strip:
		enemy.set_passive(safe_passage)
	if flag("guerra") and not level.moved_to_war:
		level.moved_to_war = true
		if BattleDirector.auto_start and not flag("batalla_guerra") and level.live_world.started:
			level.investigation.flags["batalla_guerra"] = true
			level.battles.begin()
		for enemy: Guard in level.depot_guards():
			enemy.set_patrol(BetaLayout.BRAWL_PATROL)
		for enemy: Guard in strip:
			enemy.set_patrol(BetaLayout.BRAWL_PATROL)
	elif (flag("paz") or flag("tregua")) and not level.moved_home:
		level.moved_home = true
		for enemy: Guard in strip:
			var is_jubilado: bool = enemy == level.strip_jubilado
			enemy.set_patrol(BetaLayout.JUB_HOME_PATROL if is_jubilado else BetaLayout.MOHO_HOME_PATROL)


func _apply_power_off() -> void:
	if not is_power_off_hour():
		return
	for enemy: Guard in level.jubilado_guards():
		if not enemy.is_alert():
			enemy.stun(OFFLINE_STUN)


func _apply_group(id: String) -> void:
	var prefix: String = GROUPS[id]["prefix"]
	var node: Variant = level.investigation.npc_nodes.get(id)
	if flag(prefix + "_desviada") and is_instance_valid(node):
		(node as Interactable).visible = false
		(node as Interactable).mark_used()
	if flag(prefix + "_bronca") and not flag(prefix + "_avisados"):
		level.investigation.flags[prefix + "_avisados"] = true
		_alert_nearby()


func _alert_nearby() -> void:
	var feet: Vector2 = level.player.global_position
	for enemy: Guard in level.guards():
		if enemy != level.ramon and enemy.global_position.distance_to(feet) <= BRAWL_ALERT_RANGE:
			enemy.investigate(feet)


func _move_groups(delta: float) -> void:
	for id: String in GROUPS:
		var item: Variant = level.investigation.npc_nodes.get(id)
		if not is_instance_valid(item) or (item as Interactable).used:
			continue
		var node: Interactable = item
		var route: Array[Vector2] = GROUPS[id]["route"]
		var index: int = _group_index.get(id, 0)
		node.position = node.position.move_toward(route[index], GROUP_SPEED * delta)
		if node.position.is_equal_approx(route[index]):
			_group_index[id] = (index + 1) % route.size()


func _check_encounters() -> void:
	var case: InvestigationDirector = level.investigation
	if not case.current_node.is_empty() or level.player.is_crouching:
		return
	for id: String in GROUPS:
		var item: Variant = case.npc_nodes.get(id)
		var seen: String = "encuentro_%s" % id
		if flag(seen) or not is_instance_valid(item) or (item as Interactable).used:
			continue
		var distance: float = (item as Node2D).global_position.distance_to(level.player.global_position)
		if distance <= ENCOUNTER_RANGE:
			case.flags[seen] = true
			case.open_dialogue(id)
			return
