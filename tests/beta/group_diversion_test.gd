extends GdUnitTestSuite
## Un grupo engañado se va andando; al cargar la partida ya no está.

const PATH: String = "res://scenes/beta/beta_zone.tscn"
const IDS: Dictionary = {"cuadrilla_moho": "moho_desviada", "patrulla_jub": "jub_desviada"}

var zone: BetaZone


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	var runner: GdUnitSceneRunner = scene_runner(PATH)
	zone = runner.scene()
	zone.set_enemies_active(false)
	await get_tree().process_frame


func after_test() -> void:
	BetaZone.forced_hour = -1
	get_tree().paused = false


func test_diverted_group_walks_to_its_exit_and_then_leaves() -> void:
	for id: String in IDS:
		var item: Interactable = zone.investigation.npc_nodes[id]
		var goal: Vector2 = BetaChallenges.groups[id]["exit"]
		var start: Vector2 = item.position
		zone.investigation.set_flag(IDS[id])
		assert_bool(item.visible).is_true()
		assert_bool(item.used).is_true()
		assert_bool(item.drawn_when_used).is_true()
		zone.challenges._move_groups(1.0)
		assert_float(item.position.distance_to(start)).is_equal_approx(BetaChallenges.GROUP_LEAVE_SPEED, 0.1)
		assert_bool(item.visible).is_true()
		zone.challenges._move_groups(start.distance_to(goal) / BetaChallenges.GROUP_LEAVE_SPEED)
		assert_bool(item.visible).is_false()


func test_group_diverted_in_a_loaded_game_is_already_gone() -> void:
	var item: Interactable = zone.investigation.npc_nodes["cuadrilla_moho"]
	zone.challenges._flags_applied = false
	zone.investigation.flags["moho_desviada"] = true
	zone.challenges.apply_flags()
	assert_bool(item.visible).is_false()
	assert_bool(zone.challenges._leaving.is_empty()).is_true()
