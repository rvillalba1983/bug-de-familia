class_name ConversionDirector
extends Node2D
## Dirige el flujo: elegir objeto, objetivo, ranura, preguntas y resultado.

signal converted(entity_id: String)

enum Step { IDLE, TARGETING, OBJECTIVE, SLOT, QUESTION, FEEDBACK, RESULT }

const FEEDBACK_TIME: float = 1.4

var step: Step = Step.IDLE
var catalog: ConversionCatalog
var player: Player
var pause: TacticalPause
var rng: RandomNumberGenerator
var screen: ConversionScreen
var hint: Label

var _target: Convertible
var _objective_id: String = ""
var _slot: ModularBody.Slot = ModularBody.Slot.HEAD
var _session: ConversionSession
var _time_left: float = 0.0
var _feedback_left: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"convert") and not event.is_echo():
		if step == Step.IDLE and not get_tree().paused and not player.body.is_dead:
			_enter_targeting()
		elif step == Step.TARGETING:
			cancel_targeting()
	elif step == Step.TARGETING and event.is_action_pressed(&"select"):
		get_viewport().set_input_as_handled()
		try_target(get_global_mouse_position())
	elif step == Step.QUESTION:
		_read_answer_keys(event)


func _process(delta: float) -> void:
	tick(delta)


func tick(delta: float) -> void:
	match step:
		Step.TARGETING:
			_update_highlights(true)
		Step.QUESTION:
			_time_left -= delta
			screen.set_time_fraction(_time_left / ConversionSession.TIME_LIMIT)
			if _time_left <= 0.0:
				answer_current(-1)
		Step.FEEDBACK:
			_feedback_left -= delta
			if _feedback_left <= 0.0:
				_next_question_or_result()


func begin_on(target: Convertible) -> void:
	_update_highlights(false)
	_target = target
	if not _any_room():
		step = Step.IDLE
		hint.text = tr("UI_CONVERT_NO_ROOM")
		hint.visible = true
		return
	hint.visible = false
	pause.begin_modal()
	step = Step.OBJECTIVE
	var entries: Array = []
	for id: String in catalog.objectives:
		entries.append([str(catalog.objectives[id]["name"]), choose_objective.bind(id)])
	screen.show_choices(tr("UI_CONVERT_OBJECTIVE"), entries)


func try_target(point: Vector2) -> void:
	for node: Node in get_tree().get_nodes_in_group(Convertible.GROUP):
		var candidate: Convertible = node as Convertible
		if candidate.contains_point(point) and _in_range(candidate):
			begin_on(candidate)
			return


func cancel_targeting() -> void:
	_update_highlights(false)
	hint.visible = false
	step = Step.IDLE


func choose_objective(id: String) -> void:
	_objective_id = id
	step = Step.SLOT
	var entries: Array = []
	for slot: int in ModularBody.Slot.values():
		if player.body.has_room(slot as ModularBody.Slot):
			entries.append([tr("SLOT_%d" % slot), choose_slot.bind(slot)])
	screen.show_choices(tr("UI_CONVERT_SLOT"), entries)


func choose_slot(slot: int) -> void:
	_slot = slot as ModularBody.Slot
	_session = ConversionSession.new(catalog.questions, rng)
	_show_question()


func answer_current(option: int) -> void:
	if step != Step.QUESTION:
		return
	var question: Dictionary = _session.current()
	var correct: bool = _session.answer(option, _time_left)
	var truth: String = str(question["options"][int(question["answer"])])
	var verdict: String = tr("UI_CONVERT_CORRECT" if correct else "UI_CONVERT_WRONG")
	screen.show_message(verdict, "%s %s" % [tr("UI_CONVERT_TRUTH"), truth])
	step = Step.FEEDBACK
	_feedback_left = FEEDBACK_TIME


func confirm_result() -> void:
	if step != Step.RESULT:
		return
	step = Step.IDLE
	screen.close()
	pause.end_modal()
	converted.emit(_target.entity_id)
	_target = null


func _enter_targeting() -> void:
	step = Step.TARGETING
	hint.text = tr("UI_CONVERT_TARGET")
	hint.visible = true


func _in_range(candidate: Convertible) -> bool:
	return player.global_position.distance_to(candidate.global_position) <= Convertible.RANGE


func _update_highlights(active: bool) -> void:
	for node: Node in get_tree().get_nodes_in_group(Convertible.GROUP):
		var candidate: Convertible = node as Convertible
		candidate.set_highlight(active, _in_range(candidate))


func _any_room() -> bool:
	for slot: int in ModularBody.Slot.values():
		if player.body.has_room(slot as ModularBody.Slot):
			return true
	return false


func _show_question() -> void:
	step = Step.QUESTION
	_time_left = ConversionSession.TIME_LIMIT
	var question: Dictionary = _session.current()
	var entries: Array = []
	var options: Array = question["options"]
	for index: int in range(options.size()):
		entries.append(["%d. %s" % [index + 1, options[index]], answer_current.bind(index)])
	screen.show_choices(str(question["text"]), entries, true)


func _read_answer_keys(event: InputEvent) -> void:
	var count: int = (_session.current()["options"] as Array).size()
	for index: int in range(count):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			answer_current(index)
			return


func _next_question_or_result() -> void:
	if not _session.is_finished():
		_show_question()
		return
	var kind: BodyPiece.Kind = ModularBody.kind_of(_slot)
	var piece: BodyPiece = PieceForge.forge(
		catalog, _target.material_id, _objective_id, kind, _session.score(), rng
	)
	player.body.receive(_slot, piece)
	step = Step.RESULT
	screen.show_message(tr("UI_CONVERT_RESULT"), piece.label)
	screen.add_accept(tr("UI_CONVERT_ACCEPT"), confirm_result)
