class_name AiChatter
extends Node
## Decide qué IA habla y cuándo, y aplica sus ventajas.

signal ai_fell_asleep
signal ai_lost_forever

## Valores provisionales.
const IDLE_TIME: float = 12.0
const ARGUMENT_INTERVAL: float = 45.0
const FALSE_ALARM_INTERVAL: float = 30.0
const DANGER_COOLDOWN: float = 8.0
const LOW_PIECE_LEVEL: float = 25.0
const PANIC_SENSE_RANGE: float = 260.0
const DESPRECIO_STUN_BONUS: float = 1.3
const HINT_INTERVAL: float = 55.0
const DECOY_INTERVAL: float = 40.0
const DECOY_DISTANCE: float = 340.0
const DECOY_NOISE: float = 420.0
const ARGUMENT_MUTE: float = 15.0
const TAIL_IDLE: Color = Color("#404050")
const MOTE_CHANCE: float = 0.3
const MOTE_EVENTS: Array[String] = ["danger", "fight", "piece_lost", "right", "wrong", "converted"]
const TAUNT_EVENT: String = "taunt"
const PROTAGONIST: String = "protagonista"
const PROTAGONIST_NAME: String = "Sujeto Sobrante"
const PROTAGONIST_COLOR: Color = Color("#ff9a3c")
const PROTAGONIST_PITCH: float = 1.0

var level: Sandbox
var team: AiTeam = AiTeam.new()
var perks: AiPerks = AiPerks.new(team)
## Devuelven los datos de los avisos de zona; sin ellos, esas IAs no los dan.
var route_hint: Callable = Callable()
var treason_hint: Callable = Callable()
var nicknames: Nicknames = Nicknames.new()
var bubble: SpeechBubble
var voice: BlablaVoice
## Canal IRC donde hablan las IAs; sin él, usan el bocadillo.
var chat: IrcChat

var _queue: Array = []
var _idle_time: float = 0.0
var _argument_time: float = ARGUMENT_INTERVAL
var _alarm_time: float = FALSE_ALARM_INTERVAL
var _danger_cooldown: float = 0.0
var _low_warned: bool = false
var _line_time: float = 0.0
var _hint_time: float = HINT_INTERVAL
var _decoy_time: float = DECOY_INTERVAL


func _ready() -> void:
	bubble = SpeechBubble.new()
	bubble.position = Vector2(0.0, -100.0)
	bubble.visible = false
	level.player.add_child(bubble)
	voice = BlablaVoice.new()
	add_child(voice)


func restore(data: Dictionary) -> void:
	team.restore(data, level.rng)


func _physics_process(delta: float) -> void:
	team.tick(delta)
	_danger_cooldown = maxf(_danger_cooldown - delta, 0.0)
	_track_idle(delta)
	_track_danger()
	_argument_time -= delta
	if _argument_time <= 0.0:
		_argument_time = ARGUMENT_INTERVAL
		_start_argument()
	_alarm_time -= delta
	if _alarm_time <= 0.0:
		_alarm_time = FALSE_ALARM_INTERVAL
		if team.can_speak("panico"):
			_enqueue("panico", "false_alarm")
	_track_perks(delta)
	_play_next()


func say(event: String) -> void:
	var options: Array = team.speakers().filter(_has_line.bind(event))
	if not options.is_empty():
		_enqueue(options[level.rng.randi_range(0, options.size() - 1)], event)


## Cada evento lo dice una IA distinta, si hay suficientes.
func say_chain(events: Array) -> void:
	var options: Array = team.speakers()
	for event: String in events:
		var candidates: Array = options.filter(_has_line.bind(event))
		if not candidates.is_empty():
			var speaker: String = candidates[level.rng.randi_range(0, candidates.size() - 1)]
			_enqueue(speaker, event)
			options.erase(speaker)


func say_custom(text: String) -> void:
	var options: Array = team.speakers()
	if not options.is_empty():
		var speaker: String = options[level.rng.randi_range(0, options.size() - 1)]
		_queue.append({"id": speaker, "text": text})


func stun_bonus() -> float:
	return DESPRECIO_STUN_BONUS if team.has_active("dr_desprecio") else 1.0


