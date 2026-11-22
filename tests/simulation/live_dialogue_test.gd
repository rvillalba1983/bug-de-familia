extends GdUnitTestSuite
## El saludo de un habitante usa la línea de su oficio cuando la especie la
## tiene, y cada especie reparte un catálogo amplio de conversaciones (P-42).

const MINIMO_CONVERSACIONES: int = 150
const ACCIONES: Array[String] = [
	"", "gift_piece", "hit", "provoke_battle", "praise", "insult",
]

func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func _mount(zone_path: String) -> ZoneBase:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from(zone_path)
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	return zone


func test_greeting_uses_the_line_of_the_role() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/valle.json")
	var world: LiveWorld = zone.live_world
	var npc: NpcState = world.sim.npcs[world.sim.npc_ids[0]]
	var role_lines: Array = world.sim.species_data[npc.species]["role_lines"][npc.role]
	assert_int(role_lines.size()).is_greater(0)
	world.dialogue.open(npc)
	var text: String = world.bubble_of(npc.id).text
	assert_bool(role_lines.has(text)).is_true().override_failure_message(
		"El saludo no es una línea del oficio %s: %s" % [npc.role, text]
	)
	world.dialogue.close()


func test_every_citizen_role_has_lines_in_its_species() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/valle.json")
	var world: LiveWorld = zone.live_world
	for id: String in world.sim.npc_ids:
		var npc: NpcState = world.sim.npcs[id]
		var por_rol: Dictionary = world.sim.species_data[npc.species]["role_lines"]
		assert_bool(por_rol.has(npc.role)).is_true().override_failure_message(
			"%s (%s) no tiene línea para el oficio %s" % [npc.id, npc.species, npc.role]
		)


func _species() -> Array:
	var datos: Dictionary = DataFile.load_dictionary("res://data/world/species.json")
	return datos.keys()


func test_cada_especie_tiene_al_menos_150_conversaciones() -> void:
	for species: String in _species():
		var conversations: Array = ConversationCatalog.conversations_for(species)
		assert_int(conversations.size()).is_greater_equal(MINIMO_CONVERSACIONES) \
			.override_failure_message(
				"%s solo tiene %d conversaciones" % [species, conversations.size()])
		var ids: Dictionary = {}
		for conversation: Dictionary in conversations:
			var ident: String = str(conversation.get("id", ""))
			assert_str(ident).is_not_empty().override_failure_message(
				"%s: conversación sin id" % species)
			assert_bool(ids.has(ident)).is_false().override_failure_message(
				"%s: id repetido %s" % [species, ident])
			ids[ident] = true


func test_las_conversaciones_estan_bien_formadas() -> void:
	for species: String in _species():
		var acciones: Dictionary = {}
		var largas: int = 0
		for conversation: Dictionary in ConversationCatalog.conversations_for(species):
			var ident: String = str(conversation.get("id", "?"))
			var nodes: Dictionary = conversation.get("nodes", {})
			assert_bool(nodes.has("root")).is_true().override_failure_message(
				"%s: falta el nodo root" % ident)
			if nodes.size() >= 5:
				largas += 1
			for key: String in nodes:
				var node: Dictionary = nodes[key]
				assert_str(str(node.get("text", "")).strip_edges()).is_not_empty() \
					.override_failure_message("%s:%s: texto vacío" % [ident, key])
				var options: Array = node.get("options", [])
				assert_int(options.size()).is_greater(0).override_failure_message(
					"%s:%s: sin opciones" % [ident, key])
				for option: Dictionary in options:
					assert_str(str(option.get("label", "")).strip_edges()).is_not_empty() \
						.override_failure_message("%s:%s: opción sin etiqueta" % [ident, key])
					var next: String = str(option.get("next", ""))
					if not next.is_empty():
						assert_bool(nodes.has(next)).is_true().override_failure_message(
							"%s:%s: next %s no existe" % [ident, key, next])
					var action: String = str(option.get("action", ""))
					assert_bool(ACCIONES.has(action)).is_true().override_failure_message(
						"%s:%s: acción desconocida %s" % [ident, key, action])
					if not action.is_empty():
						acciones[action] = int(acciones.get(action, 0)) + 1
		for action: String in ["gift_piece", "hit", "provoke_battle"]:
			assert_int(int(acciones.get(action, 0))).is_greater(0) \
				.override_failure_message("%s: ninguna conversación usa %s" % [species, action])
		assert_int(largas).is_greater(0).override_failure_message(
			"%s: ninguna conversación encadena cinco nodos o más" % species)


func test_los_habitantes_de_una_zona_no_repiten_conversacion() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/valle.json")
	var world: LiveWorld = zone.live_world
	var elegidas: Dictionary = {}
	for id: String in world.sim.npc_ids:
		var npc: NpcState = world.sim.npcs[id]
		var conversation: Dictionary = ConversationCatalog.pick(npc.species, npc.id + npc.role)
		assert_bool(conversation.is_empty()).is_false().override_failure_message(
			"%s (%s) no tiene conversación" % [id, npc.species])
		var ident: String = str(conversation.get("id", ""))
		assert_bool(elegidas.has(ident)).is_false().override_failure_message(
			"%s comparte la conversación %s con %s" % [id, ident, elegidas.get(ident, "?")])
		elegidas[ident] = id
		var otra: Dictionary = ConversationCatalog.pick(npc.species, npc.id + npc.role)
		assert_str(str(otra.get("id", ""))).is_equal(ident).override_failure_message(
			"%s cambia de conversación entre dos llamadas" % id)


func test_zone_rumor_option_marks_a_neighbour_as_known() -> void:
	var zone: ZoneBase = await _mount("res://data/zones/valle.json")
	var manager: ZoneManager = auto_free(ZoneManager.new())
	add_child(manager)
	manager.current_id = "valle"
	zone.zone_manager = manager
	var world: LiveWorld = zone.live_world
	var npc: NpcState = world.sim.npcs[world.sim.npc_ids[0]]
	var neighbours: Array[String] = manager.registry.graph.neighbours("valle")
	assert_int(neighbours.size()).is_greater(0)
	world.dialogue.open(npc)
	var index: int = -1
	for option_index: int in range(world.dialogue.options().size()):
		var entry: Array = world.dialogue.options()[option_index]
		if str(entry[0]) == "¿Sabes de otra zona?":
			index = option_index
			break
	assert_int(index).is_greater_equal(0)
	world.dialogue.choose(index)
	var learned: Array[String] = []
	for zone_id: String in neighbours:
		if manager.is_known(zone_id):
			learned.append(zone_id)
	assert_int(learned.size()).is_equal(1)
	var record: ZoneRecord = manager.records[learned[0]] as ZoneRecord
	assert_int(record.level).is_equal(ZoneRecord.Level.STATISTICAL)
	var zone_name: String = manager.registry.zone(learned[0]).display_name
	assert_bool(world.bubble_of(npc.id).text.contains(zone_name)).is_true()
	world.dialogue.close()
