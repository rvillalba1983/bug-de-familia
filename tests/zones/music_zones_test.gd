extends GdUnitTestSuite
## Música de las 24 zonas: catálogo zonal (69 pistas), director en zona genérica,
## día/noche por calendario y biblioteca original para combate y festival.
##
## Las 23 zonas genéricas tienen tres pistas `cuerda_zonal` (día, noche y tensión);
## `despliegue_cero` conserva sus diez cues `cuerda_pulsada` y su propio barrio.

const ZONES_PATH: String = "res://data/zones/"
const LIBRARY_PATH: String = MusicDirector.DATA_PATH
const BETA_ZONE: String = "despliegue_cero"
## 15 ene 2026 a las 11:00 local, sin festividad: el día que usa music_test.
const DAY_UNIX: int = 1768474800
## El mismo día a las 22:00: dentro del umbral de noche (21:00-08:00).
const NIGHT_UNIX: int = 1768514400
const ZONAL_STATES: Array[String] = ["dia", "noche", "tension"]


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}
	WorldCalendar.forced_local_unix = DAY_UNIX


func after_test() -> void:
	WorldCalendar.forced_local_unix = -1
	get_tree().paused = false


func _zone_ids() -> Array[String]:
	var result: Array[String] = []
	var directory: DirAccess = DirAccess.open(ZONES_PATH)
	assert_object(directory).is_not_null()
	for file_name: String in directory.get_files():
		if file_name.ends_with(".json"):
			result.append(file_name.trim_suffix(".json"))
	result.sort()
	return result


func _generic_zone_ids() -> Array[String]:
	var result: Array[String] = []
	for id: String in _zone_ids():
		if id != BETA_ZONE:
			result.append(id)
	return result


func _tracks() -> Array:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY_PATH))
	assert_bool(data is Dictionary).is_true().override_failure_message(
		"Biblioteca ilegible: %s" % LIBRARY_PATH)
	if not data is Dictionary:
		return []
	return (data as Dictionary)["tracks"]


func _zonal_tracks() -> Array:
	var result: Array = []
	for track: Dictionary in _tracks():
		if str(track.get("palette", "")) == MusicDirector.PALETTE_ZONAL:
			result.append(track)
	return result


func _zonal_of(zone_id: String) -> Array:
	var result: Array = []
	for track: Dictionary in _zonal_tracks():
		if str(track["zone"]) == zone_id:
			result.append(track)
	return result


func _mount(zone_id: String) -> ZoneBase:
	var zone: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	zone.set_definition(ZoneDefinition.load_from(ZONES_PATH + zone_id + ".json"))
	zone.world_mode = true
	add_child(zone)
	await get_tree().process_frame
	return zone


## Las 23 zonas genéricas declaran exactamente día, noche y tensión en la paleta
## zonal; ninguna es de cualquier zona (cada pista es de su zona).
func test_el_catalogo_zonal_cubre_las_23_zonas_genericas() -> void:
	var ids: Array[String] = _generic_zone_ids()
	assert_int(ids.size()).is_equal(23)
	var zonal: Array = _zonal_tracks()
	assert_int(zonal.size()).is_equal(ids.size() * ZONAL_STATES.size())
	for id: String in ids:
		var tracks: Array = _zonal_of(id)
		assert_int(tracks.size()).is_equal(3).override_failure_message(
			"%s no tiene tres pistas zonales" % id)
		var estados: Array[String] = []
		for track: Dictionary in tracks:
			assert_str(str(track["zone"])).is_equal(id).override_failure_message(
				"Pista zonal con zona ajena: %s" % str(track["file"]))
			assert_bool(bool(track["any_zone"])).is_false().override_failure_message(
				"%s: la pista %s es de cualquier zona" % [id, str(track["file"])])
			estados.append(str(track["state"]))
		for state: String in ZONAL_STATES:
			assert_bool(estados.has(state)).is_true().override_failure_message(
				"%s no tiene pista zonal para %s" % [id, state])