## Ayuda o sabotaje de las IAs activas durante una pregunta.
func question_advice(question: Dictionary) -> Dictionary:
	var options: Array = question["options"]
	var answer: int = int(question["answer"])
	var wrong: Array = []
	for index: int in range(options.size()):
		if index != answer:
			wrong.append(index)
	if perks.in_love():
		return {"text": "Cupido_Beta: «La %d, mi vida. No se lo digas a Narcisa»." % (answer + 1), "disabled": -1}
	if team.can_speak("rencorosa") and options.size() > 2:
		var cut: int = wrong[level.rng.randi_range(0, wrong.size() - 1)]
		return {"text": "Rencorosa Pro: «Esa no. Y no te acostumbres».", "disabled": cut}
	if team.can_speak("abuela") and options.size() > 2:
		var discarded: int = wrong[level.rng.randi_range(0, wrong.size() - 1)]
		return {"text": "Abuela RAM: «Esa no era, cariño, creo».", "disabled": discarded}
	if team.can_speak("troll") and not team.has_active("arbitro"):
		var bait: int = wrong[level.rng.randi_range(0, wrong.size() - 1)]
		var text: String = "Troll-o-Matic: «Es la %d. Confía en mí. Jeje.»" % (bait + 1)
		return {"text": text, "disabled": -1}
	return {}


## Burla de una IA activa al convertir. Elige con el texto de la pregunta para no gastar
## la semilla de la partida: es solo presentación.
func question_taunt(question: Dictionary) -> Dictionary:
	var speakers: Array = team.speakers().filter(_has_taunt)
	if speakers.is_empty():
		return {}
	var seed_value: int = absi(str(question["text"]).hash())
	var id: String = speakers[seed_value % speakers.size()]
	var data: Dictionary = team.ais[id]
	var lines: Array = data["lines"][TAUNT_EVENT]
	return {
		"name": data["name"],
		"text": lines[seed_value % lines.size()],
		"color": Color(data["color"] as String),
	}


func on_answered(correct: bool) -> void:
	perks.streak = perks.streak + 1 if correct else 0
	if perks.streak == AiPerks.CUPIDO_STREAK and team.can_speak("cupido"):
		_enqueue("cupido", "in_love")
	if not correct and team.can_speak("rencorosa"):
		_enqueue("rencorosa", "offended")
		team.muted["rencorosa"] = AiTeam.OFFENDED_MUTE_TIME
	say("right" if correct else "wrong")


## Fallar las dos preguntas enfada de verdad a una IA.
func on_all_wrong() -> void:
	var options: Array = team.speakers()
	if options.is_empty():
		return
	var id: String = options[level.rng.randi_range(0, options.size() - 1)]
	_enqueue(id, "offended")
	if team.offend(id, level.rng):
		ai_lost_forever.emit()


func on_piece_destroyed(_slot: ModularBody.Slot) -> void:
	say("piece_lost")


func on_piece_discarded() -> void:
	team.recharge_sleeping(level.rng)


func check_low_pieces() -> void:
	if not perks.mama_warns():
		return
	var body: ModularBody = level.player.body
	var low: bool = false
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = body.equipped(slot as ModularBody.Slot)
		if piece != null and piece.durability < LOW_PIECE_LEVEL:
			low = true
	if low and not _low_warned:
		_enqueue("mama", "low_piece")
	_low_warned = low


func pending() -> Array:
	return _queue


## El protagonista no gasta tokens y pasa delante de lo que esté en cola.
func enqueue_protagonist(text: String) -> void:
	_queue.push_front({"id": PROTAGONIST, "text": text})


## Para cuando el juego está en pausa y la cola no avanza.
func speak_protagonist_now(text: String) -> void:
	if not bubble.is_busy():
		_show_protagonist(text)


func _has_taunt(id: String) -> bool:
	return _has_line(id, TAUNT_EVENT)


func _has_line(id: String, event: String) -> bool:
	return (team.ais[id]["lines"] as Dictionary).has(event)


func _enqueue(id: String, event: String) -> void:
	var lines: Array = team.ais[id]["lines"].get(event, [])
	if not lines.is_empty():
		var text: String = lines[level.rng.randi_range(0, lines.size() - 1)]
		_queue.append({"id": id, "text": _with_mote(text, id, event)})


## Algunas frases llevan el mote escrito; otras, a veces, lo reciben delante.
func _with_mote(text: String, id: String, event: String) -> String:
	if text.contains(Nicknames.TOKEN):
		return nicknames.resolve(text, id, level.rng)
	if MOTE_EVENTS.has(event) and level.rng.randf() < MOTE_CHANCE:
		return "%s. %s" % [nicknames.pick(id, level.rng), text]
	return text


