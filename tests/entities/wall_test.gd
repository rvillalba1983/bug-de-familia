extends GdUnitTestSuite

const AREA: Rect2 = Rect2(100.0, 100.0, 200.0, 90.0)
const BASE_Y: float = 190.0
const HEIGHT: float = 60.0


func test_character_behind_wall_is_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(200.0, 170.0), HEIGHT)).is_true()


func test_character_with_only_legs_covered_is_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(200.0, 105.0), HEIGHT)).is_true()


func test_character_in_front_is_not_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(200.0, 200.0), HEIGHT)).is_false()


func test_character_beside_wall_is_not_hidden() -> void:
	assert_bool(Wall.hides_character(AREA, BASE_Y, Vector2(400.0, 170.0), HEIGHT)).is_false()


## Un muro normal se atenúa cuando tapa a un personaje.
func test_solid_wall_fades_when_it_hides_the_character() -> void:
	var wall: Wall = _wall(Wall.Kind.SOLID)
	wall.update_occlusion(Vector2(200.0, 110.0), HEIGHT)
	assert_float(wall.modulate.a).is_equal_approx(Wall.FADED_ALPHA, 0.001)


## El fondo del corredor no se atenúa nunca: si se desvaneciera se vería el corte
## del mapa que está tapando.
func test_backdrop_wall_stays_opaque() -> void:
	var wall: Wall = _wall(Wall.Kind.BACKDROP)
	wall.always_opaque = true
	assert_bool(Wall.hides_character(
		wall.visual_rect(), wall.footprint.end.y, Vector2(200.0, 110.0), HEIGHT
	)).is_true()
	wall.update_occlusion(Vector2(200.0, 110.0), HEIGHT)
	assert_float(wall.modulate.a).is_equal(1.0)


## El fondo no colisiona: el hueco del pasillo tiene que seguir abierto.
func test_backdrop_wall_has_no_collision() -> void:
	assert_int(_wall(Wall.Kind.BACKDROP).collision_layer).is_equal(0)
	assert_int(_wall(Wall.Kind.SOLID).collision_layer).is_equal(PhysicsLayers.WALLS)


func _wall(kind: Wall.Kind) -> Wall:
	var wall: Wall = auto_free(Wall.new())
	wall.setup(Rect2(100.0, 100.0, 200.0, 16.0), 64.0, kind)
	add_child(wall)
	return wall
