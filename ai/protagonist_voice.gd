class_name ProtagonistVoice
extends Node
## Comentarios espontáneos de Sujeto Sobrante en la zona de la beta.

const DATA_PATH: String = "res://data/protagonist/comments.json"
## Comentarios escritos que aún no tienen ningún sistema que los dispare.
const WAITING_FOR_SYSTEM: Array[String] = ["cupido_in_love", "fast_travel"]
## Marca de la investigación y comentario que provoca, una sola vez.
const FLAG_EVENTS: Dictionary = {
	"e_sombrero": "find_hat",
	"e_manolo": "find_manolo",
	"e_etiqueta": "reel_label",
	"bobina_puesta": "reel_message",
	"verdad_ramon": "ramon_truth",
	"ramon_muerto": "ramon_dead",
	"beta_completa": "all_done",
	"reto_encontrar": "meet_ramon",
	"encuentro_cuadrilla_moho": "moho_vote",
	"encuentro_patrulla_jub": "jub_stop",
}
## Personaje de la investigación y comentario al acercarse por primera vez.
const NEAR_EVENTS: Dictionary = {
	"contestador": "meet_contestador",
	"panel": "central_sealed",
}

## Valores provisionales: ver docs/adr/0007-motes-y-comentarios.md.
const POLL_TIME: float = 1.0
const GLOBAL_COOLDOWN: float = 25.0
const SHORT_COOLDOWN: float = 45.0
const LONG_COOLDOWN: float = 240.0
const VERY_LONG_COOLDOWN: float = 600.0
const IDLE_TIME: float = 30.0
const ABOUT_AIS_INTERVAL: float = 300.0
const SIGHT_RANGE: float = 340.0
const HIDE_RANGE: float = 380.0
const NEAR_RANGE: float = 170.0
const LOW_LEG_LEVEL: float = 25.0
const ANSWER_CHANCE: float = 0.25
const PAUSE_CHANCE: float = 0.2
const LATE_NIGHT_END_HOUR: int = 6

var level: BetaZone
var lines: Dictionary = {}
var global_left: float = 0.0

var _cooldowns: Dictionary = {}
var _last: Dictionary = {}
var _said_flags: Dictionary = {}
var _started: bool = false
var _poll_left: float = POLL_TIME
var _idle_time: float = 0.0
var _about_ais_left: float = ABOUT_AIS_INTERVAL
var _low_leg_warned: bool = false


func _ready() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if not data is Dictionary:
		push_error("Datos ilegibles en %s" % DATA_PATH)
		return
	lines = data


func connect_world() -> void:
	level.rain.started.connect(comment.bind("rain", LONG_COOLDOWN))
	level.pause.paused_changed.connect(_on_paused_changed)
	level.conversion.answered.connect(_on_answered)
	level.conversion.converted.connect(_on_converted)
	level.ai.ai_fell_asleep.connect(comment.bind("ai_asleep", LONG_COOLDOWN))
	level.ai.ai_lost_forever.connect(comment.bind("ai_lost", 0.0, true))
	for point: SavePoint in level.save_points:
		point.entered.connect(comment.bind("saved", LONG_COOLDOWN))


func connect_body(body: ModularBody) -> void:
	body.piece_destroyed.connect(_on_piece_destroyed)
	body.piece_swapped.connect(_on_piece_swapped)
	body.piece_discarded.connect(_on_piece_discarded)


## Devuelve si el comentario ha entrado en la cola de bocadillos.
func comment(event: String, cooldown: float = SHORT_COOLDOWN, is_story: bool = false) -> bool:
	if not _can_comment(event, is_story):
		return false
	_mark_said(event, cooldown)
	level.ai.enqueue_protagonist(pick_line(event))
	return true


func pick_line(event: String) -> String:
	var options: Array = lines.get(event, [])
	if options.is_empty():
		return ""
	var index: int = level.rng.randi_range(0, options.size() - 1)
	if options.size() > 1 and index == int(_last.get(event, -1)):
		index = (index + 1) % options.size()
	_last[event] = index
	return options[index]


## Revisa lo que no avisa con una señal. Público para poder probarlo.
func poll() -> void:
	if not _started:
		_start()
		return
	_check_flags()
	_check_near_events()
	_check_low_leg()
	if level.fight.phase == FightDirector.Phase.CALM:
		_check_sightings()


func _physics_process(delta: float) -> void:
	global_left = maxf(global_left - delta, 0.0)
	for event: String in _cooldowns.keys():
		_cooldowns[event] = maxf(float(_cooldowns[event]) - delta, 0.0)
	_track_idle(delta)
	_about_ais_left -= delta
	if _about_ais_left <= 0.0:
		_about_ais_left = ABOUT_AIS_INTERVAL
		comment("about_ais", LONG_COOLDOWN)
	_poll_left -= delta
	if _poll_left <= 0.0:
		_poll_left = POLL_TIME
		poll()


