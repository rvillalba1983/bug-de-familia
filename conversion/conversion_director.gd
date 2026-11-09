class_name ConversionDirector
extends Node2D
## Dirige el flujo: elegir objeto, objetivo, ranura, preguntas y resultado.

signal converted(entity_id: String)
signal answered(correct: bool)
## Se emite al terminar las preguntas con todas falladas.
signal all_wrong

enum Step { IDLE, OBJECTIVE, SLOT, QUESTION, FEEDBACK, RESULT }

const FEEDBACK_TIME: float = 1.4
const HINT_TIME: float = 2.5
const FOCUS_OFFSET: Vector2 = Vector2(0.0, -20.0)

var step: Step = Step.IDLE
var catalog: ConversionCatalog
var player: Player
var pause: TacticalPause
var rng: RandomNumberGenerator
var screen: ConversionScreen
var hint: Label
## Recibe la pregunta y devuelve { "text": String, "disabled": int }.
var perks: AiPerks
var material_hinter: Callable = Callable()
var advisor: Callable = Callable()
## Recibe la pregunta y devuelve { "name": String, "text": String, "color": Color }.
var taunter: Callable = Callable()

var _target: Convertible
var _highlighted: Convertible
var _hint_left: float = 0.0
var _objective_id: String = ""
var _slot: ModularBody.Slot = ModularBody.Slot.HEAD
var _session: ConversionSession
var _time_total: float = ConversionSession.TIME_LIMIT
var _time_left: float = 0.0
var _feedback_left: float = 0.0
var _correct_count: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"close_panel") and not event.is_echo():
		_on_close_key()
	elif event.is_action_pressed(&"convert") and not event.is_echo():
		if step == Step.IDLE and not get_tree().paused and not player.body.is_dead:
			convert_nearest()
	elif step == Step.QUESTION:
		_read_answer_keys(event)


func _process(delta: float) -> void:
	tick(delta)


func tick(delta: float) -> void:
	if _hint_left > 0.0:
		_hint_left -= delta
		hint.visible = _hint_left > 0.0
	match step:
		Step.IDLE:
			_refresh_highlight()
		Step.QUESTION:
			_time_left -= delta
			screen.set_time_fraction(_time_left / _time_total)
			if _time_left <= 0.0:
				answer_current(-1)
		Step.FEEDBACK:
			_feedback_left -= delta
			if _feedback_left <= 0.0:
				_next_question_or_result()


## Convierte lo más cercano al alcance. Devuelve si había algo que convertir.
func convert_nearest() -> bool:
	var target: Convertible = _nearest_in_range()
	if target == null:
		_flash_hint(tr("UI_CONVERT_NONE"))
		return false
	begin_on(target)
	return true


func begin_on(target: Convertible) -> void:
	_set_highlighted(null)
	_target = target
	if not _any_room():
		step = Step.IDLE
		_flash_hint(tr("UI_CONVERT_NO_ROOM"))
		return
	_hint_left = 0.0
	hint.visible = false
	pause.begin_modal()
	screen.begin(target.get_global_transform_with_canvas().origin + FOCUS_OFFSET)
	step = Step.OBJECTIVE
	var entries: Array = []
	for id: String in catalog.objectives:
		if not _free_slots(id).is_empty():
			entries.append([str(catalog.objectives[id]["name"]), choose_objective.bind(id)])
	screen.show_choices(tr("UI_CONVERT_OBJECTIVE"), entries)
	screen.show_inventory(_inventory_rows())
	_show_material_hint()


func choose_objective(id: String) -> void:
	_objective_id = id
	step = Step.SLOT
	var entries: Array = []
	for slot: int in _free_slots(id):
		entries.append([tr("SLOT_%d" % slot), choose_slot.bind(slot)])
	screen.show_choices(tr("UI_CONVERT_SLOT"), entries)
	screen.show_inventory(_inventory_rows())


func choose_slot(slot: int) -> void:
	_slot = slot as ModularBody.Slot
	_session = ConversionSession.new(catalog.questions, rng)
	_correct_count = 0
	_show_question()


func answer_current(option: int) -> void:
	if step != Step.QUESTION:
		return
	var question: Dictionary = _session.current()
	var correct: bool = _session.answer(option, _time_left)
	_correct_count += 1 if correct else 0
	answered.emit(correct)
	var truth: String = str(question["options"][int(question["answer"])])
	var verdict: String = tr("UI_CONVERT_CORRECT" if correct else "UI_CONVERT_WRONG")
	screen.show_verdict(correct, verdict, "%s %s" % [tr("UI_CONVERT_TRUTH"), truth])
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


