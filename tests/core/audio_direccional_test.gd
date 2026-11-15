extends GdUnitTestSuite
## P-29: buses de audio, timbre de cada IA y oclusión de los pasos por muro.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"


func before_test() -> void:
	TestSupport.reset_session()
	AudioMixer.ensure_buses()


func after_test() -> void:
	AudioMixer.ensure_buses()


func test_se_crean_los_buses_de_pasos_y_de_timbre() -> void:
	for bus: StringName in [
		AudioMixer.BUS_MUSIC, AudioMixer.BUS_VOICES, AudioMixer.BUS_STEPS,
		AudioMixer.BUS_STEPS_MUFFLED, AudioMixer.BUS_VOICE_RADIO,
		AudioMixer.BUS_VOICE_ECHO, AudioMixer.BUS_VOICE_DISTORTED,
	]:
		assert_int(AudioServer.get_bus_index(bus)).is_greater_equal(0).override_failure_message(
			"Falta el bus %s" % bus
		)


func test_los_buses_de_timbre_tienen_su_filtro() -> void:
	assert_int(_efectos(AudioMixer.BUS_VOICE_RADIO)).is_greater(0)
	assert_int(_efectos(AudioMixer.BUS_VOICE_ECHO)).is_greater(0)
	assert_int(_efectos(AudioMixer.BUS_VOICE_DISTORTED)).is_greater(0)
	assert_int(_efectos(AudioMixer.BUS_STEPS_MUFFLED)).is_greater(0)


func test_cada_timbre_manda_a_su_bus() -> void:
	assert_str(str(AudioMixer.bus_for_timbre(AudioMixer.TIMBRE_NORMAL))).is_equal(
		str(AudioMixer.BUS_VOICES)
	)
	assert_str(str(AudioMixer.bus_for_timbre(AudioMixer.TIMBRE_RADIO))).is_equal(
		str(AudioMixer.BUS_VOICE_RADIO)
	)
	assert_str(str(AudioMixer.bus_for_timbre(AudioMixer.TIMBRE_ECHO))).is_equal(
		str(AudioMixer.BUS_VOICE_ECHO)
	)
	assert_str(str(AudioMixer.bus_for_timbre(AudioMixer.TIMBRE_DISTORTED))).is_equal(
		str(AudioMixer.BUS_VOICE_DISTORTED)
	)
	assert_str(str(AudioMixer.bus_for_timbre("inventado"))).is_equal(
		str(AudioMixer.BUS_VOICES)
	)


func test_los_pasos_tienen_bus_propio_y_el_tapado_otro() -> void:
	assert_str(str(AudioMixer.bus_for_steps(false))).is_equal(str(AudioMixer.BUS_STEPS))
	assert_str(str(AudioMixer.bus_for_steps(true))).is_equal(str(AudioMixer.BUS_STEPS_MUFFLED))


func test_todas_las_ias_tienen_timbre_conocido() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://data/ai/personalities.json"
	))
	assert_bool(data is Dictionary).is_true()
	var ais: Dictionary = (data as Dictionary)["ais"]
	for id: String in ais:
		var timbre: String = str((ais[id] as Dictionary).get("timbre", ""))
		assert_bool(AudioMixer.TIMBRES.has(timbre)).is_true().override_failure_message(
			"La IA %s no tiene un timbre válido: «%s»" % [id, timbre]
		)


func test_hay_ias_de_cada_timbre() -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://data/ai/personalities.json"
	))
	var ais: Dictionary = (data as Dictionary)["ais"]
	for timbre: String in AudioMixer.TIMBRES:
		var cuantas: int = 0
		for id: String in ais:
			if str((ais[id] as Dictionary).get("timbre", "")) == timbre:
				cuantas += 1
		assert_int(cuantas).is_greater(0).override_failure_message(
			"Ninguna IA tiene el timbre %s" % timbre
		)


func test_la_voz_cambia_de_bus_segun_el_timbre() -> void:
	var voz: BlablaVoice = auto_free(BlablaVoice.new())
	add_child(voz)
	await get_tree().process_frame
	voz.speak(1.0, "panico", AudioMixer.TIMBRE_RADIO)
	assert_str(str(voz.bus)).is_equal(str(AudioMixer.BUS_VOICE_RADIO))
	voz.speak(1.0, "panico", AudioMixer.TIMBRE_ECHO)
	assert_str(str(voz.bus)).is_equal(str(AudioMixer.BUS_VOICE_ECHO))
	voz.speak(1.0, "panico", AudioMixer.TIMBRE_DISTORTED)
	assert_str(str(voz.bus)).is_equal(str(AudioMixer.BUS_VOICE_DISTORTED))
	voz.speak(1.0, "panico", AudioMixer.TIMBRE_NORMAL)
	assert_str(str(voz.bus)).is_equal(str(AudioMixer.BUS_VOICES))


