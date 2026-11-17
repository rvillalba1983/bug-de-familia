extends GdUnitTestSuite
## Ocho direcciones sobre cinco vistas dibujadas (P-52): reparto y espejo del guardia.

const ART_FOLDER: String = "res://art/shared/"
const BASE: String = "jubilado_hierro"
const RIG_FOLDER: String = "res://art/shared/rig/jubilado_hierro"
## Las cinco vistas reales, en el orden de `GuardVisual.VIEW_SUFFIX`. Desde P-52 el
## arte dibuja también las diagonales: no hay respaldo con la lateral.
const VIEW_FILES: Array[Texture2D] = [
	preload("res://art/shared/jubilado_hierro.svg"),
	preload("res://art/shared/jubilado_hierro_se.svg"),
	preload("res://art/shared/jubilado_hierro_e.svg"),
	preload("res://art/shared/jubilado_hierro_ne.svg"),
	preload("res://art/shared/jubilado_hierro_n.svg"),
]
## Direcciones de los ocho octantes, en el orden de `Player.octant_of`:
## E, SE, S, SW, W, NW, N, NE.
const OCTANTS: Array[Vector2] = [
	Vector2(1.0, 0.0), Vector2(1.0, 1.0), Vector2(0.0, 1.0), Vector2(-1.0, 1.0),
	Vector2(-1.0, 0.0), Vector2(-1.0, -1.0), Vector2(0.0, -1.0), Vector2(1.0, -1.0),
]


func test_octant_of_uses_the_convention_of_the_protagonist() -> void:
	for octant: int in OCTANTS.size():
		assert_int(GuardVisual.octant_of(OCTANTS[octant])).is_equal(octant)
		assert_int(GuardVisual.octant_of(OCTANTS[octant])).is_equal(
			Player.octant_of(OCTANTS[octant])
		)


func test_view_for_covers_the_eight_octants() -> void:
	var expected: Array[int] = [
		GuardVisual.VIEW_EAST, GuardVisual.VIEW_SOUTHEAST, GuardVisual.VIEW_SOUTH,
		GuardVisual.VIEW_SOUTHEAST, GuardVisual.VIEW_EAST, GuardVisual.VIEW_NORTHEAST,
		GuardVisual.VIEW_NORTH, GuardVisual.VIEW_NORTHEAST,
	]
	for octant: int in OCTANTS.size():
		assert_int(GuardVisual.view_for(OCTANTS[octant])).is_equal(expected[octant])


func test_only_the_three_west_octants_are_mirrored() -> void:
	for octant: int in OCTANTS.size():
		var west: bool = octant == 3 or octant == 4 or octant == 5
		assert_bool(GuardVisual.is_mirrored(OCTANTS[octant])).is_equal(west)


func test_only_the_three_side_views_are_drawn_sideways() -> void:
	var sides: Array[int] = [
		GuardVisual.VIEW_SOUTHEAST, GuardVisual.VIEW_EAST, GuardVisual.VIEW_NORTHEAST,
	]
	for view: int in GuardVisual.VIEW_SUFFIX.size():
		assert_bool(GuardVisual.is_side(view)).is_equal(sides.has(view))


func test_load_views_brings_the_five_textures() -> void:
	var views: Array[Texture2D] = GuardVisual.load_views(ART_FOLDER, BASE)
	assert_int(views.size()).is_equal(GuardVisual.VIEW_SUFFIX.size())
	for view: int in views.size():
		assert_object(views[view]).is_not_null()


## P-52: cada vista se carga de su propio archivo, sin respaldo entre vistas.
func test_every_view_loads_its_own_file() -> void:
	var views: Array[Texture2D] = GuardVisual.load_views(ART_FOLDER, BASE)
	assert_int(views.size()).is_equal(GuardVisual.VIEW_SUFFIX.size())
	for view: int in views.size():
		assert_object(views[view]).is_not_null()
		assert_str(views[view].resource_path).is_equal(
			ART_FOLDER + BASE + GuardVisual.VIEW_SUFFIX[view] + ".svg"
		)
		assert_object(views[view]).is_same(VIEW_FILES[view])


## Las diagonales son arte propio desde P-52: ya no reutilizan la lateral `_e`.
func test_the_diagonals_are_art_of_their_own() -> void:
	var views: Array[Texture2D] = GuardVisual.load_views(ART_FOLDER, BASE)
	var east: Texture2D = views[GuardVisual.VIEW_EAST]
	assert_object(views[GuardVisual.VIEW_SOUTHEAST]).is_not_same(east)
	assert_object(views[GuardVisual.VIEW_NORTHEAST]).is_not_same(east)


func test_the_rig_follows_the_eight_octants_and_mirrors_the_three_west_ones() -> void:
	var guard: Guard = auto_free(Guard.new())
	guard.visual.rig_folder = RIG_FOLDER
	for octant: int in OCTANTS.size():
		var direction: Vector2 = OCTANTS[octant]
		guard.detector.facing_angle = direction.angle()
		guard.visual.update_rig()
		assert_int(guard.visual._rig_view).is_equal(GuardVisual.view_for(direction))
		var west: bool = octant == 3 or octant == 4 or octant == 5
		assert_bool(guard.visual.rig.scale.x < 0.0).is_equal(west)
	## Cinco esqueletos perezosos como mucho: uno por vista dibujada.
	assert_int(guard.visual._rigs.size()).is_equal(GuardVisual.VIEW_SUFFIX.size())


func test_rigs_are_built_only_for_the_view_in_use() -> void:
	var guard: Guard = auto_free(Guard.new())
	guard.visual.rig_folder = RIG_FOLDER
	guard.detector.facing_angle = Vector2.DOWN.angle()
	guard.visual.update_rig()
	assert_object(guard.visual.rig).is_not_null()
	assert_object(guard.visual._rigs[GuardVisual.VIEW_EAST]).is_null()
	assert_object(guard.visual._rigs[GuardVisual.VIEW_SOUTHEAST]).is_null()


func test_falling_keeps_the_view_where_the_guard_was_looking() -> void:
	var guard: Guard = auto_free(Guard.new())
	guard.visual.rig_folder = RIG_FOLDER
	guard.detector.facing_angle = Vector2.LEFT.angle()
	guard.visual.update_rig()
	var view: int = guard.visual._rig_view
	guard.state = Guard.State.DOWN
	guard.visual.update_rig()
	assert_int(guard.visual._rig_view).is_equal(view)