## Esc sale antes de las preguntas y acepta el resultado. Con el reloj en marcha no hay salida.
func _on_close_key() -> void:
	match step:
		Step.OBJECTIVE, Step.SLOT:
			step = Step.IDLE
			screen.close()
			pause.end_modal()
			_target = null
			get_viewport().set_input_as_handled()
		Step.RESULT:
			confirm_result()
			get_viewport().set_input_as_handled()


func _flash_hint(text: String) -> void:
	hint.text = text
	hint.visible = true
	_hint_left = HINT_TIME


func _nearest_in_range() -> Convertible:
	var best: Convertible = null
	var best_distance: float = Convertible.RANGE
	for node: Node in get_tree().get_nodes_in_group(Convertible.GROUP):
		var candidate: Convertible = node as Convertible
		var distance: float = player.global_position.distance_to(candidate.global_position)
		if distance <= best_distance:
			best = candidate
			best_distance = distance
	return best


## Marca en el mundo lo que convertiría Q ahora mismo.
func _refresh_highlight() -> void:
	var active: bool = not get_tree().paused and not player.body.is_dead
	_set_highlighted(_nearest_in_range() if active else null)


func _set_highlighted(candidate: Convertible) -> void:
	if candidate == _highlighted:
		return
	if is_instance_valid(_highlighted):
		_highlighted.set_highlight(false)
	_highlighted = candidate
	if candidate != null:
		candidate.set_highlight(true)


## Ranuras con sitio donde cabe este objetivo.
func _free_slots(objective_id: String) -> Array[int]:
	var kinds: Array = catalog.objectives[objective_id].get("slots", ["head", "arm", "leg"])
	var result: Array[int] = []
	for slot: int in ModularBody.Slot.values():
		var kind: String = ["head", "arm", "leg"][ModularBody.kind_of(slot as ModularBody.Slot)]
		if kinds.has(kind) and player.body.has_room(slot as ModularBody.Slot):
			result.append(slot)
	return result


## Qué llevas y qué te queda en cada zona del cuerpo, para decidir sin cambiar de vista.
func _inventory_rows() -> Array:
	var rows: Array = []
	for slot: int in ModularBody.Slot.values():
		var piece: BodyPiece = player.body.equipped(slot as ModularBody.Slot)
		var state: String = "ROTA"
		if piece != null:
			state = "básica" if piece.label.is_empty() else "nivel %d" % piece.level
		rows.append({
			"name": tr("SLOT_%d" % slot), "state": state,
			"spares": player.body.spares(slot as ModularBody.Slot).size(),
		})
	return rows


func _any_room() -> bool:
	for slot: int in ModularBody.Slot.values():
		if player.body.has_room(slot as ModularBody.Slot):
			return true
	return false


func _show_question() -> void:
	step = Step.QUESTION
	_time_total = ConversionSession.TIME_LIMIT if perks == null else perks.question_time()
	_time_left = _time_total
	screen.time_shown = _time_total
	var question: Dictionary = _session.current()
	var entries: Array = []
	var options: Array = question["options"]
	for index: int in range(options.size()):
		entries.append(["%d. %s" % [index + 1, options[index]], answer_current.bind(index)])
	screen.show_choices(str(question["text"]), entries, true)
	if advisor.is_valid():
		var advice: Dictionary = advisor.call(question)
		if not advice.is_empty():
			screen.add_remark(advice["text"], advice["disabled"])
	if taunter.is_valid():
		var taunt: Dictionary = taunter.call(question)
		if not taunt.is_empty():
			screen.show_taunt(taunt["name"], taunt["text"], taunt["color"])


func _final_score() -> float:
	return _session.score() if perks == null else perks.forge_score(_session.score(), _target, _correct_count)


func _show_material_hint() -> void:
	if not material_hinter.is_valid():
		return
	var ids: Array = catalog.materials[_target.effective_material()]["properties"]
	var remark: String = material_hinter.call(str(catalog.properties[ids[rng.randi_range(0, ids.size() - 1)]]["name"]))
	if not remark.is_empty():
		screen.add_remark(remark, -1)


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
	if _correct_count == 0:
		all_wrong.emit()
	var kind: BodyPiece.Kind = ModularBody.kind_of(_slot)
	var piece: BodyPiece = PieceForge.forge(
		catalog, _target.effective_material(), _objective_id, kind, _final_score(), rng, _target.fixed_property
	)
	player.body.receive(_slot, piece)
	step = Step.RESULT
	screen.show_message(tr("UI_CONVERT_RESULT"), "%s\n\n%s" % [piece.label, piece.description])
	screen.add_accept(tr("UI_CONVERT_ACCEPT"), confirm_result)
