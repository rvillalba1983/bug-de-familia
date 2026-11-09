extends GdUnitTestSuite

const FOLDER: String = "res://art/beta/rig/jubilado_hierro"


func _rig() -> EnemyRig:
	var rig: EnemyRig = auto_free(EnemyRig.new())
	add_child(rig)
	rig.build(FOLDER, 96.0, 0.93)
	return rig


func test_every_part_has_its_texture() -> void:
	for part: String in EnemyRig.ALL_PARTS:
		assert_bool(ResourceLoader.exists(FOLDER.path_join(part + ".svg"))).is_true()


func test_has_the_four_animations_and_loops_walking() -> void:
	var rig: EnemyRig = _rig()
	for animation: StringName in [EnemyRig.IDLE, EnemyRig.WALK, EnemyRig.ALERT, EnemyRig.FALL]:
		assert_bool(rig.player.has_animation(animation)).is_true()
	assert_int(rig.player.get_animation(EnemyRig.WALK).loop_mode).is_equal(Animation.LOOP_LINEAR)
	assert_int(rig.player.get_animation(EnemyRig.FALL).loop_mode).is_equal(Animation.LOOP_NONE)


func test_tracks_point_to_existing_bones() -> void:
	var rig: EnemyRig = _rig()
	var root: Node = rig.player.get_node(rig.player.root_node)
	for animation: StringName in rig.player.get_animation_list():
		var data: Animation = rig.player.get_animation(animation)
		for track: int in range(data.get_track_count()):
			var path: NodePath = data.track_get_path(track)
			assert_object(root.get_node_or_null(NodePath(str(path).get_slice(":", 0)))).is_not_null()


func test_asking_again_does_not_restart() -> void:
	var rig: EnemyRig = _rig()
	rig.show_animation(EnemyRig.WALK)
	rig.player.seek(0.3, true)
	rig.show_animation(EnemyRig.WALK)
	assert_float(rig.player.current_animation_position).is_equal_approx(0.3, 0.01)
