class_name InvestigationDirector
extends Node
## Caso investigable: pruebas, conversaciones, deducciones y consecuencias.
## El estado es interno: el jugador no ve ningún diario, conforme al diseño.

signal outcome_reached(result: String)
signal flags_changed

const CASE_PATH: String = "res://data/investigation/case_01.json"
const OUTCOMES: Array[String] = ["paz", "tregua", "guerra"]
const HEAR_RANGE: float = 380.0
const AMBIENT_LINE_TIME: float = 3.6
const OBSERVATION_RANGE: float = 200.0
## Tiempo provisional hasta que el conflicto estalla si nadie interviene.
const NEGLECT_LIMIT: float = 600.0
const TENSION_WARNING: float = 420.0
const ZONE_START_X: float = 1100.0
## Para quien no pertenece a una raza con datos, como las máquinas.
const COLOR_OTHER_RACE: Color = Color("#8fbf60")
const COLOR_EVIDENCE_NEAR: float = 1.0

var level: Sandbox
var case_path: String = CASE_PATH
var case_data: Dictionary = {}
var flags: Dictionary = {}
var neglect_time: float = 0.0
var zone_entered: bool = false
var current_node: String = ""
var answer_time_left: float = 0.0
var bar: ConversationBar
var bubbles: Dictionary = {}
var npc_nodes: Dictionary = {}

## Repeticiones por opción de diálogo: al agotarlas desaparece y salta la pelea.
var _option_uses: Dictionary = {}
var _option_limits: Dictionary = {}

var _ambient_index: int = 0
var _line_index: int = 0
var _line_time: float = 0.0
var _observed: Dictionary = {}
var _announced: bool = false
var _tension_warned: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(case_path))
	if not data is Dictionary:
		push_error("Datos ilegibles en %s" % case_path)
		return
	case_data = data
	bar = ConversationBar.new()
	add_child(bar)
	_build_world()


func _unhandled_input(event: InputEvent) -> void:
	if current_node.is_empty():
		return
	if event.is_action_pressed(&"close_panel") and not event.is_echo() and answer_time_left <= 0.0:
		_close()
		get_viewport().set_input_as_handled()
		return
	for index: int in range(ActionSystem.MAX_KEYS):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			choose(index)
			return


func _process(delta: float) -> void:
	_tick_answer_limit(delta)
	if get_tree().paused:
		return
	if level.player.global_position.x >= ZONE_START_X:
		zone_entered = true
	tick_ambient(delta)
	advance_neglect(delta)
	_observe_nearby()


func validate() -> Array[String]:
	var problems: Array[String] = []
	var npc_ids: Array = case_data["npcs"].map(func(npc: Dictionary) -> String: return npc["id"])
	var nodes: Dictionary = case_data["dialogue"]
	for npc: Dictionary in case_data["npcs"]:
		if not nodes.has(npc["dialogue"]):
			problems.append("npcs.%s.dialogue: no existe" % npc["id"])
	for id: String in nodes:
		if not npc_ids.has(nodes[id]["speaker"]):
			problems.append("dialogue.%s.speaker: no existe" % id)
		for option: Dictionary in nodes[id]["options"]:
			if not (option["next"] as String).is_empty() and not nodes.has(option["next"]):
				problems.append("dialogue.%s: destino %s no existe" % [id, option["next"]])
	return problems


func set_flag(flag: String) -> void:
	flags[flag] = true
	flags_changed.emit()


func clear_flag(flag: String) -> void:
	flags.erase(flag)


func has_flag(flag: String) -> bool:
	return flags.has(flag)


func is_resolved() -> bool:
	for result: String in OUTCOMES:
		if has_flag(result):
			return true
	return false


func examine(evidence_id: String) -> void:
	for evidence: Dictionary in case_data["evidence"]:
		if evidence["id"] == evidence_id:
			set_flag(evidence_id)
			level.ai.bubble.say(evidence["text"], Color.WHITE, 6.0)
			return


func open_dialogue(npc_id: String) -> void:
	for npc: Dictionary in case_data["npcs"]:
		if npc["id"] == npc_id:
			level.pause.begin_modal()
			_show_node(npc["dialogue"])
			return


func available_options(node_id: String) -> Array:
	var result: Array = []
	var options: Array = case_data["dialogue"][node_id]["options"]
	for index: int in range(options.size()):
		var option: Dictionary = options[index]
		if _option_exhausted(node_id, index):
			continue
		if _meets(option):
			result.append(option)
	return result