func test_la_radio_se_desajusta_al_hablar() -> void:
	var voz: BlablaVoice = auto_free(BlablaVoice.new())
	add_child(voz)
	await get_tree().process_frame
	var ajustes: Array[float] = []
	for intento: int in range(12):
		voz.speak(1.0, "panico", AudioMixer.TIMBRE_RADIO)
		ajustes.append(voz.pitch_scale)
	var distintos: bool = false
	for valor: float in ajustes:
		if not is_equal_approx(valor, ajustes[0]):
			distintos = true
	assert_bool(distintos).is_true()


func test_el_timbre_normal_no_desajusta_el_tono() -> void:
	var voz: BlablaVoice = auto_free(BlablaVoice.new())
	add_child(voz)
	await get_tree().process_frame
	var ajustes: Array[float] = []
	for _intento: int in range(12):
		voz.speak(1.0, "panico", AudioMixer.TIMBRE_NORMAL)
		ajustes.append(voz.pitch_scale)
	for valor: float in ajustes:
		assert_float(valor).is_equal(ajustes[0])


func test_un_paso_detras_de_un_muro_suena_tapado() -> void:
	var oyente: Node2D = auto_free(Node2D.new())
	add_child(oyente)
	var pasos: FootstepAudio = auto_free(load("res://audio/footstep_audio.gd").new())
	pasos.listener = oyente
	pasos.occludable = true
	pasos.position = Vector2(600.0, 0.0)
	add_child(pasos)
	var muro: StaticBody2D = auto_free(_muro(Vector2(300.0, 0.0)))
	add_child(muro)
	await get_tree().process_frame
	assert_bool(pasos.is_muffled()).is_true().override_failure_message(
		"El paso debería sonar tapado: hay un muro en medio"
	)


func test_sin_muro_el_paso_no_suena_tapado() -> void:
	var oyente: Node2D = auto_free(Node2D.new())
	add_child(oyente)
	var pasos: FootstepAudio = auto_free(load("res://audio/footstep_audio.gd").new())
	pasos.listener = oyente
	pasos.occludable = true
	pasos.position = Vector2(600.0, 0.0)
	add_child(pasos)
	await get_tree().process_frame
	assert_bool(pasos.is_muffled()).is_false().override_failure_message(
		"No hay muro: el paso debería sonar claro"
	)


func test_el_jugador_no_tiene_oclusion() -> void:
	var zone: DespliegueCeroZone = scene_runner(PATH).scene()
	await get_tree().process_frame
	var pasos: FootstepAudio = _pasos_del_jugador(zone)
	assert_object(pasos).is_not_null()
	assert_bool(pasos.occludable).is_false()


func test_el_guardia_tiene_oclusion_y_oye_al_jugador() -> void:
	var zone: DespliegueCeroZone = scene_runner(PATH).scene()
	await get_tree().process_frame
	var pasos: FootstepAudio = _pasos_de_guardia(zone)
	assert_object(pasos).is_not_null()
	assert_bool(pasos.occludable).is_true()
	assert_object(pasos.listener).is_equal(zone.player)


func _muro(at: Vector2) -> StaticBody2D:
	var muro: StaticBody2D = StaticBody2D.new()
	muro.collision_layer = PhysicsLayers.WALLS
	muro.collision_mask = 0
	var forma: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(40.0, 400.0)
	forma.shape = rect
	muro.add_child(forma)
	muro.position = at
	return muro


func _pasos_de_guardia(zone: DespliegueCeroZone) -> FootstepAudio:
	for guard: Guard in zone.guards():
		for hijo: Node in guard.get_children():
			if hijo is FootstepAudio:
				return hijo as FootstepAudio
	return null


func _pasos_del_jugador(zone: DespliegueCeroZone) -> FootstepAudio:
	for hijo: Node in zone.player.get_children():
		if hijo is FootstepAudio:
			return hijo as FootstepAudio
	return null


func _efectos(bus: StringName) -> int:
	var index: int = AudioServer.get_bus_index(bus)
	if index < 0:
		return 0
	return AudioServer.get_bus_effect_count(index)
