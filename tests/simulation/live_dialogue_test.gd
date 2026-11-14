extends GdUnitTestSuite
## El saludo de un habitante usa la línea de su oficio cuando la especie la tiene.

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
