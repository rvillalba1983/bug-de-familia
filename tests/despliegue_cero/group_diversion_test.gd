extends GdUnitTestSuite
## Un grupo engañado se va andando; al cargar la partida ya no está.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"
const IDS: Dictionary = {"cuadrilla_moho": "moho_desviada", "patrulla_jub": "jub_desviada"}

var zone: DespliegueCeroZone


func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	var runner: GdUnitSceneRunner = scene_runner(PATH)
	zone = runner.scene()
	zone.set_enemies_active(false)
	await get_tree().process_frame


func after_test() -> void:
	DespliegueCeroZone.forced_hour = -1
	get_tree().paused = false


func test_diverted_group_walks_to_indicated_zone_and_stays_there() -> void:
	for id: String in IDS:
		var item: Interactable = zone.investigation.npc_nodes[id]
		var goal: Vector2 = DespliegueCeroChallenges.groups[id]["indicated"]
		var start: Vector2 = item.position
		zone.investigation.set_flag(IDS[id])
		assert_bool(item.visible).is_true()
		assert_bool(item.used).is_true()
		assert_bool(item.drawn_when_used).is_true()
		zone.challenges._move_groups(1.0)
		assert_float(item.position.distance_to(start)).is_greater(0.0)
		assert_bool(item.visible).is_true()
		var steps: int = 0
		while item.position.distance_to(goal) > 1.0 and steps < 1000:
			zone.challenges._move_groups(0.1)
			steps += 1
		assert_float(item.position.distance_to(goal)).is_less(2.0)
		# No desaparece para siempre: se queda visible en el punto indicado.
		assert_bool(item.visible).is_true()


func test_group_diverted_in_a_loaded_game_settles_at_goal() -> void:
	var item: Interactable = zone.investigation.npc_nodes["cuadrilla_moho"]
	var goal: Vector2 = DespliegueCeroChallenges.groups["cuadrilla_moho"]["indicated"]
	zone.challenges._flags_applied = false
	zone.investigation.flags["moho_desviada"] = true
	zone.challenges.apply_flags()
	# En partida cargada el grupo ya está en el punto indicado, visible.
	assert_float(item.position.distance_to(goal)).is_less(2.0)
	assert_bool(item.visible).is_true()
	assert_bool(zone.challenges._leaving.is_empty()).is_true()
