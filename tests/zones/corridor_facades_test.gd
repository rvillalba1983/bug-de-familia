extends GdUnitTestSuite
## Corredores delimitados con edificios/fachadas (`geometry.corridors[].facades`).
##
## P-53 y ADR 0034: las fachadas son la forma normal de delimitar un pasillo y los
## `walls` quedan soportados como legacy. Desde el 17-nov todos los JSON de
## `data/zones/` delimitan con `facades`, así que el caso legacy se construye en
## memoria a partir de las fachadas (mismos rects, otro delimitador).

const TALLER_PATH: String = "res://data/zones/taller.json"
const CUMBRE_PATH: String = "res://data/zones/cumbre.json"
const EL_ENCHUFE_PATH: String = "res://data/zones/el_enchufe.json"


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func _mount(zone_path: String) -> ZoneBase:
	return await _mount_edited(zone_path, func(_definition: ZoneDefinition) -> void: pass)


## Monta la zona con la definición editada antes de construir el mundo.
func _mount_edited(zone_path: String, edit: Callable) -> ZoneBase:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	var definition: ZoneDefinition = ZoneDefinition.load_from(zone_path)
	edit.call(definition)
	zone.set_definition(definition)
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	return zone


## Convierte en muros de pasillo (legacy) las fachadas: los mismos rects, otro
## delimitador. Ninguna zona de `data/zones/` declara ya `walls`, y el soporte
## legacy sigue cubierto por esta edición en memoria.
func _facades_to_walls(definition: ZoneDefinition) -> void:
	for corridor: Dictionary in definition.data["geometry"]["corridors"]:
		if not corridor.has("facades"):
			continue
		corridor["walls"] = corridor["facades"]
		corridor.erase("facades")


## Quita los delimitadores en memoria. Desde el ADR 0044 las 24 zonas declaran
## fachadas, así que el caso «sin delimitar» ya no existe en disco: se sintetiza
## para conservar la cobertura del comportamiento opt-in sin debilitar el test.
func _remove_delimiters(definition: ZoneDefinition) -> void:
	for corridor: Dictionary in definition.data["geometry"]["corridors"]:
		corridor.erase("facades")
		corridor.erase("walls")


## Cada rect de `facades` se monta como un edificio con colisión, del alto de los
## muros de corredor, con textura de fachada y en `actors` (y-sort).
func test_corridors_with_facades_mount_buildings_with_collision() -> void:
	var zone: ZoneBase = await _mount(TALLER_PATH)
	var definition: ZoneDefinition = zone.zone_definition()
	assert_int(definition.corridors().size()).is_greater(0)
	var expected: int = 0
	for corridor: Dictionary in definition.corridors():
		var to_zone: String = str(corridor["to"])
		var walls: Array = corridor.get("walls", [])
		assert_bool(walls.is_empty()).override_failure_message(
			"El corredor hacia %s sigue declarando muros" % to_zone).is_true()
		var rects: Array = corridor.get("facades", [])
		assert_int(rects.size()).is_greater(0).override_failure_message(
			"El corredor hacia %s no declara fachadas" % to_zone)
		expected += rects.size()
	assert_int(expected).is_greater(0)
	assert_int(zone.corridor_facades.size()).is_equal(expected)
	var placed: Array[Rect2] = []
	for facade: CorridorFacade in zone.corridor_facades:
		placed.append(facade.footprint)
		assert_float(facade.front_height).is_equal(ZoneBase.CORRIDOR_WALL_HEIGHT)
		assert_int(facade.collision_layer).is_equal(PhysicsLayers.WALLS)
		assert_int(facade.collision_mask).is_equal(0)
		assert_object(facade.texture).is_not_null()
		assert_int(_collision_shapes(facade)).is_equal(1).override_failure_message(
			"La fachada %s no tiene collider" % facade.footprint)
		assert_bool(facade.get_parent() == zone.actors).is_true().override_failure_message(
			"La fachada %s no está en actors (y-sort)" % facade.footprint)
	for corridor: Dictionary in definition.corridors():
		for rect: Rect2 in corridor.get("facades", []):
			assert_bool(placed.has(rect)).is_true().override_failure_message(
				"Falta la fachada %s del corredor hacia %s" % [rect, str(corridor["to"])])


