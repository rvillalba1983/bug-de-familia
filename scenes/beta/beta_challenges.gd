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
const ID_RAMON_TRACE: String = "huella_ramon"
const ID_CONTESTADOR_TRACE: String = "huella_contestador"
const FOOTPRINT_IDS: Array[String] = [ID_RAMON_TRACE, ID_CONTESTADOR_TRACE]
const SOLDER_SLOTS: Array[ModularBody.Slot] = [
	ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT,
	ModularBody.Slot.ARM_EXTRA_LEFT, ModularBody.Slot.ARM_EXTRA_RIGHT, ModularBody.Slot.HEAD,
]
const SOLDER_SCORE: float = 0.8

## Valores provisionales, a ajustar al probar.
const FIND_RANGE: float = 150.0
const ENCOUNTER_RANGE: float = 170.0
const GROUP_SPEED: float = 70.0
## Provisional: un grupo engañado se marcha más deprisa de lo que patrulla.
const GROUP_LEAVE_SPEED: float = 150.0
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
static var groups: Dictionary = {
	"cuadrilla_moho": {
		"prefix": "moho",
		"route": BetaLayout.moho_group_route,
		"exit": BetaLayout.moho_group_exit,
		# Zona indicada al desviarlos: chatarra sin vigilar, al norte.
		"indicated": BetaLayout.jub_home.get_center(),
	},
	"patrulla_jub": {
		"prefix": "jub",
		"route": BetaLayout.jub_group_route,
		"exit": BetaLayout.jub_group_exit,
		# Zona indicada al desviarlos: sombreros en el sur.
		"indicated": BetaLayout.moho_home.get_center(),
	},
}

const ROUTE_GOALS: Dictionary = {
	ENTER: {"name": "la ce-centralita", "at": Vector2(2570.0, 1040.0)},
	EXTRACT: {"name": "el de-depósito", "at": Vector2(2500.0, 1815.0)},
	CROSS: {"name": "el fi-final de la tierra de nadie", "at": Vector2(3525.0, 1320.0)},
}

var level: BetaZone
## Grupos que se están marchando tras ser engañados.
var _leaving: Dictionary = {}
## Ruta de NavGrid que sigue cada grupo desviado, para no atravesar edificios.
var _leave_paths: Dictionary = {}
var _leave_index: Dictionary = {}
## La primera aplicación viene de cargar: quien ya se fue no vuelve a irse andando.
var _flags_applied: bool = false
var hour_source: Callable = _system_hour

var _group_index: Dictionary = {}
var _offline_time: float = 0.0
var _announced_complete: bool = false
var _footprints: Dictionary = {}


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
		level.noise_bus.emit_noise(BetaLayout.central_door.get_center(), WRONG_CODE_NOISE)
		level.show_notice(tr("BETA_WRONG_CODE"))
	if flag("clave_ok") and not level.door.is_open:
		level.open_central_door()
	if flag("muro_volado") and not level.cracked_wall.is_open:
		level.open_cracked_wall()
	if flag("voto_bobina") and not flag("tiene_bobina"):
		case.flags["tiene_bobina"] = true
	_hide_taken_items()
	_apply_conflict()
	_solder_piece()
	_show_footprints()
	for id: String in groups:
		_apply_group(id)
	_flags_applied = true


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
	var at: Vector2 = BetaLayout.cracked_wall.get_center()
	for enemy: Guard in level.guards():
		if enemy.global_position.distance_to(at) <= BLOWN_WALL_STUN_RADIUS:
			enemy.stun(BLOWN_WALL_STUN_TIME)
	level.noise_bus.emit_noise(at, BLOWN_WALL_NOISE)


func take_reel() -> void:
	level.investigation.set_flag("tiene_bobina")
	level.ai.say_custom(tr("BETA_AI_REEL"))


func break_generator() -> void:
	level.noise_bus.emit_noise(BetaLayout.generator, SandboxLayout.CRATE_NOISE_RADIUS)
	if is_instance_valid(level.ramon) and not level.ramon.is_down():
		level.ramon.investigate(BetaLayout.generator)


