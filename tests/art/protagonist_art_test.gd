extends GdUnitTestSuite


func _source() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(ProtagonistArt.DATA_PATH))


func _check_shapes(shapes: Array) -> void:
	for shape: Dictionary in shapes:
		if shape.has("p"):
			var points: PackedVector2Array = PackedVector2Array()
			for pair: Array in shape["p"]:
				points.append(Vector2(pair[0] as float, pair[1] as float))
			assert_bool(Geometry2D.triangulate_polygon(points).is_empty()).is_false()


func test_every_view_has_every_slot_and_can_be_triangulated() -> void:
	var views: Dictionary = _source()["views"]
	for view_name: String in ProtagonistArt.VIEWS:
		var parts: Dictionary = views[view_name]["parts"]
		for part_name: String in ProtagonistArt.PART_SLOTS:
			assert_bool(parts.has(part_name)).is_true()
		for part_name: String in parts:
			_check_shapes(parts[part_name]["shapes"] as Array)
			for addon: String in parts[part_name]["addons"]:
				_check_shapes(parts[part_name]["addons"][addon] as Array)


func test_variant_counts_match_the_design_sheet() -> void:
	var variants: Dictionary = _source()["variants"]
	assert_int((variants["head"] as Array).size()).is_equal(BodyPiece.VISUAL_VARIANTS[BodyPiece.Kind.HEAD])
	assert_int((variants["arm"] as Array).size()).is_equal(BodyPiece.VISUAL_VARIANTS[BodyPiece.Kind.ARM])
	assert_int((variants["leg"] as Array).size()).is_equal(BodyPiece.VISUAL_VARIANTS[BodyPiece.Kind.LEG])


func test_view_follows_the_eight_directions() -> void:
	assert_str(ProtagonistArt.view_for(Vector2.RIGHT)).is_equal("E")
	assert_str(ProtagonistArt.view_for(Vector2.DOWN)).is_equal("S")
	assert_str(ProtagonistArt.view_for(Vector2.LEFT)).is_equal("W")
	assert_str(ProtagonistArt.view_for(Vector2.UP)).is_equal("N")
	assert_str(ProtagonistArt.view_for(Vector2(1.0, 1.0))).is_equal("SE")


func test_visual_variant_survives_saving() -> void:
	var piece: BodyPiece = BodyPiece.new(BodyPiece.Kind.ARM)
	piece.pick_visual_variant("prueba")
	assert_int(piece.visual_variant).is_greater(0)
	assert_int(BodyPiece.from_dict(piece.to_dict()).visual_variant).is_equal(piece.visual_variant)


func test_night_follows_the_blackout_hours() -> void:
	var atmosphere: DespliegueCeroAtmosphere = DespliegueCeroAtmosphere.new()
	atmosphere.hour_source = func() -> int: return 22
	assert_bool(atmosphere.is_night()).is_true()
	atmosphere.hour_source = func() -> int: return 12
	assert_bool(atmosphere.is_night()).is_false()
	atmosphere.free()