func _option_key(node_id: String, index: int) -> String:
	return "%s|%d" % [node_id, index]


func _option_exhausted(node_id: String, index: int) -> bool:
	var key: String = _option_key(node_id, index)
	if not _option_limits.has(key):
		return false
	return int(_option_uses.get(key, 0)) >= int(_option_limits[key])


func choose(index: int) -> void:
	if current_node.is_empty():
		return
	var options: Array = available_options(current_node)
	if index < 0 or index >= options.size():
		return
	var option: Dictionary = options[index]
	var original: int = _original_option_index(current_node, option)
	if original >= 0 and _register_option_use(current_node, original):
		_provoke_dialogue_fight()
		return
	if option.get("cost_piece", false):
		_pay_one_spare()
	for flag: String in option["sets"]:
		flags[flag] = true
	flags_changed.emit()
	_check_outcome()
	var next_node: String = option["next"]
	if next_node.is_empty():
		_close()
	else:
		_show_node(next_node)


func _original_option_index(node_id: String, option: Dictionary) -> int:
	var options: Array = case_data["dialogue"][node_id]["options"]
	for index: int in range(options.size()):
		if options[index] == option:
			return index
	return -1


func _register_option_use(node_id: String, index: int) -> bool:
	var key: String = _option_key(node_id, index)
	if not _option_limits.has(key):
		_option_limits[key] = level.rng.randi_range(2, 5)
	var uses: int = int(_option_uses.get(key, 0)) + 1
	_option_uses[key] = uses
	return uses >= int(_option_limits[key])


func _provoke_dialogue_fight() -> void:
	var speaker: String = case_data["dialogue"][current_node]["speaker"]
	_close()
	_attack_speaker(speaker)


func _attack_speaker(speaker: String) -> void:
	if level.has_method("attack_dialogue_speaker"):
		level.call("attack_dialogue_speaker", speaker)
		return
	if level.live_world != null and level.live_world.citizens.has(speaker):
		level.attack_citizen(level.live_world.citizens[speaker])


func tick_ambient(delta: float) -> void:
	_line_time -= delta
	if _line_time > 0.0:
		return
	_line_time = AMBIENT_LINE_TIME
	var groups: Array = case_data["ambient"].filter(_meets)
	if groups.is_empty():
		return
	_ambient_index = _ambient_index % groups.size()
	var lines: Array = groups[_ambient_index]["lines"]
	if _line_index >= lines.size():
		_line_index = 0
		_ambient_index = (_ambient_index + 1) % groups.size()
		lines = groups[_ambient_index]["lines"]
	var line: Array = lines[_line_index]
	_line_index += 1
	_speak_ambient(line[0], line[1])


func advance_neglect(delta: float) -> void:
	if is_resolved() or not zone_entered:
		return
	neglect_time += delta
	if neglect_time >= TENSION_WARNING and not _tension_warned:
		_tension_warned = true
		level.show_notice(tr("CASE_TENSION"))
	if neglect_time >= NEGLECT_LIMIT:
		flags["guerra"] = true
		_check_outcome()


func to_dict() -> Dictionary:
	return {"flags": flags.keys(), "neglect": neglect_time, "zone": zone_entered}


func restore(data: Dictionary) -> void:
	flags.clear()
	for flag: Variant in data.get("flags", []):
		flags[flag] = true
	neglect_time = float(data.get("neglect", 0.0))
	zone_entered = bool(data.get("zone", false))
	_announced = is_resolved()
	_apply_outcome_look()


func _meets(entry: Dictionary) -> bool:
	for flag: String in entry.get("requires", []):
		if not has_flag(flag):
			return false
	for flag: String in entry.get("forbids", []):
		if has_flag(flag):
			return false
	return not entry.get("cost_piece", false) or _has_spare()


func _has_spare() -> bool:
	for slot: int in ModularBody.Slot.values():
		if not level.player.body.spares(slot as ModularBody.Slot).is_empty():
			return true
	return false


func _pay_one_spare() -> void:
	for slot: int in ModularBody.Slot.values():
		if not level.player.body.spares(slot as ModularBody.Slot).is_empty():
			level.player.body.discard_spare(slot as ModularBody.Slot, 0)
			return


