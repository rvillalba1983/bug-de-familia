extends GdUnitTestSuite
## Biblioteca de música y voces, y elección según la situación.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"

var zone: DespliegueCeroZone


func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	# Dia sin festividad para que la situacion inicial sea "dia" (P-39, determinismo).
	WorldCalendar.forced_local_unix = 1768474800
	zone = scene_runner(PATH).scene()
	zone.set_enemies_active(false)


func after_test() -> void:
	DespliegueCeroZone.forced_hour = -1
	WorldCalendar.forced_local_unix = -1
	get_tree().paused = false


func _library() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(MusicDirector.DATA_PATH))


func test_hay_cien_pistas_y_todas_existen() -> void:
	var tracks: Array = _library()["tracks"]
	assert_int(tracks.size()).is_greater_equal(100)
	for track: Dictionary in tracks:
		assert_bool(ResourceLoader.exists(str(track["file"]))).override_failure_message(str(track["file"])).is_true()


func test_toda_situacion_y_barrio_tiene_musica() -> void:
	for state: String in ["dia", "noche", "tension", "combate", "festival"]:
		for where: String in ["bosque", "barrio_jubilado", "barrio_mohocrata", "tierra_de_nadie"]:
			assert_str(str(zone.music.pick(state, where)["state"])).is_equal(state)


## El barrio de música de la zona sigue derivándose de la posición del jugador
## (ahora en `DespliegueCeroZone.music_zone()`): los cuatro rects del layout.
func test_el_barrio_de_musica_sigue_los_cuatro_rects_del_layout() -> void:
	var casos: Array = [
		[DespliegueCeroLayout.north_quarter, "barrio_jubilado"],
		[DespliegueCeroLayout.south_quarter, "barrio_mohocrata"],
		[DespliegueCeroLayout.no_mans_land, "tierra_de_nadie"],
	]
	var previos: Array[Rect2] = []
	for caso: Array in casos:
		var rect: Rect2 = caso[0]
		var centro: Vector2 = rect.get_center()
		assert_bool(rect.has_point(centro)).is_true()
		for previo: Rect2 in previos:
			assert_bool(previo.has_point(centro)).is_false().override_failure_message(
				"El centro de %s cae en un rect que se comprueba antes" % str(caso[1]))
		previos.append(rect)
		zone.player.global_position = centro
		assert_str(zone.music_zone()).is_equal(str(caso[1]))
		assert_str(zone.music.zone()).is_equal(str(caso[1]))
	var inicio: Vector2 = zone.start_point()
	for rect: Rect2 in previos:
		assert_bool(rect.has_point(inicio)).is_false().override_failure_message(
			"El inicio de la zona cae dentro de un barrio con música")
	zone.player.global_position = inicio
	assert_str(zone.music_zone()).is_equal("bosque")
	assert_str(zone.music.zone()).is_equal("bosque")


func test_diez_cues_de_cuerda_estan_bien_formados() -> void:
	var estados: Dictionary = {}
	var total: int = 0
	for track: Dictionary in _library()["tracks"]:
		if str(track.get("palette", "")) != MusicDirector.PALETTE_CUERDA:
			continue
		total += 1
		estados[str(track["state"])] = true
		assert_bool(["guitarra", "laud", "oud", "shamisen"].has(str(track["lead"]))).is_true()
		assert_bool(ResourceLoader.exists(str(track["file"]))).is_true()
		assert_bool(bool(track["ambient"]) == (str(track["state"]) != "tension")).is_true()
		assert_bool(float(track["bpm_fin"]) >= float(track["bpm"])).is_true()
		if str(track["state"]) == "tension":
			assert_bool(float(track["bpm_fin"]) > float(track["bpm"])).is_true()
	assert_int(total).is_equal(10)
	for state: String in ["dia", "noche", "tension"]:
		assert_bool(estados.has(state)).is_true()


func test_la_cuerda_se_prefiere_en_calma_y_tension() -> void:
	var tracks: Array = _library()["tracks"]
	for state: String in ["dia", "noche", "tension"]:
		for where: String in ["bosque", "barrio_jubilado", "barrio_mohocrata", "tierra_de_nadie"]:
			var hay_cuerda: bool = false
			for track: Dictionary in tracks:
				if str(track["state"]) == state \
					and (bool(track["any_zone"]) or str(track["zone"]) == where) \
					and str(track.get("palette", "")) == MusicDirector.PALETTE_CUERDA:
					hay_cuerda = true
					break
			if not hay_cuerda:
				continue
			assert_str(str(zone.music.pick(state, where)["palette"])).is_equal(
				MusicDirector.PALETTE_CUERDA)


func test_la_seleccion_de_cuerda_es_reproducible() -> void:
	zone.music._recent.clear()
	zone.music._rng.seed = MusicDirector.RNG_SEED
	var primera: Dictionary = zone.music.pick("dia", "bosque")
	zone.music._recent.clear()
	zone.music._rng.seed = MusicDirector.RNG_SEED
	var segunda: Dictionary = zone.music.pick("dia", "bosque")
	assert_str(str(segunda["file"])).is_equal(str(primera["file"]))
	assert_str(str(primera["palette"])).is_equal(MusicDirector.PALETTE_CUERDA)


func test_no_repite_las_ultimas_pistas() -> void:
	var seen: Dictionary = {}
	for index: int in range(MusicDirector.RECENT_SIZE):
		zone.music._play("dia")
		var file: String = zone.music.current_track["file"]
		assert_bool(seen.has(file)).is_false()
		seen[file] = true


func test_la_batalla_pone_musica_de_combate() -> void:
	assert_str(zone.music.situation()).is_equal("dia")
	assert_bool(zone.battles.begin()).is_true()
	zone.battles.choose(3)
	assert_str(zone.music.situation()).is_equal("combate")


func test_cada_ia_tiene_voz_estable() -> void:
	var voice: BlablaVoice = zone.ai.voice
	voice.speak(1.0, "panico")
	assert_object(voice.stream).is_instanceof(AudioStream)
	assert_bool(voice.stream is AudioStreamWAV).is_false()
