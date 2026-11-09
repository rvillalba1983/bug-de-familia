extends GdUnitTestSuite
## Biblioteca de música y voces, y elección según la situación.

const PATH: String = "res://scenes/beta/beta_zone.tscn"

var zone: BetaZone


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	zone = scene_runner(PATH).scene()
	zone.set_enemies_active(false)


func after_test() -> void:
	BetaZone.forced_hour = -1
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
