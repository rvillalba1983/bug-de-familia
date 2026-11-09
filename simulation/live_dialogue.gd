class_name LiveDialogue
extends Node
## Conversación contextual con un habitante: las opciones salen de su estado.

const REFUSE_STANDING: float = -12.0
const INSULT_STANDING: float = -4.0
const PRAISE_STANDING: float = 1.0

var world: LiveWorld
var npc: NpcState
var bar: ConversationBar

var _options: Array = []
var _insulted: bool = false


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
	world.level.pause.begin_modal()
	if float(world.sim.player_standing.get(npc.species, 0.0)) <= REFUSE_STANDING:
		_say(tr("LIVE_REFUSE"))
		_set_options([[tr("LIVE_HIT"), _hit], [tr("LIVE_BYE"), close]])
		return
	_say(_random_line("greet"))
	_refresh()


func options() -> Array:
	return _options


func choose(index: int) -> void:
	(_options[index][1] as Callable).call()


func close() -> void:
	if npc == null:
		return
	world.bubble_of(npc.id).clear()
	npc = null
	_options = []
	bar.clear()
	world.level.pause.end_modal()


func _refresh() -> void:
	var entries: Array = [[tr("LIVE_ASK_NEWS"), _ask_news]]
	if _latest_belief() >= 0:
		entries.append([tr("LIVE_ASK_SOURCE"), _ask_source])
	entries.append([tr("LIVE_ASK_LORE"), _ask_lore])
	entries.append_array(world.extra_options(npc))
	entries.append([tr("LIVE_PRAISE"), _praise])
	entries.append([tr("LIVE_HIT"), _hit] if _insulted else [tr("LIVE_INSULT"), _insult])
	entries.append([tr("LIVE_BYE"), close])
	_set_options(entries)


func _set_options(entries: Array) -> void:
	_options = entries
	bar.show_options(entries)


func _say(text: String) -> void:
	world.bubble_of(npc.id).say(text, Color.BLACK, 3600.0)


## Permite a otros sistemas responder y seguir la conversación.
func reply(text: String) -> void:
	_say(text)
	_refresh()


func _random_line(key: String) -> String:
	var lines: Array = world.sim.species_data[npc.species][key]
	return lines[absi((npc.id + key + str(npc.memories.size())).hash()) % lines.size()]


func _latest_belief() -> int:
	var best: int = -1
	for key: String in npc.beliefs:
		best = maxi(best, key.to_int())
	return best


func _ask_news() -> void:
	var id: int = _latest_belief()
	if id < 0:
		reply(_random_line("nothing"))
		return
	var text: String = world.sim.rumors.phrase(world.sim, npc.beliefs[str(id)])
	reply("%s %s" % [_random_line("opener"), text])


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
		reply(_random_line("nothing"))
		return
	var facts: Array = world.sim.species_data[npc.species]["lore"]
	reply(facts[int(npc.lore[0])]["text"])


func _praise() -> void:
	npc.feel("alegria", 20.0)
	npc.relate(WorldSim.PLAYER_ID, "afecto", 10.0)
	world.sim.change_standing(npc.species, PRAISE_STANDING)
	reply(_random_line("praised"))


## Cierra la charla y va a por él. El resto lo decide el combate de siempre.
func _hit() -> void:
	var guard: Guard = world.citizens[npc.id]
	close()
	world.level.attack_citizen(guard)


func _insult() -> void:
	_insulted = true
	npc.feel("ira", 35.0)
	npc.relate(WorldSim.PLAYER_ID, "afecto", -20.0)
	world.sim.change_standing(npc.species, INSULT_STANDING)
	reply(_random_line("angry"))
