extends GdUnitTestSuite
## Fachada que delimita un corredor (P-53): geometría, colisión y opacidad.

const FOOTPRINT: Rect2 = Rect2(1840.0, 64.0, 40.0, 400.0)
const HEIGHT: float = 200.0


func test_footprint_and_front_drive_the_geometry() -> void:
	var facade: CorridorFacade = _facade()
	assert_vector(facade.position).is_equal(Vector2(FOOTPRINT.position.x, FOOTPRINT.end.y))
	assert_vector(facade.front_rect().size).is_equal(Vector2(FOOTPRINT.size.x, HEIGHT))
	assert_vector(facade.front_rect().position).is_equal(Vector2(0.0, -HEIGHT))
	var visible: Rect2 = facade.visual_rect()
	var visible_top: float = FOOTPRINT.position.y - HEIGHT
	assert_vector(visible.position).is_equal(Vector2(FOOTPRINT.position.x, visible_top))
	assert_vector(visible.size).is_equal(FOOTPRINT.size + Vector2(0.0, HEIGHT))


## Delimita igual que un muro: colisiona en la capa de muros y no filtra contactos.
func test_collision_matches_a_wall() -> void:
	var facade: CorridorFacade = _facade()
	assert_int(facade.collision_layer).is_equal(PhysicsLayers.WALLS)
	assert_int(facade.collision_mask).is_equal(0)
	var shapes: Array[CollisionShape2D] = []
	for child: Node in facade.get_children():
		if child is CollisionShape2D:
			shapes.append(child as CollisionShape2D)
	assert_int(shapes.size()).is_equal(1)
	assert_vector((shapes[0].shape as RectangleShape2D).size).is_equal(FOOTPRINT.size)


## No se desvanece: no procesa por fotograma ni depende de la distancia al jugador
## (la fachada de un edificio transitable, en cambio, se aclara al acercarse).
func test_facade_never_fades_with_the_player() -> void:
	var facade: CorridorFacade = _facade()
	assert_bool(facade.is_processing()).is_false()
	assert_bool(facade is StaticBody2D).is_true()
	assert_float(facade.modulate.a).is_equal(1.0)


## Sin textura (SVG ausente) la fachada sigue delimitando: el error queda visible
## en el registro y no se rompe el montaje.
func test_facade_without_texture_keeps_the_footprint() -> void:
	var facade: CorridorFacade = auto_free(CorridorFacade.new())
	facade.setup(FOOTPRINT, HEIGHT, null)
	add_child(facade)
	assert_object(facade.texture).is_null()
	assert_vector(facade.footprint.size).is_equal(FOOTPRINT.size)


func _facade() -> CorridorFacade:
	var facade: CorridorFacade = auto_free(CorridorFacade.new())
	facade.setup(FOOTPRINT, HEIGHT, load("res://art/shared/fachada_centralita.svg") as Texture2D)
	add_child(facade)
	return facade