## En un encuentro tenso, callar también es responder: se elige la última opción.
func _tick_answer_limit(delta: float) -> void:
	if answer_time_left <= 0.0:
		return
	answer_time_left -= delta
	if answer_time_left <= 0.0 and not current_node.is_empty():
		choose(available_options(current_node).size() - 1)


## Devuelve 0 si la conversación no tiene límite de tiempo.
func _roll_answer_limit(node: Dictionary) -> float:
	if not node.has("limit"):
		return 0.0
	var limits: Array = node["limit"]
	return level.rng.randf_range(float(limits[0]), float(limits[1]))


func _show_node(node_id: String) -> void:
	current_node = node_id
	var node: Dictionary = case_data["dialogue"][node_id]
	answer_time_left = _roll_answer_limit(node)
	if answer_time_left > 0.0:
		level.show_notice(tr("UI_ANSWER_NOW"))
	var text: String = level.ai.nicknames.resolve(node["text"], node["speaker"], level.rng)
	_bubble_for(node["speaker"]).say(text, Color.BLACK, 3600.0)
	var entries: Array = []
	var options: Array = available_options(node_id)
	for index: int in range(options.size()):
		entries.append([options[index]["text"], choose.bind(index)])
	bar.show_options(entries)


func _close() -> void:
	var speaker: String = case_data["dialogue"][current_node]["speaker"]
	_bubble_for(speaker).clear()
	current_node = ""
	answer_time_left = 0.0
	bar.clear()
	level.pause.end_modal()


func _bubble_for(npc_id: String) -> SpeechBubble:
	return bubbles[npc_id]


func _speak_ambient(npc_id: String, text: String) -> void:
	var npc: Node2D = npc_nodes[npc_id]
	if is_instance_valid(npc) and level.player.global_position.distance_to(npc.global_position) <= HEAR_RANGE:
		_bubble_for(npc_id).say(text, Color.BLACK, AMBIENT_LINE_TIME - 0.3)


func _observe_nearby() -> void:
	for evidence: Dictionary in case_data["evidence"]:
		var id: String = evidence["id"]
		if _observed.has(id) or has_flag(id):
			continue
		var at: Array = evidence["pos"]
		var point: Vector2 = Vector2(float(at[0]), float(at[1]))
		if level.player.global_position.distance_to(point) <= OBSERVATION_RANGE:
			_observed[id] = true
			level.ai.say_custom(evidence["observation"])


func _check_outcome() -> void:
	for result: String in OUTCOMES:
		if has_flag(result):
			_apply_outcome_look()
			if not _announced:
				_announced = true
				level.show_notice(tr("CASE_OUTCOME_%s" % result))
			outcome_reached.emit(result)
			if level.fight.phase == FightDirector.Phase.CALM and current_node.is_empty():
				level.autosave()
			return


func _apply_outcome_look() -> void:
	var tint: Color = Color.WHITE
	if has_flag("guerra"):
		tint = Color(1.0, 0.45, 0.45)
	elif has_flag("paz") or has_flag("tregua"):
		tint = Color(0.75, 1.0, 0.8)
	for npc_id: String in npc_nodes:
		if is_instance_valid(npc_nodes[npc_id]):
			(npc_nodes[npc_id] as Node2D).modulate = tint


func _build_world() -> void:
	for npc: Dictionary in case_data["npcs"]:
		var race: String = npc["race"]
		var color: Color = SpeciesCatalog.color(race) if SpeciesCatalog.has(race) else COLOR_OTHER_RACE
		var item: Interactable = _spawn(npc, Interactable.Kind.NPC, color)
		npc_nodes[npc["id"]] = item
		var bubble: SpeechBubble = SpeechBubble.new()
		bubble.position = Vector2(0.0, -60.0)
		bubble.visible = false
		item.add_child(bubble)
		bubbles[npc["id"]] = bubble
	for evidence: Dictionary in case_data["evidence"]:
		_spawn(evidence, Interactable.Kind.EVIDENCE, Color.TRANSPARENT)


func _spawn(entry: Dictionary, kind: Interactable.Kind, color: Color) -> Interactable:
	var item: Interactable = Interactable.new()
	var at: Array = entry["pos"]
	item.setup(entry["id"], kind, Vector2(float(at[0]), float(at[1])))
	item.custom_label = entry["name"]
	item.custom_color = color
	item.reusable = true
	item.activated.connect(level.on_item_activated)
	level.actors.add_child(item)
	return item