func on_ramon_fell() -> void:
	if is_instance_valid(level.ramon):
		leave_footprint(ID_RAMON_TRACE, level.ramon.global_position, "BETA_TRACE_RAMON", "Don Ramón")
	level.investigation.set_flag("ramon_muerto")
	_retire_ramon_item()


## Un aliado único deja huella: un rastro que se guarda y un suceso del que se habla.
func leave_footprint(id: String, at: Vector2, text_key: String, who: String) -> void:
	var flags: Dictionary = level.investigation.flags
	if flags.has(id):
		return
	flags[id] = {"x": at.x, "y": at.y, "text": text_key}
	var sim: WorldSim = level.live_world.sim
	var teller: NpcState = sim.random_alive(sim.rng)
	if teller != null:
		sim.events.report(sim, "muere_ramon" if id == ID_RAMON_TRACE else "muere_contestador", teller.id, "", at)
	level.ai.say_custom(tr("BETA_AI_LOSS") % who)
	_show_footprints()


func _show_footprints() -> void:
	for id: String in FOOTPRINT_IDS:
		var entry: Variant = level.investigation.flags.get(id)
		if entry is Dictionary and not _footprints.has(id):
			var item: Interactable = Interactable.new()
			item.setup(id, Interactable.Kind.EVIDENCE, Vector2(float(entry["x"]), float(entry["y"])))
			item.custom_label = tr("BETA_TRACE_LABEL")
			item.custom_color = FestivalDecor.COLOR_RUIN
			item.reusable = true
			item.activated.connect(_read_footprint)
			level.actors.add_child(item)
			_footprints[id] = item


func _read_footprint(item: Interactable) -> void:
	level.ai.bubble.say(tr(str(level.investigation.flags[item.item_id]["text"])), Color.WHITE, 6.0)


## Don Ramón te suelda un repuesto al contarte la verdad, y solo una vez.
func _solder_piece() -> void:
	if not flag("verdad_ramon") or flag("ramon_soldado"):
		return
	level.investigation.flags["ramon_soldado"] = true
	for slot: ModularBody.Slot in SOLDER_SLOTS:
		if level.player.body.has_room(slot):
			var piece: BodyPiece = PieceForge.forge(
				level.catalog, "nanoacero", "defensa", ModularBody.kind_of(slot), SOLDER_SCORE, level.rng, "p047"
			)
			piece.label = tr("BETA_SOLDER_NAME") + piece.label
			level.player.body.receive(slot, piece)
			level.show_notice(tr("BETA_SOLDER_DONE"))
			return
	level.show_notice(tr("BETA_SOLDER_FULL"))


func _system_hour() -> int:
	return int(Time.get_time_dict_from_system()["hour"])


func _check_challenges() -> void:
	var feet: Vector2 = level.player.global_position
	if BetaLayout.central_inside.has_point(feet):
		_complete(ENTER)
	if flag("tiene_bobina") and not BetaLayout.depot.has_point(feet):
		_complete(EXTRACT)
	if BetaLayout.crossing_goal.has_point(feet):
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
			enemy.set_patrol(BetaLayout.brawl_patrol)
		for enemy: Guard in strip:
			enemy.set_patrol(BetaLayout.brawl_patrol)
	elif (flag("paz") or flag("tregua")) and not level.moved_home:
		level.moved_home = true
		for enemy: Guard in strip:
			var is_jubilado: bool = enemy == level.strip_jubilado
			enemy.set_patrol(BetaLayout.jub_home_patrol if is_jubilado else BetaLayout.moho_home_patrol)


func _apply_power_off() -> void:
	if not is_power_off_hour():
		_restore_jubilados_day()
		return
	var home: Vector2 = BetaLayout.jub_home.get_center()
	for enemy: Guard in level.guards_of("jubilado"):
		enemy.no_attack = true
		if enemy.is_alert():
			enemy.flee_to(home)
		elif not enemy.passive and enemy.state in [Guard.State.PATROL, Guard.State.WAIT, Guard.State.LOOK_AROUND]:
			enemy.set_passive(true)
			enemy.investigate(home)


func _restore_jubilados_day() -> void:
	for enemy: Guard in level.guards_of("jubilado"):
		if not enemy.no_attack:
			continue
		enemy.no_attack = false
		enemy.set_passive(false)
	_apply_conflict()