## Forma de cada pista zonal: archivo real y único, sin confundirse con los cues
## `cuerda_`, ambiente solo en calma y bpm final igual al inicial, +18 en tensión.
func test_las_pistas_zonales_estan_bien_formadas() -> void:
	var ids: Array[String] = _generic_zone_ids()
	var archivos: Dictionary = {}
	var revisadas: int = 0
	for track: Dictionary in _zonal_tracks():
		revisadas += 1
		var zone_id: String = str(track["zone"])
		var state: String = str(track["state"])
		var file: String = str(track["file"])
		assert_bool(ids.has(zone_id)).is_true().override_failure_message(
			"Pista zonal de una zona desconocida: %s" % file)
		assert_bool(ResourceLoader.exists(file)).is_true().override_failure_message(
			"Falta el archivo %s" % file)
		assert_bool(archivos.has(file)).is_false().override_failure_message(
			"Archivo repetido en el catálogo zonal: %s" % file)
		archivos[file] = true
		assert_bool(file.get_file().begins_with("cuerda_")).is_false(
			).override_failure_message("La pista zonal %s usa el nombre de un cue" % file)
		assert_bool(bool(track["ambient"]) == (state != "tension")).is_true(
			).override_failure_message(
			"%s: ambiente incoherente con el estado %s" % [file, state])
		var bpm: float = float(track["bpm"])
		var bpm_fin: float = float(track["bpm_fin"])
		if state == "tension":
			assert_float(bpm_fin).is_equal_approx(bpm + 18.0, 0.01).override_failure_message(
				"%s: la tensión debería subir 18 bpm (%s → %s)" % [file, bpm, bpm_fin])
		else:
			assert_float(bpm_fin).is_equal_approx(bpm, 0.01).override_failure_message(
				"%s: en calma el bpm no debe cambiar (%s → %s)" % [file, bpm, bpm_fin])
	assert_int(revisadas).is_equal(69)


## La zona genérica monta un único director, apunta a la zona y elige su pista
## zonal (no la original ni la de otro barrio).
func test_una_zona_generica_monta_un_unico_director_zonal() -> void:
	var zone: ZoneBase = await _mount("el_enchufe")
	assert_object(zone.music).is_not_null()
	if zone.music == null:
		return
	assert_bool(zone.music.level == zone).is_true().override_failure_message(
		"El director no apunta a su zona")
	assert_str(zone.music.zone()).is_equal("el_enchufe")
	assert_str(str(zone.music.pick("dia", "el_enchufe")["zone"])).is_equal("el_enchufe")
	var directores: int = 0
	for child: Node in zone.get_children():
		if child is MusicDirector:
			directores += 1
	assert_int(directores).is_equal(1).override_failure_message(
		"La zona monta %d directores de música" % directores)


## Día y noche salen del calendario de la zona: 11:00 es día y 22:00 es noche,
## sin festividad (el 15 de enero no tiene fiesta).
func test_la_hora_del_calendario_decide_dia_y_noche() -> void:
	WorldCalendar.forced_local_unix = DAY_UNIX
	var zone: ZoneBase = await _mount("el_enchufe")
	assert_bool(zone.is_night()).is_false()
	assert_str(zone.music.situation()).is_equal("dia")
	WorldCalendar.forced_local_unix = NIGHT_UNIX
	assert_bool(zone.is_night()).is_true()
	assert_str(zone.music.situation()).is_equal("noche")


## Combate y festival siguen tirando de la biblioteca original: la paleta zonal
## es solo para calma y tensión.
func test_combate_y_festival_siguen_usando_la_biblioteca_original() -> void:
	var zone: ZoneBase = await _mount("el_enchufe")
	for id: String in _generic_zone_ids():
		for state: String in ["combate", "festival"]:
			var track: Dictionary = zone.music.pick(state, id)
			assert_str(str(track["state"])).is_equal(state).override_failure_message(
				"%s: estado equivocado para %s" % [id, state])
			var palette: String = str(track.get("palette", ""))
			assert_str(palette).is_equal("original").override_failure_message(
				"%s: %s no usa la biblioteca original (%s)" % [
					id, state, str(track["file"])])


## La tensión de cada zona genérica es siempre su propio cue zonal: con la
## preferencia por la zona activa, no entra ninguna de las cues compartidas.
func test_la_tension_de_cada_zona_usa_su_propio_cue() -> void:
	var zone: ZoneBase = await _mount("el_enchufe")
	assert_object(zone.music).is_not_null()
	if zone.music == null:
		return
	assert_bool(zone.music_prefers_own_zone()).is_true().override_failure_message(
		"La zona genérica no prefiere su propia música")
	for id: String in _generic_zone_ids():
		zone.music._rng.seed = MusicDirector.RNG_SEED
		zone.music._recent.clear()
		var track: Dictionary = zone.music.pick("tension", id)
		assert_str(str(track["zone"])).is_equal(id).override_failure_message(
			"%s: la tensión usa una pista de otra zona (%s)" % [id, str(track["file"])])
		var palette: String = str(track.get("palette", ""))
		assert_str(palette).is_equal(MusicDirector.PALETTE_ZONAL).override_failure_message(
			"%s: la tensión no usa la paleta zonal (%s)" % [id, str(track["file"])])
