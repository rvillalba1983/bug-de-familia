class_name LiveDialogue
extends Node
## Conversación contextual con un habitante: las opciones salen de su estado.

const REFUSE_STANDING: float = -12.0
const INSULT_STANDING: float = -4.0
const PRAISE_STANDING: float = 1.0
const BADMOUTH_ANGER: float = 15.0
const BADMOUTH_RELATION: float = -6.0
const PROVOCATIONS_NEEDED: int = 3

var world: LiveWorld
var npc: NpcState
var bar: ConversationBar

var _options: Array = []
var _insulted: bool = false
var _branch: String = ""
var _option_uses: Dictionary = {}
var _option_limits: Dictionary = {}
var _dialogue_tree: Dictionary = {}
var _conversation: Dictionary = {}
var _conversation_nodes: Dictionary = {}
var _current_node_id: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bar = ConversationBar.new()
	add_child(bar)


func _unhandled_input(event: InputEvent) -> void:
	if npc == null:
		return
	if event.is_action_pressed(&"close_panel") and not event.is_echo():
		close()
		get_viewport().set_input_as_handled()
		return
	for index: int in range(_options.size()):
		if event.is_action_pressed(StringName("action_%d" % (index + 1))):
			(_options[index][1] as Callable).call()
			return


func is_open() -> bool:
	return npc != null


func open(target: NpcState) -> void:
	npc = target
	_insulted = false
	_branch = ""
	_current_node_id = ""
	_dialogue_tree = DialogueTrees.tree_for(npc.species)
	_conversation = ConversationCatalog.pick(npc.species, npc.id + npc.role)
	_conversation_nodes = (_conversation.get("nodes", {}) as Dictionary) if not _conversation.is_empty() else {}
	world.level.pause.begin_modal()
	## P-32: hablar con un NPC descubre los retos de la zona.
	world.level.discover_challenge()
	if float(world.sim.player_standing.get(npc.species, 0.0)) <= REFUSE_STANDING:
		_say(tr("LIVE_REFUSE"))
		_set_options([[tr("LIVE_HIT"), _hit], [tr("LIVE_BYE"), close]])
		return
	_say(_greeting(npc))
	_refresh()


## Saludo según el oficio del habitante. Sin línea de rol, el saludo normal.
func _greeting(who: NpcState) -> String:
	var info: Dictionary = world.sim.species_data.get(who.species, {})
	var por_rol: Dictionary = info.get("role_lines", {})
	var lines: Array = por_rol.get(who.role, [])
	if lines.is_empty():
		return _random_line(who, "greet")
	return lines[absi((who.id + who.role + str(who.memories.size())).hash()) % lines.size()]


func options() -> Array:
	return _options


func choose(index: int) -> void:
	(_options[index][1] as Callable).call()


func _option_key(label: String) -> String:
	return "%s|%s" % [npc.id, label]


func _option_exhausted(label: String) -> bool:
	var key: String = _option_key(label)
	if not _option_limits.has(key):
		return false
	return int(_option_uses.get(key, 0)) >= int(_option_limits[key])


func _register_option_use(label: String) -> bool:
	var key: String = _option_key(label)
	if not _option_limits.has(key):
		_option_limits[key] = world.sim.rng.randi_range(2, 5)
	var uses: int = int(_option_uses.get(key, 0)) + 1
	_option_uses[key] = uses
	return uses >= int(_option_limits[key])


func _wrap_option(label: String, action: Callable) -> Array:
	return [label, func() -> void:
		if _register_option_use(label):
			_exhaust_option()
			return
		action.call()
	]


func _exhaust_option() -> void:
	## Al agotar las repeticiones salta enfado y pelea de inmediato.
	if world.citizens.has(npc.id):
		_hit()
	else:
		close()


func close() -> void:
	if npc == null:
		return
	world.bubble_of(npc.id).clear()
	npc = null
	_options = []
	_conversation = {}
	_conversation_nodes = {}
	bar.clear()
	world.level.pause.end_modal()


func _refresh() -> void:
	if _current_node_id != "":
		_show_dialogue_node(_current_node_id)
		return
	if _branch == "news":
		var entries: Array = []
		if _latest_belief() >= 0:
			entries.append([tr("LIVE_ASK_SOURCE"), _ask_source])
		entries.append([tr("LIVE_ASK_LORE"), _ask_lore])
		entries.append(["Volver", _back_to_root])
		entries.append([tr("LIVE_BYE"), close])
		_set_options(entries)
		return
	var entries: Array = [[tr("LIVE_ASK_NEWS"), _ask_news]]
	if _latest_belief() >= 0:
		entries.append([tr("LIVE_ASK_SOURCE"), _ask_source])
	entries.append([tr("LIVE_ASK_LORE"), _ask_lore])
	if not _dialogue_tree.is_empty():
		entries.append(["Hablar", _enter_dialogue])
	if not _conversation_nodes.is_empty():
		entries.append(["Te cuento algo", _enter_conversation])
	entries.append_array(world.extra_options(npc))
	entries.append([tr("LIVE_BADMOUTH") % SpeciesCatalog.plural(SpeciesCatalog.rival(npc.species)), _badmouth])
	entries.append([tr("LIVE_PRAISE"), _praise])
	entries.append([tr("LIVE_HIT"), _hit] if _insulted else [tr("LIVE_INSULT"), _insult])
	entries.append([tr("LIVE_BYE"), close])
	_set_options(entries)