func _apply_group(id: String) -> void:
	var prefix: String = groups[id]["prefix"]
	var node: Variant = level.investigation.npc_nodes.get(id)
	if flag(prefix + "_desviada") and is_instance_valid(node) and not (node as Interactable).used:
		(node as Interactable).drawn_when_used = _flags_applied
		(node as Interactable).mark_used()
		if _flags_applied:
			_leaving[id] = true
			var goal: Vector2 = _leave_goal(id)
			_leave_paths[id] = level.nav.find_path((node as Node2D).position, goal)
			_leave_index[id] = 0
		else:
			# Partida cargada: el grupo ya está en el punto indicado, visible.
			(node as Interactable).position = _leave_goal(id)
			(node as Interactable).visible = true
	if flag(prefix + "_bronca") and not flag(prefix + "_avisados"):
		level.investigation.flags[prefix + "_avisados"] = true
		_alert_nearby()


func _alert_nearby() -> void:
	var feet: Vector2 = level.player.global_position
	for enemy: Guard in level.guards():
		if enemy != level.ramon and enemy.global_position.distance_to(feet) <= BRAWL_ALERT_RANGE:
			enemy.investigate(feet)


func _move_groups(delta: float) -> void:
	for id: String in groups:
		var item: Variant = level.investigation.npc_nodes.get(id)
		if _leaving.has(id) and is_instance_valid(item):
			_walk_away(id, item as Interactable, delta)
		if not is_instance_valid(item) or (item as Interactable).used:
			continue
		var node: Interactable = item
		var route: Array[Vector2] = groups[id]["route"]
		var index: int = _group_index.get(id, 0)
		node.position = node.position.move_toward(route[index], GROUP_SPEED * delta)
		if node.position.is_equal_approx(route[index]):
			_group_index[id] = (index + 1) % route.size()


## Se va andando hasta donde le han dicho; al llegar deja de estar en la zona.
## Sigue la ruta de NavGrid para no atravesar edificios (P-40).
func _walk_away(id: String, node: Interactable, delta: float) -> void:
	var goal: Vector2 = _leave_goal(id)
	var path: PackedVector2Array = _leave_paths.get(id, PackedVector2Array())
	if path.is_empty() and level.nav != null:
		path = level.nav.find_path(node.position, goal)
		_leave_paths[id] = path
		_leave_index[id] = 0
	var index: int = int(_leave_index.get(id, 0))
	const TOL: float = 6.0
	while index < path.size() and node.position.distance_to(path[index]) <= TOL:
		index += 1
	_leave_index[id] = index
	if index >= path.size():
		# Sin ruta utilizable: cae al movimiento directo para no quedarse parado.
		if path.is_empty():
			node.position = node.position.move_toward(goal, GROUP_LEAVE_SPEED * delta)
			if node.position.is_equal_approx(goal):
				# Se queda en el punto indicado (visible, interactuable): no desaparece para siempre.
				node.position = goal
				_leaving.erase(id)
				_leave_paths.erase(id)
				_leave_index.erase(id)
			return
		# Llegó al punto indicado: se queda allí (visible), no desaparece para siempre.
		node.position = goal
		_leaving.erase(id)
		_leave_paths.erase(id)
		_leave_index.erase(id)
		return
	node.position = node.position.move_toward(path[index], GROUP_LEAVE_SPEED * delta)


## Los grupos engañados van a la zona que se les indicó, no al borde del mapa.
func _leave_goal(id: String) -> Vector2:
	var prefix: String = groups[id]["prefix"]
	if flag(prefix + "_desviada"):
		return groups[id]["indicated"]
	return groups[id]["exit"]


func _check_encounters() -> void:
	var case: InvestigationDirector = level.investigation
	if not case.current_node.is_empty() or level.player.is_crouching:
		return
	for id: String in groups:
		var item: Variant = case.npc_nodes.get(id)
		var seen: String = "encuentro_%s" % id
		if flag(seen) or not is_instance_valid(item) or (item as Interactable).used:
			continue
		var distance: float = (item as Node2D).global_position.distance_to(level.player.global_position)
		if distance <= ENCOUNTER_RANGE:
			case.flags[seen] = true
			case.open_dialogue(id)
			return
