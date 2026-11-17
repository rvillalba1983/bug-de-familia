extends GdUnitTestSuite
## Ocho direcciones sobre cinco vistas (P-52): reparto y espejo del dron.

## Direcciones de los ocho octantes, en el orden de `Player.octant_of`:
## E, SE, S, SW, W, NW, N, NE.
const OCTANTS: Array[Vector2] = [
	Vector2(1.0, 0.0), Vector2(1.0, 1.0), Vector2(0.0, 1.0), Vector2(-1.0, 1.0),
	Vector2(-1.0, 0.0), Vector2(-1.0, -1.0), Vector2(0.0, -1.0), Vector2(1.0, -1.0),
]
## Las cinco vistas reales del dron, en el orden de `GuardVisual.VIEW_SUFFIX`.
## Desde P-52 el arte dibuja también las diagonales: no hay respaldo con la lateral.
const DRONE_FILES: Array[Texture2D] = [
	preload("res://art/shared/dron_viejo.svg"),
	preload("res://art/shared/dron_viejo_se.svg"),
	preload("res://art/shared/dron_viejo_e.svg"),
	preload("res://art/shared/dron_viejo_ne.svg"),
	preload("res://art/shared/dron_viejo_n.svg"),
]


func test_art_for_covers_the_eight_octants() -> void:
	var drone: Drone = auto_free(Drone.new())
	var expected: Array[Texture2D] = [
		DRONE_FILES[GuardVisual.VIEW_EAST], DRONE_FILES[GuardVisual.VIEW_SOUTHEAST],
		DRONE_FILES[GuardVisual.VIEW_SOUTH], DRONE_FILES[GuardVisual.VIEW_SOUTHEAST],
		DRONE_FILES[GuardVisual.VIEW_EAST], DRONE_FILES[GuardVisual.VIEW_NORTHEAST],
		DRONE_FILES[GuardVisual.VIEW_NORTH], DRONE_FILES[GuardVisual.VIEW_NORTHEAST],
	]
	for octant: int in OCTANTS.size():
		assert_object(drone.art_for(OCTANTS[octant])).is_same(expected[octant])


## P-52: cada vista se carga de su propio archivo, sin respaldo entre vistas.
func test_every_view_loads_its_own_file() -> void:
	var drone: Drone = auto_free(Drone.new())
	for view: int in GuardVisual.VIEW_SUFFIX.size():
		var path: String = "res://art/shared/dron_viejo" + GuardVisual.VIEW_SUFFIX[view] + ".svg"
		assert_str(Drone.path_of(view)).is_equal(path)
		assert_object(Drone.texture_of(view)).is_not_null()
		assert_object(Drone.texture_of(view)).is_same(DRONE_FILES[view])
	## Las cinco posiciones de la tabla de vistas son las cinco texturas reales.
	assert_object(drone.art_for(Vector2.DOWN)).is_same(DRONE_FILES[GuardVisual.VIEW_SOUTH])
	assert_object(drone.art_for(Vector2.RIGHT)).is_same(DRONE_FILES[GuardVisual.VIEW_EAST])
	assert_object(drone.art_for(Vector2.UP)).is_same(DRONE_FILES[GuardVisual.VIEW_NORTH])


## Las diagonales son arte propio desde P-52: ya no reutilizan la lateral `_e`.
func test_the_diagonals_are_art_of_their_own() -> void:
	var drone: Drone = auto_free(Drone.new())
	var east: Texture2D = drone.art_for(Vector2.RIGHT)
	assert_object(drone.art_for(OCTANTS[1])).is_not_same(east)
	assert_object(drone.art_for(OCTANTS[7])).is_not_same(east)


func test_only_the_three_west_octants_are_mirrored() -> void:
	var drone: Drone = auto_free(Drone.new())
	for octant: int in OCTANTS.size():
		var west: bool = octant == 3 or octant == 4 or octant == 5
		assert_bool(drone.mirrored_for(OCTANTS[octant])).is_equal(west)
