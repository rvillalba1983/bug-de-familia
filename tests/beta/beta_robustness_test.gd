extends GdUnitTestSuite
## Busca cierres del juego: referencias a cosas que ya no existen y combinaciones raras.
## Un cierre deja la ejecución parada y la prueba falla por tiempo.

const PATH: String = "res://scenes/beta/beta_zone.tscn"
const SEEDS: Array[int] = [11, 222, 3333, 44444]
const SOAK_STEPS: int = 150
const WORLD_FLAGS: Array[String] = [
	"guerra", "paz", "tregua", "voto_bobina", "tiene_bobina", "tiene_mina", "muro_volado",
	"clave_ok", "clave_mal", "salvoconducto", "moho_desviada", "jub_desviada", "moho_bronca",
	"jub_bronca", "ramon_peleado", "ramon_muerto", "ramon_discutido", "bobina_puesta",
]

var zone: BetaZone


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	zone = _load_zone()


func after_test() -> void:
	BetaZone.forced_hour = -1
	get_tree().paused = false


func _load_zone() -> BetaZone:
	var runner: GdUnitSceneRunner = scene_runner(PATH)
	return runner.scene()


func _frames(count: int = 3) -> void:
	for _index: int in range(count):
		await get_tree().process_frame


## Avanza las reglas aunque haya una pausa abierta.
func _tick(level: BetaZone) -> void:
	level.challenges._physics_process(0.5)
	level.combat._physics_process(0.016)
	level.fight._physics_process(0.016)
	level.investigation.tick_ambient(5.0)


func _remove(level: BetaZone, id: String) -> void:
	if level.entities.has(id):
		level._on_converted(id)


func _apply_every_flag(level: BetaZone) -> void:
	for flag: String in WORLD_FLAGS:
		level.investigation.set_flag(flag)
		_tick(level)


func _reload_and_check() -> void:
	zone.autosave()
	var restored: BetaZone = _load_zone()
	await _frames()
	_apply_every_flag(restored)
	assert_object(restored.player).is_not_null()


func test_every_flag_with_all_entities_gone() -> void:
	for id: String in zone.entities.keys():
		_remove(zone, id)
	await _frames()
	_apply_every_flag(zone)
	await _frames()
	await _reload_and_check()


func test_every_flag_with_each_entity_gone_alone() -> void:
	var ids: Array = zone.entities.keys().filter(func(id: String) -> bool: return not id.begins_with("npc_"))
	ids.append_array(zone.entities.keys().filter(func(id: String) -> bool: return id.begins_with("npc_")).slice(0, 4))
	for id: String in ids:
		var level: BetaZone = _load_zone()
		_remove(level, id)
		await _frames()
		_apply_every_flag(level)
		await _frames()
	assert_int(ids.size()).is_greater(5)


func test_corpses_that_expire_leave_nothing_dangling() -> void:
	var enemies: Array[Guard] = zone.guards()
	for enemy: Guard in enemies:
		enemy.take_damage(1000.0)
	for enemy: Guard in enemies:
		zone._on_corpse_expired(enemy)
	await _frames()
	assert_array(zone.guards()).is_empty()
	_apply_every_flag(zone)
	await _reload_and_check()


func test_combat_target_removed_mid_fight() -> void:
	var enemy: Guard = zone.guards()[0]
	zone.combat.engage(enemy)
	_remove(zone, zone._id_of(enemy))
	await _frames()
	_tick(zone)
	await _frames()


func test_piece_actions_when_their_targets_are_gone() -> void:
	_remove(zone, "camera_1")
	_remove(zone, "drone_1")
	await _frames()
	for action: String in ["a054", "a055", "a056", "a062"]:
		zone.actions._perform(action)
	await _frames()


func test_every_dialogue_option_can_be_chosen() -> void:
	var case: InvestigationDirector = zone.investigation
	var nodes: Dictionary = case.case_data["dialogue"]
	var chosen: int = 0
	for node_id: String in nodes:
		for index: int in range((nodes[node_id]["options"] as Array).size()):
			for flag: String in (nodes[node_id]["options"][index]["requires"] as Array):
				case.flags[flag] = true
			for flag: String in (nodes[node_id]["options"][index]["forbids"] as Array):
				case.flags.erase(flag)
			zone.player.body.add_spare(ModularBody.Slot.LEG_LEFT, BodyPiece.new(BodyPiece.Kind.LEG))
			zone.pause.begin_modal()
			case._show_node(node_id)
			var target: Dictionary = nodes[node_id]["options"][index]
			var position_in_list: int = case.available_options(node_id).find(target)
			assert_int(position_in_list).is_greater_equal(0)
			case.choose(position_in_list)
			if not case.current_node.is_empty():
				case._close()
			chosen += 1
			_tick(zone)
	await _frames()
	assert_int(chosen).is_greater(40)


