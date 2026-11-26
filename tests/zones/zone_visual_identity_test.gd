extends GdUnitTestSuite
## Identidad visual de las 24 zonas (ADR 0044): suelo, tinte, fachadas propias
## y carteles. Comprueba los datos y la escena sin depender del renders.

const ZONES_PATH: String = "res://data/zones/"
## Las 16 zonas sin cartel declarado antes del 26-nov (incluye despliegue_cero).
const SIGNED_ZONES: Array[String] = [
	"despliegue_cero", "antecamara", "archivo", "asamblea", "atajo", "camara",
	"camino", "canon", "cementerio", "colmena", "el_enchufe", "instalacion",
	"lonja", "sendero", "ultima_ruta", "valle",
]


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func _zone_ids() -> Array[String]:
	var result: Array[String] = []
	var directory: DirAccess = DirAccess.open(ZONES_PATH)
	assert_object(directory).is_not_null()
	for file_name: String in directory.get_files():
		if file_name.ends_with(".json"):
			result.append(file_name.trim_suffix(".json"))
	result.sort()
	return result


func _zone_data(id: String) -> Dictionary:
	var path: String = ZONES_PATH + id + ".json"
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	assert_object(file).is_not_null().override_failure_message("Falta %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	assert_bool(parsed is Dictionary).is_true()
	return parsed as Dictionary


## Las 24 zonas tienen bioma, tinte y cuatro fachadas propias declaradas.
func test_all_zones_have_declared_floor_and_four_facades() -> void:
	var ids: Array[String] = _zone_ids()
	assert_int(ids.size()).is_equal(24)
	for id: String in ids:
		assert_bool(ZoneBase.FLOOR_ART_BY_ZONE.has(id)).is_true().override_failure_message(
			"%s no tiene suelo declarado" % id)
		var art: Array = ZoneBase.FLOOR_ART_BY_ZONE[id]
		assert_bool(ZoneBase.FLOOR_TEXTURES.has(str(art[0]))).is_true(
			).override_failure_message("%s usa un bioma sin textura" % id)
		assert_bool(art[1] is Color).is_true()
		assert_int(ZoneBase.CORRIDOR_FACADE_ART_BY_ZONE.get(id, []).size()).is_equal(4
			).override_failure_message("%s no tiene cuatro fachadas propias" % id)


## Los carteles declarados son los mismos que ya elegía el fallback por destino:
## se explicitan en el JSON sin cambiar lo que se veía en partida.
func test_declared_signs_match_the_existing_fallback() -> void:
	for id: String in SIGNED_ZONES:
		var data: Dictionary = _zone_data(id)
		for corridor: Dictionary in data["geometry"]["corridors"]:
			var sign_id: String = str(corridor.get("sign", ""))
			var expected: String = ZoneBase.SIGN_PREFIX + "%02d" % (
				posmod(hash(str(corridor["to"])), ZoneBase.SIGN_COUNT) + 1)
			assert_str(sign_id).is_equal(expected).override_failure_message(
				"%s → %s: cartel declarado %s, fallback %s" % [
					id, corridor["to"], sign_id, expected])
			assert_bool(FileAccess.file_exists("res://art/shared/fuentes/%s.svg" % sign_id)
				).is_true().override_failure_message("Falta el SVG %s" % sign_id)


## Ningún corredor se queda sin delimitar: las 24 zonas usan fachadas y no muros.
func test_every_zone_corridor_is_delimited_by_facades() -> void:
	for id: String in _zone_ids():
		var data: Dictionary = _zone_data(id)
		var corridors: Array = data["geometry"]["corridors"]
		assert_int(corridors.size()).is_greater(0).override_failure_message(
			"%s no tiene corredores" % id)
		for corridor: Dictionary in corridors:
			assert_bool((corridor.get("facades", []) as Array).size() >= 2).is_true(
				).override_failure_message(
					"El corredor hacia %s en %s no tiene fachadas" % [corridor["to"], id])
			assert_bool((corridor.get("walls", []) as Array).is_empty()).is_true(
				).override_failure_message("%s sigue usando muros legacy" % id)


## Las bocas siguen transitables y alcanzables tras delimitar las 15 zonas nuevas.
func test_new_facades_keep_every_corridor_walkable() -> void:
	var ids: Array[String] = [
		"antecamara", "archivo", "asamblea", "atajo", "camara", "camino", "canon",
		"cementerio", "colmena", "el_enchufe", "instalacion", "lonja", "sendero",
		"ultima_ruta", "valle",
	]
	for id: String in ids:
		var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
		zone.set_definition(ZoneDefinition.load_from(ZONES_PATH + id + ".json"))
		zone.world_mode = true
		add_child(zone)
		await get_tree().process_frame
		assert_int(zone.corridor_facades.size()).is_greater(0).override_failure_message(
			"%s no montó fachadas" % id)
		for corridor: Dictionary in zone.zone_definition().corridors():
			var rect: Rect2 = corridor["rect"]
			assert_bool(zone.nav.is_walkable(rect.get_center())).is_true(
				).override_failure_message(
					"El corredor hacia %s en %s quedó tapado" % [corridor["to"], id])
			var path: PackedVector2Array = zone.nav.find_path(zone.start_point(), rect.get_center())
			assert_int(path.size()).is_greater(0).override_failure_message(
				"El corredor hacia %s en %s no es alcanzable" % [corridor["to"], id])
