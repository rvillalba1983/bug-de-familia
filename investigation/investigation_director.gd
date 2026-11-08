class_name InvestigationDirector
extends Node
## Caso investigable: pruebas, conversaciones, deducciones y consecuencias.
## El estado es interno: el jugador no ve ningún diario, conforme al diseño.

signal outcome_reached(result: String)

const CASE_PATH: String = "res://data/investigation/case_01.json"
const OUTCOMES: Array[String] = ["paz", "tregua", "guerra"]
const HEAR_RANGE: float = 380.0
const AMBIENT_LINE_TIME: float = 3.6
const OBSERVATION_RANGE: float = 200.0
## Tiempo provisional hasta que el conflicto estalla si nadie interviene.
const NEGLECT_LIMIT: float = 300.0
const COLOR_MOHOCRATA: Color = Color("#8fbf60")
const COLOR_JUBILADO: Color = Color("#a0a8b8")
const COLOR_EVIDENCE_NEAR: float = 1.0

var level: Sandbox
var case_data: Dictionary = {}
var flags: Dictionary = {}
var neglect_time: float = 0.0
var current_node: String = ""
var bar: ConversationBar
var bubbles: Dictionary = {}
var npc_nodes: Dictionary = {}

var _ambient_index: int = 0
var _line_index: int = 0
var _line_time: float = 0.0
var _observed: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CASE_PATH))
	if not data is Dictionary:
		push_error("Datos ilegibles en %s" % CASE_PATH)
		return
	case_data = data
	bar = ConversationBar.new()
	add_child(bar)
	_build_world()


func _unhandled_input(event: InputEvent) -> void:
	if current_node.is_empty():
		return
	for index: int in range(ActionSystem.MAX_KEYS):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			choose(index)
			return


func _process(delta: float) -> void:
	if get_tree().paused:
		return
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
			flags[evidence_id] = true
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
	for option: Dictionary in case_data["dialogue"][node_id]["options"]:
		if _meets(option):
			result.append(option)
	return result


func choose(index: int) -> void:
	if current_node.is_empty():
		return
	var options: Array = available_options(current_node)
	if index < 0 or index >= options.size():
		return
	var option: Dictionary = options[index]
	for flag: String in option["sets"]:
		flags[flag] = true
	_check_outcome()
	var next_node: String = option["next"]
	if next_node.is_empty():
		_close()
	else:
		_show_node(next_node)


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
	if is_resolved():
		return
	neglect_time += delta
	if neglect_time >= NEGLECT_LIMIT:
		flags["guerra"] = true
		_check_outcome()


func to_dict() -> Dictionary:
	return {"flags": flags.keys(), "neglect": neglect_time}


func restore(data: Dictionary) -> void:
	flags.clear()
	for flag: Variant in data.get("flags", []):
		flags[flag] = true
	neglect_time = float(data.get("neglect", 0.0))
	_apply_outcome_look()


func _meets(entry: Dictionary) -> bool:
	for flag: String in entry.get("requires", []):
		if not has_flag(flag):
			return false
	for flag: String in entry.get("forbids", []):
		if has_flag(flag):
			return false
	return true


func _show_node(node_id: String) -> void:
	current_node = node_id
	var node: Dictionary = case_data["dialogue"][node_id]
	_bubble_for(node["speaker"]).say(node["text"], Color.BLACK, 3600.0)
	var entries: Array = []
	var options: Array = available_options(node_id)
	for index: int in range(options.size()):
		entries.append([options[index]["text"], choose.bind(index)])
	bar.show_options(entries)


func _close() -> void:
	var speaker: String = case_data["dialogue"][current_node]["speaker"]
	_bubble_for(speaker).clear()
	current_node = ""
	bar.clear()
	level.pause.end_modal()


func _bubble_for(npc_id: String) -> SpeechBubble:
	return bubbles[npc_id]


func _speak_ambient(npc_id: String, text: String) -> void:
	var npc: Node2D = npc_nodes[npc_id]
	if level.player.global_position.distance_to(npc.global_position) <= HEAR_RANGE:
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
		(npc_nodes[npc_id] as Node2D).modulate = tint


func _build_world() -> void:
	for npc: Dictionary in case_data["npcs"]:
		var color: Color = COLOR_JUBILADO if npc["race"] == "jubilado" else COLOR_MOHOCRATA
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
	item.activated.connect(level._on_item_activated)
	level.actors.add_child(item)
	return item