## Las fachadas cierran el paso en NavGrid, pero el rect del corredor sigue siendo
## caminable y alcanzable desde el inicio de la zona.
func test_facade_rects_block_navigation_without_closing_the_passage() -> void:
	var zone: ZoneBase = await _mount(TALLER_PATH)
	assert_int(zone.corridor_facades.size()).is_greater(0)
	for facade: CorridorFacade in zone.corridor_facades:
		assert_bool(zone.nav.is_walkable(facade.footprint.get_center())).is_false(
			).override_failure_message(
				"NavGrid deja cruzar la fachada %s" % facade.footprint)
	for corridor: Dictionary in zone.zone_definition().corridors():
		var rect: Rect2 = corridor["rect"]
		assert_bool(zone.nav.is_walkable(rect.get_center())).is_true(
			).override_failure_message(
				"El corredor hacia %s queda tapado por sus fachadas" % str(corridor["to"]))
		var path: PackedVector2Array = zone.nav.find_path(zone.start_point(), rect.get_center())
		assert_int(path.size()).is_greater(0).override_failure_message(
			"El corredor hacia %s no es alcanzable desde el inicio" % str(corridor["to"]))


## La fachada de corredor cumple la función de muro: oculta lo que hay más allá y
## no se desvanece al acercarse el jugador, a diferencia de la fachada de un
## edificio transitable.
func test_corridor_facades_stay_opaque_when_they_hide_a_character() -> void:
	var zone: ZoneBase = await _mount(TALLER_PATH)
	assert_int(zone.corridor_facades.size()).is_greater(0)
	var facade: CorridorFacade = zone.corridor_facades[0]
	var height: float = zone.player.current_height()
	var feet: Vector2 = Vector2(facade.footprint.get_center().x, facade.footprint.end.y - 40.0)
	assert_bool(Wall.hides_character(
		facade.visual_rect(), facade.footprint.end.y, feet, height
	)).is_true().override_failure_message(
		"El caso de prueba no llega a tapar al personaje: el test no probaría nada")
	zone._update_wall_occlusion(feet, height)
	assert_float(facade.modulate.a).is_equal(1.0)


## El fondo de las bocas sur y este (ADR 0034, apartado 6) también se construye
## cuando el corredor se delimita con fachadas: se deriva de tener delimitador.
func test_facades_build_the_backdrop_of_the_south_and_east_mouths() -> void:
	var zone: ZoneBase = await _mount(TALLER_PATH)
	var expected: int = 0
	for corridor: Dictionary in zone.zone_definition().corridors():
		var edge: String = str(corridor["edge"])
		if edge != "south" and edge != "east":
			continue
		expected += 1
		var rect: Rect2 = corridor["rect"]
		var backdrop: Wall = _backdrop_at(zone, rect)
		assert_object(backdrop).is_not_null().override_failure_message(
			"Falta el fondo del corredor hacia %s" % str(corridor["to"]))
		if backdrop == null:
			continue
		assert_bool(_front_of(backdrop).is_equal_approx(rect)).is_true(
			).override_failure_message(
				"El frente del fondo hacia %s no cubre el pasillo" % str(corridor["to"]))
		assert_bool(backdrop.always_opaque).is_true()
	assert_int(expected).is_greater(0)
	assert_int(_backdrops_of(zone).size()).is_equal(expected)


## Declarar `walls` y `facades` a la vez es un error de datos: se avisa con el
## archivo y el destino, y el corredor se queda con las fachadas (forma normal).
func test_corridor_with_walls_and_facades_is_a_clear_error() -> void:
	var definition: ZoneDefinition = ZoneDefinition.load_from(TALLER_PATH)
	for corridor: Dictionary in definition.data["geometry"]["corridors"]:
		corridor["walls"] = corridor["facades"]
	var expected_error: String = (
		"%s: el corredor hacia el_enchufe declara walls y " % definition.path
		+ "facades a la vez; se delimita con facades (ADR 0034, P-53)"
	)
	var conflicted: Array[Dictionary] = []
	var check: Callable = func() -> void:
		conflicted.assign(definition.corridors())
	await assert_error(check).is_push_error(expected_error)
	assert_int(conflicted.size()).is_greater(0)
	for corridor: Dictionary in conflicted:
		assert_bool((corridor.get("walls", []) as Array).is_empty()).is_true(
			).override_failure_message(
				"El corredor hacia %s monta muros y fachadas a la vez" % str(corridor["to"]))
		assert_int((corridor.get("facades", []) as Array).size()).is_greater(0)