func _track_idle(delta: float) -> void:
	if level.player.velocity != Vector2.ZERO:
		_idle_time = 0.0
		return
	_idle_time += delta
	if _idle_time >= IDLE_TIME:
		_idle_time = 0.0
		say_chain(["idle_advice", "idle_insult", "idle_reproach"])


func _track_danger() -> void:
	if _danger_cooldown > 0.0 or not is_instance_valid(level.guard) or level.guard.is_down():
		return
	var guard: Guard = level.guard
	var distance: float = level.player.global_position.distance_to(guard.global_position)
	var close: bool = distance < PANIC_SENSE_RANGE
	if guard.detector.meter > 0.5 or (close and team.can_speak("panico")):
		_danger_cooldown = DANGER_COOLDOWN
		if close and team.can_speak("panico"):
			_enqueue("panico", "danger")
		else:
			say("danger")


func warn_rain() -> void:
	if perks.mama_warns():
		_enqueue("mama", "rain_warn")


func material_hint(text: String) -> String:
	if not team.can_speak("friki"):
		return ""
	return "Friki-Nexus 3000: «%s»" % (team.ais["friki"]["lines"]["material"][0] as String).format({"prop": text})


func on_hacked() -> void:
	if team.can_speak("burocrata"):
		_enqueue("burocrata", "hack")


func _track_perks(delta: float) -> void:
	level.player.still_stealth_factor = perks.still_stealth_factor()
	_hint_time -= delta
	if _hint_time <= 0.0:
		_hint_time = HINT_INTERVAL
		_give_hint()
	_decoy_time -= delta
	if _decoy_time <= 0.0 and team.can_speak("lumi"):
		_try_decoy()


func _give_hint() -> void:
	if team.can_speak("matriz") and route_hint.is_valid():
		var route: Dictionary = route_hint.call()
		if not route.is_empty():
			_enqueue_formatted("matriz", "route", route)
	if team.can_speak("conspi") and treason_hint.is_valid():
		_enqueue_formatted("conspi", "treason", {"raza": treason_hint.call()})


func _enqueue_formatted(id: String, event: String, values: Dictionary) -> void:
	var lines: Array = team.ais[id]["lines"][event]
	_queue.append({"id": id, "text": str(lines[level.rng.randi_range(0, lines.size() - 1)]).format(values)})


## Lumi crea un señuelo cuando alguien está a punto de verte.
func _try_decoy() -> void:
	for guard: Guard in level.guards():
		if not guard.is_down() and guard.detector.meter > 0.5:
			var away: Vector2 = guard.global_position.direction_to(level.player.global_position)
			var spot: Vector2 = guard.global_position - away.orthogonal() * DECOY_DISTANCE
			level.noise_bus.emit_noise(spot, DECOY_NOISE)
			_decoy_time = DECOY_INTERVAL
			_enqueue("lumi", "decoy")
			return


func _start_argument() -> void:
	for pair: Dictionary in team.pairs:
		if team.can_speak(pair["a"]) and team.can_speak(pair["b"]):
			for line: Array in pair["lines"]:
				_queue.append({"id": pair[line[0]], "text": line[1]})
			if pair.get("mutes", false):
				team.muted[pair["a"]] = ARGUMENT_MUTE
				team.muted[pair["b"]] = ARGUMENT_MUTE
			return


func _play_next() -> void:
	_line_time -= get_physics_process_delta_time()
	if bubble.is_busy() or _line_time > 0.0:
		return
	if _queue.is_empty():
		level.player.tail_speaking = false
		return
	var entry: Dictionary = _queue.pop_front()
	var id: String = entry["id"]
	if id == PROTAGONIST:
		_show_protagonist(entry["text"])
		return
	if not team.ais.has(id) or team.lost.has(id):
		return
	var info: Dictionary = team.ais[id]
	var color: Color = Color(info["color"] as String)
	var duration: float = 1.6 + float((entry["text"] as String).length()) * 0.045
	if chat != null:
		chat.add_message(id, entry["text"])
		_line_time = duration
	else:
		bubble.say("%s: %s" % [info["name"], entry["text"]], color, duration)
	voice.speak(float(info["pitch"]), id)
	level.player.tail_color = color
	level.player.tail_speaking = true
	team.spend(id, level.rng)
	if not team.active.has(id):
		ai_fell_asleep.emit()


func _show_protagonist(text: String) -> void:
	var duration: float = 1.6 + float(text.length()) * 0.045
	bubble.say("%s: %s" % [PROTAGONIST_NAME, text], PROTAGONIST_COLOR, duration)
	voice.speak(PROTAGONIST_PITCH)
	level.player.tail_speaking = false