func test_dialogue_timer_after_closing_does_nothing() -> void:
	zone.investigation.open_dialogue("cuadrilla_moho")
	zone.investigation.choose(1)
	zone.investigation._tick_answer_limit(20.0)
	assert_str(zone.investigation.current_node).is_empty()


func test_random_play_does_not_crash() -> void:
	for seed_value: int in SEEDS:
		TestSupport.reset_session()
		var level: BetaZone = _load_zone()
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = seed_value
		for _step: int in range(SOAK_STEPS):
			_random_action(level, rng)
			_tick(level)
			if rng.randf() < 0.1:
				await _frames(1)
		_end_dialogue(level)
		await _frames()
		level.autosave()
		var restored: BetaZone = _load_zone()
		await _frames()
		assert_object(restored.investigation).is_not_null()


func _random_action(level: BetaZone, rng: RandomNumberGenerator) -> void:
	var case: InvestigationDirector = level.investigation
	if not case.current_node.is_empty():
		var options: int = case.available_options(case.current_node).size()
		case.choose(rng.randi_range(0, options - 1))
		return
	match rng.randi_range(0, 7):
		0:
			level.player.global_position = Vector2(
				rng.randf_range(200.0, 3600.0), rng.randf_range(200.0, 2400.0)
			)
		1:
			case.set_flag(WORLD_FLAGS[rng.randi_range(0, WORLD_FLAGS.size() - 1)])
		2:
			var ids: Array = level.entities.keys()
			if not ids.is_empty():
				_remove(level, ids[rng.randi_range(0, ids.size() - 1)])
		3:
			_activate_random_item(level, rng)
		4:
			_open_random_dialogue(level, rng)
		5:
			var enemies: Array[Guard] = level.guards()
			if not enemies.is_empty():
				enemies[rng.randi_range(0, enemies.size() - 1)].take_damage(rng.randf_range(10.0, 120.0))
		6:
			var mines: Array = level.mines.values()
			if not mines.is_empty():
				(mines[rng.randi_range(0, mines.size() - 1)] as PetanqueMine).detonate(false)
		7:
			level.rain.wear(0.5)


func _activate_random_item(level: BetaZone, rng: RandomNumberGenerator) -> void:
	var ids: Array = level.items.keys()
	if not ids.is_empty():
		(level.items[ids[rng.randi_range(0, ids.size() - 1)]] as Interactable).activate()


func _open_random_dialogue(level: BetaZone, rng: RandomNumberGenerator) -> void:
	var ids: Array = level.investigation.npc_nodes.keys()
	var id: String = ids[rng.randi_range(0, ids.size() - 1)]
	var node: Variant = level.investigation.npc_nodes[id]
	if is_instance_valid(node) and not (node as Interactable).used:
		level.investigation.open_dialogue(id)


func _end_dialogue(level: BetaZone) -> void:
	if not level.investigation.current_node.is_empty():
		level.investigation._close()


func test_cada_accion_del_catalogo_se_puede_ejecutar() -> void:
	var player: Player = zone.player
	player.global_position = zone.guards()[0].global_position + Vector2(30.0, 0.0)
	for id: String in zone.catalog.actions:
		var spec: Dictionary = zone.catalog.actions[id].get("do", {})
		if not spec.is_empty():
			zone.actions._perform_generic(spec)
	await _frames()
	assert_bool(player.body.is_dead).is_false()


func test_don_ramon_suelda_una_sola_vez() -> void:
	var before: int = zone.player.body.spare_count()
	zone.investigation.set_flag("verdad_ramon")
	zone.investigation.set_flag("verdad_ramon")
	assert_int(zone.player.body.spare_count()).is_equal(before + 1)


func test_aliado_unico_deja_huella_y_comentarios() -> void:
	var at: Vector2 = zone.ramon.global_position
	var before: int = zone.live_world.sim.truth.records.size()
	zone.challenges.on_ramon_fell()
	assert_bool(zone.investigation.flags.has(BetaChallenges.ID_RAMON_TRACE)).is_true()
	assert_int(zone.live_world.sim.truth.records.size()).is_greater(before)
	var trace: Interactable = zone.challenges._footprints[BetaChallenges.ID_RAMON_TRACE]
	assert_vector(trace.global_position).is_equal(at)