## Los corredores legacy con `walls` siguen montando muros que se atenúan: el
## soporte de muros no ha cambiado aunque ninguna zona los declare ya.
func test_legacy_corridors_with_walls_are_unchanged() -> void:
	var zone: ZoneBase = await _mount_edited(CUMBRE_PATH, _facades_to_walls)
	assert_int(zone.corridor_facades.size()).is_equal(0)
	var definition: ZoneDefinition = zone.zone_definition()
	var corridor_walls: Array[Wall] = _corridor_walls_of(zone, definition)
	assert_int(corridor_walls.size()).is_greater(0)
	for wall: Wall in corridor_walls:
		assert_float(wall.front_height).is_equal(ZoneBase.CORRIDOR_WALL_HEIGHT)
		assert_int(wall.collision_layer).is_equal(PhysicsLayers.WALLS)
		assert_bool(wall.kind == Wall.Kind.SOLID).is_true()
	var wall: Wall = corridor_walls[0]
	var height: float = zone.player.current_height()
	var feet: Vector2 = Vector2(wall.footprint.get_center().x, wall.footprint.end.y - 40.0)
	assert_bool(Wall.hides_character(
		wall.visual_rect(), wall.footprint.end.y, feet, height
	)).is_true().override_failure_message(
		"El caso de prueba no llega a tapar al personaje: el test no probaría nada")
	zone._update_wall_occlusion(feet, height)
	assert_float(wall.modulate.a).is_equal_approx(Wall.FADED_ALPHA, 0.001)


## Sin delimitadores no hay fachadas ni fondo: el cambio sigue siendo opt-in.
## El caso se construye en memoria porque el ADR 0044 ya delimita las 24 zonas.
func test_zones_without_corridor_delimiters_have_no_facades() -> void:
	var zone: ZoneBase = await _mount_edited(EL_ENCHUFE_PATH, _remove_delimiters)
	assert_int(zone.corridor_facades.size()).is_equal(0)
	assert_int(_backdrops_of(zone).size()).is_equal(0)
	for corridor: Dictionary in zone.zone_definition().corridors():
		assert_bool((corridor.get("walls", []) as Array).is_empty()).is_true()
		assert_bool((corridor.get("facades", []) as Array).is_empty()).is_true()


## Colliders de un nodo: la fachada tiene que traer el suyo, como un muro.
func _collision_shapes(node: Node) -> int:
	var count: int = 0
	for child: Node in node.get_children():
		if child is CollisionShape2D:
			count += 1
	return count


## Muros de pasillo de la zona (los que corresponden a rects de `walls`).
func _corridor_walls_of(zone: ZoneBase, definition: ZoneDefinition) -> Array[Wall]:
	var rects: Array[Rect2] = []
	for corridor: Dictionary in definition.corridors():
		for rect: Rect2 in corridor.get("walls", []):
			rects.append(rect)
	var result: Array[Wall] = []
	for wall: Wall in zone.walls:
		if rects.has(wall.footprint):
			result.append(wall)
	return result


## Fondo de la boca cuyo rect es `rect`: el muro BACKDROP cuyo frente lo cubre.
func _backdrop_at(zone: ZoneBase, rect: Rect2) -> Wall:
	for wall: Wall in _backdrops_of(zone):
		if _front_of(wall).is_equal_approx(rect):
			return wall
	return null


func _backdrops_of(zone: ZoneBase) -> Array[Wall]:
	var result: Array[Wall] = []
	for wall: Wall in zone.walls:
		if wall.kind == Wall.Kind.BACKDROP:
			result.append(wall)
	return result


## Rectángulo que dibuja el frente de un muro: su huella elevada `front_height`.
func _front_of(wall: Wall) -> Rect2:
	return Rect2(
		wall.footprint.position.x, wall.footprint.end.y - wall.front_height,
		wall.footprint.size.x, wall.front_height
	)