func _enter_dialogue() -> void:
	_current_node_id = "root"
	_show_dialogue_node("root")


func _enter_conversation() -> void:
	_current_node_id = "conv_root"
	_show_dialogue_node("conv_root")


func _show_dialogue_node(node_id: String) -> void:
	var tree: Dictionary = _dialogue_tree
	if node_id.begins_with("conv_"):
		tree = _conversation_nodes
	var real_id: String = node_id.trim_prefix("conv_")
	if not tree.has(real_id):
		_current_node_id = ""
		_refresh()
		return
	var node: Dictionary = tree[real_id]
	_current_node_id = node_id
	_say(str(node.get("text", "...")))
	var entries: Array = []
	for opt: Dictionary in node.get("options", []):
		var label: String = str(opt.get("label", "..."))
		var next: String = str(opt.get("next", ""))
		if not next.is_empty() and node_id.begins_with("conv_"):
			next = "conv_" + next
		var action: String = str(opt.get("action", ""))
		entries.append([label, func() -> void:
			_execute_dialogue_action(action)
			if next == "":
				_current_node_id = ""
				_refresh()
			else:
				_show_dialogue_node(next)
		])
	entries.append(["Volver", func() -> void:
		_current_node_id = ""
		_refresh()
	])
	_set_options(entries)


func _execute_dialogue_action(action: String) -> void:
	match action:
		"gift_piece":
			_give_piece()
		"hit":
			_hit()
		"provoke_battle":
			world.provoke_battle(tr("LIVE_BADMOUTH_BOOM"))
		"praise":
			_praise()
		"insult":
			_insult()


func _give_piece() -> void:
	## Regala una pieza al protagonista. Simplificado: muestra mensaje.
	_say("Toma, una pieza para ti.")
	if world.level.has_method("give_piece_to_player"):
		world.level.give_piece_to_player()


func _set_options(entries: Array) -> void:
	var filtered: Array = []
	for entry: Array in entries:
		var label: String = str(entry[0])
		if _option_exhausted(label):
			continue
		filtered.append(_wrap_option(label, entry[1] as Callable))
	_options = filtered
	bar.show_options(filtered)


func _say(text: String) -> void:
	world.bubble_of(npc.id).say(text, Color.BLACK, 3600.0)


## Permite a otros sistemas responder y seguir la conversación.
func reply(text: String) -> void:
	_branch = ""
	_say(text)
	_refresh()


func _random_line(who: NpcState, key: String) -> String:
	var info: Dictionary = world.sim.species_data.get(who.species, {})
	var lines: Array = info.get(key, info.get("angry", ["..."]))
	if lines.is_empty():
		return "..."
	return lines[absi((who.id + key + str(who.memories.size())).hash()) % lines.size()]


func _latest_belief() -> int:
	var best: int = -1
	for key: String in npc.beliefs:
		best = maxi(best, key.to_int())
	return best


func _ask_news() -> void:
	var id: int = _latest_belief()
	if id < 0:
		_branch = ""
		reply(_random_line(npc, "nothing"))
		return
	var text: String = world.sim.rumors.phrase(world.sim, npc.beliefs[str(id)])
	_branch = "news"
	_say("%s %s" % [_random_line(npc, "opener"), text])
	_refresh()


func _back_to_root() -> void:
	_branch = ""
	_refresh()


func _ask_source() -> void:
	var belief: Dictionary = npc.beliefs[str(_latest_belief())]
	if bool(belief["direct"]):
		reply(tr("LIVE_SOURCE_SELF"))
	elif str(belief["source"]).is_empty():
		reply(tr("LIVE_SOURCE_NONE"))
	else:
		reply(tr("LIVE_SOURCE_NAME") % (world.sim.npcs[belief["source"]] as NpcState).name)


func _ask_lore() -> void:
	if npc.lore.is_empty():
		reply(_random_line(npc, "nothing"))
		return
	var facts: Array = world.sim.species_data[npc.species]["lore"]
	reply(facts[int(npc.lore[0])]["text"])


func _praise() -> void:
	npc.feel("alegria", 20.0)
	npc.relate(WorldSim.PLAYER_ID, "afecto", 10.0)
	world.sim.change_standing(npc.species, PRAISE_STANDING)
	reply(_random_line(npc, "praised"))


## Cierra la charla y va a por él. El resto lo decide el combate de siempre.
func _hit() -> void:
	var guard: Guard = world.citizens[npc.id]
	close()
	world.level.attack_citizen(guard)


## Malmeter de la otra raza: a la tercera vez estalla la batalla.
func _badmouth() -> void:
	npc.feel("ira", BADMOUTH_ANGER)
	world.sim.change_species_relation(BADMOUTH_RELATION)
	world.provocations += 1
	if world.provocations >= PROVOCATIONS_NEEDED:
		world.provocations = 0
		world.provoke_battle(tr("LIVE_BADMOUTH_BOOM"))
		return
	reply(tr("LIVE_BADMOUTH_%d" % world.provocations))


func _insult() -> void:
	_insulted = true
	npc.feel("ira", 35.0)
	npc.relate(WorldSim.PLAYER_ID, "afecto", -20.0)
	world.sim.change_standing(npc.species, INSULT_STANDING)
	reply(_random_line(npc, "angry"))
