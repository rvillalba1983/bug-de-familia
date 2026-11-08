extends GdUnitTestSuite

const PARTS: Array[String] = [
	"head", "head_back", "torso", "torso_back", "scarf", "arm_main_left", "arm_main_right",
	"arm_extra_left", "arm_extra_right", "leg_left", "leg_right",
]


func test_every_polygon_can_be_triangulated() -> void:
	var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ProtagonistArt.DATA_PATH))
	for part_name: String in PARTS:
		assert_bool(source.has(part_name)).is_true()
		for shape: Dictionary in source[part_name]["shapes"]:
			if shape.has("p"):
				var points: PackedVector2Array = PackedVector2Array()
				for pair: Array in shape["p"]:
					points.append(Vector2(pair[0] as float, pair[1] as float))
				assert_bool(Geometry2D.triangulate_polygon(points).is_empty()).is_false()


func test_night_follows_the_blackout_hours() -> void:
	var atmosphere: BetaAtmosphere = BetaAtmosphere.new()
	atmosphere.hour_source = func() -> int: return 22
	assert_bool(atmosphere.is_night()).is_true()
	atmosphere.hour_source = func() -> int: return 12
	assert_bool(atmosphere.is_night()).is_false()
	atmosphere.free()