func _can_comment(event: String, is_story: bool) -> bool:
	if not lines.has(event):
		return false
	return is_story or (global_left <= 0.0 and float(_cooldowns.get(event, 0.0)) <= 0.0)


func _mark_said(event: String, cooldown: float) -> void:
	_cooldowns[event] = cooldown
	global_left = GLOBAL_COOLDOWN


## Lo que ya había pasado al cargar la partida no se vuelve a comentar.
func _start() -> void:
	_started = true
	for flag: String in FLAG_EVENTS:
		if level.investigation.has_flag(flag):
			_said_flags[flag] = true
	if level.resumed:
		comment("returned", VERY_LONG_COOLDOWN)
	elif level.local_hour() < LATE_NIGHT_END_HOUR:
		comment("late_night", VERY_LONG_COOLDOWN)


func _track_idle(delta: float) -> void:
	if level.player.velocity != Vector2.ZERO:
		_idle_time = 0.0
		return
	_idle_time += delta
	if _idle_time >= IDLE_TIME:
		_idle_time = 0.0
		comment("idle", LONG_COOLDOWN)


func _check_flags() -> void:
	for flag: String in FLAG_EVENTS:
		if level.investigation.has_flag(flag) and not _said_flags.has(flag):
			_said_flags[flag] = true
			comment(FLAG_EVENTS[flag], 0.0, true)


func _check_near_events() -> void:
	var feet: Vector2 = level.player.global_position
	var case: InvestigationDirector = level.investigation
	for npc_id: String in NEAR_EVENTS:
		var said: String = "dicho_%s" % npc_id
		var npc: Variant = case.npc_nodes.get(npc_id)
		if case.has_flag(said) or not is_instance_valid(npc):
			continue
		if (npc as Node2D).global_position.distance_to(feet) <= NEAR_RANGE:
			case.flags[said] = true
			comment(NEAR_EVENTS[npc_id], 0.0, true)


func _check_low_leg() -> void:
	var low: bool = false
	for slot: ModularBody.Slot in [ModularBody.Slot.LEG_LEFT, ModularBody.Slot.LEG_RIGHT]:
		var piece: BodyPiece = level.player.body.equipped(slot)
		low = low or (piece != null and piece.durability < LOW_LEG_LEVEL)
	if low and not _low_leg_warned:
		comment("low_leg", LONG_COOLDOWN)
	_low_leg_warned = low


func _check_sightings() -> void:
	var jubilado_near: bool = _any_guard_near(level.jubilado_guards(), SIGHT_RANGE)
	if jubilado_near and level.challenges.is_power_off_hour():
		comment("power_off", VERY_LONG_COOLDOWN)
	elif jubilado_near:
		comment("see_jubilados", LONG_COOLDOWN)
	if _any_guard_near(level.mohocrata_guards(), SIGHT_RANGE):
		comment("see_mohocratas", LONG_COOLDOWN)
	if level.player.is_crouching and _any_guard_near(level.guards(), HIDE_RANGE):
		comment("hiding", LONG_COOLDOWN)
	if _is_near(level.security_camera):
		comment("see_camera", LONG_COOLDOWN)
	if _is_near(level.drone):
		comment("see_drone", LONG_COOLDOWN)
	for mine: Variant in level.mines.values():
		if _is_near(mine):
			comment("see_mine", LONG_COOLDOWN)
			return


func _any_guard_near(list: Array[Guard], reach: float) -> bool:
	for enemy: Guard in list:
		if not enemy.is_down() and _distance_to(enemy) <= reach:
			return true
	return false


func _is_near(node: Variant) -> bool:
	return is_instance_valid(node) and _distance_to(node as Node2D) <= SIGHT_RANGE


func _distance_to(node: Node2D) -> float:
	return node.global_position.distance_to(level.player.global_position)


func _on_paused_changed(is_paused: bool) -> void:
	if not is_paused or level.rng.randf() >= PAUSE_CHANCE:
		return
	if _can_comment("tactical_pause", false):
		_mark_said("tactical_pause", LONG_COOLDOWN)
		level.ai.speak_protagonist_now(pick_line("tactical_pause"))


func _on_answered(correct: bool) -> void:
	if level.rng.randf() < ANSWER_CHANCE:
		comment("right" if correct else "wrong")


func _on_converted(entity_id: String) -> void:
	comment("convert_enemy" if level.is_enemy_id(entity_id) else "convert")


func _on_piece_destroyed(slot: ModularBody.Slot) -> void:
	var is_leg: bool = slot == ModularBody.Slot.LEG_LEFT or slot == ModularBody.Slot.LEG_RIGHT
	if is_leg and level.player.body.leg_count() == 1:
		comment("one_leg", SHORT_COOLDOWN, true)
	else:
		comment("piece_lost")


func _on_piece_swapped(slot: ModularBody.Slot) -> void:
	if slot == ModularBody.Slot.HEAD:
		comment("head_swap", SHORT_COOLDOWN, true)


func _on_piece_discarded(_piece: BodyPiece) -> void:
	comment("discard", LONG_COOLDOWN)
