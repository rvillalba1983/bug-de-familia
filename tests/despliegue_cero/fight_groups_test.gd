extends GdUnitTestSuite
## Pelear con habitantes: puntería de los clics, conversación y reacción del grupo.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"
const AT: Vector2 = Vector2(1500.0, 900.0)

var zone: DespliegueCeroZone
var people: Array = []


func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	zone = scene_runner(PATH).scene()
	await await_idle_frame()
	zone.set_enemies_active(false)
	people = _of_species("jubilado")


func after_test() -> void:
	if zone.panel.is_open:
		zone.panel.close()
	DespliegueCeroZone.forced_hour = -1
	get_tree().paused = false
	Engine.time_scale = 1.0


func _of_species(species: String) -> Array:
	var world: LiveWorld = zone.live_world
	return world.citizens.keys().filter(func(id: String) -> bool: return (world.sim.npcs[id] as NpcState).species == species).map(func(id: String) -> Guard: return world.citizens[id])


func _place(guards: Array) -> void:
	for index: int in range(guards.size()):
		(guards[index] as Guard).global_position = AT + Vector2(float(index) * 26.0, 0.0)


func _selectable(guard: Guard) -> Selectable:
	return guard.get_children().filter(func(n: Node) -> bool: return n is Selectable)[0]


func test_click_on_head_selects_that_person() -> void:
	_place([people[0]])
	zone.selection.select_at(AT - Vector2(0.0, 70.0))
	assert_object(zone.selection.current).is_same(_selectable(people[0]))


func test_both_buttons_pick_the_same_person_in_a_group() -> void:
	_place([people[0], people[1], people[2]])
	for index: int in range(3):
		var point: Vector2 = (people[index] as Guard).global_position - Vector2(0.0, 35.0)
		zone.selection.select_at(point)
		assert_object(zone.selection.current).is_same(_selectable(people[index]))
		assert_object(zone.orders.enemy_at(point)).is_same(people[index])


func test_insulting_turns_into_hitting() -> void:
	var world: LiveWorld = zone.live_world
	var npc: NpcState = world.sim.npcs[world.citizens.find_key(people[0])]
	world.dialogue.open(npc)
	assert_bool(_labels().has(tr("LIVE_HIT"))).is_false()
	world.dialogue.choose(_labels().find(tr("LIVE_INSULT")))
	assert_bool(_labels().has(tr("LIVE_INSULT"))).is_false()
	world.dialogue.choose(_labels().find(tr("LIVE_HIT")))
	assert_bool(world.dialogue.is_open()).is_false()
	assert_object(zone.combat.target).is_same(people[0])
	assert_object(zone.selection.current).is_same(_selectable(people[0]))


func _labels() -> Array:
	return zone.live_world.dialogue.options().map(func(option: Array) -> String: return option[0])


func test_group_of_same_species_joins_but_others_do_not() -> void:
	var outsider: Guard = _of_species("mohocrata")[0]
	var far: Guard = people[3]
	_place([people[0], people[1], people[2]])
	outsider.global_position = AT + Vector2(0.0, 40.0)
	far.global_position = AT + Vector2(DespliegueCeroZone.GROUP_REACT_RADIUS + 200.0, 0.0)
	(people[0] as Guard).take_damage(10.0)
	assert_bool((people[1] as Guard).is_alert()).is_true()
	assert_bool((people[2] as Guard).is_alert()).is_true()
	assert_bool(outsider.is_alert()).is_false()
	assert_bool(far.is_alert()).is_false()


func test_passive_citizen_does_not_compute_its_hidden_cone() -> void:
	var guard: Guard = people[0]
	guard.process_mode = Node.PROCESS_MODE_INHERIT
	guard._view._points.clear()
	await await_idle_frame()
	await get_tree().physics_frame
	assert_int(guard._view._points.size()).is_equal(0)
