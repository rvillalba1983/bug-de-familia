extends GdUnitTestSuite
## P-32: el tema del canal solo enseña los retos conocidos y no completados.

const PATH: String = "res://scenes/despliegue_cero/despliegue_cero_zone.tscn"

var zone: DespliegueCeroZone
var runner: GdUnitSceneRunner


func before_test() -> void:
	TestSupport.reset_session()
	DespliegueCeroZone.forced_hour = 12
	runner = scene_runner(PATH)
	zone = runner.scene()


func after_test() -> void:
	Engine.time_scale = 1.0
	DespliegueCeroZone.forced_hour = -1
	get_tree().paused = false


func _reto(id: String) -> String:
	return String(zone.tr({
		DespliegueCeroChallenges.ENTER: "ZONE_RETO_ENTRAR",
		DespliegueCeroChallenges.EXTRACT: "ZONE_RETO_SACAR",
		DespliegueCeroChallenges.CROSS: "ZONE_RETO_CRUZAR",
		DespliegueCeroChallenges.FIND: "ZONE_RETO_ENCONTRAR",
	}.get(id, "")))


func test_al_empezar_el_tema_no_enseña_la_lista_de_retos() -> void:
	var topic: String = zone.chat_topic()
	assert_str(topic).is_equal(zone.tr("ZONE_OBJECTIVE"))
	assert_bool(topic.contains(_reto(DespliegueCeroChallenges.ENTER))).is_false()


func test_hablar_marca_el_primer_reto_desconocido() -> void:
	zone.discover_challenge()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.ENTER)).is_true()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.EXTRACT)).is_false()


func test_cada_conversacion_enseña_un_reto_nuevo() -> void:
	zone.discover_challenge()
	zone.discover_challenge()
	zone.discover_challenge()
	zone.discover_challenge()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.ENTER)).is_true()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.EXTRACT)).is_true()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.CROSS)).is_true()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.FIND)).is_true()


func test_el_tema_enseña_solo_los_conocidos() -> void:
	zone.discover_challenge()
	var topic: String = zone.chat_topic()
	assert_bool(topic.contains(_reto(DespliegueCeroChallenges.ENTER))).is_true()
	assert_bool(topic.contains(_reto(DespliegueCeroChallenges.EXTRACT))).is_false()


func test_el_tema_no_enseña_un_reto_completado() -> void:
	zone.investigation.set_flag(DespliegueCeroChallenges.ENTER)
	zone.discover_challenge()
	var topic: String = zone.chat_topic()
	assert_bool(topic.contains(_reto(DespliegueCeroChallenges.ENTER))).is_false()


func test_el_reto_completado_desaparece_de_la_lista() -> void:
	zone.discover_challenge()
	assert_bool(zone.chat_topic().contains(_reto(DespliegueCeroChallenges.ENTER))).is_true()
	zone.challenges._complete(DespliegueCeroChallenges.ENTER)
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.ENTER)).is_false()
	assert_bool(zone.chat_topic().contains(_reto(DespliegueCeroChallenges.ENTER))).is_false()


func test_el_tema_vuelve_al_objetivo_generico_cuando_no_queda_nada() -> void:
	for id: String in DespliegueCeroChallenges.ALL_CHALLENGES:
		zone.investigation.set_flag(id)
	zone.discover_challenge()
	assert_str(zone.chat_topic()).is_equal(zone.tr("ZONE_OBJECTIVE"))


func test_los_retos_conocidos_se_guardan_y_se_recargan() -> void:
	zone.discover_challenge()
	zone.discover_challenge()
	var guardado: Dictionary = zone.investigation.to_dict()
	assert_bool((guardado["known"] as Array).has(DespliegueCeroChallenges.ENTER)).is_true()
	assert_bool((guardado["known"] as Array).has(DespliegueCeroChallenges.EXTRACT)).is_true()
	zone.investigation.restore({})
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.ENTER)).is_false()
	zone.investigation.restore(guardado)
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.ENTER)).is_true()
	assert_bool(zone.investigation.has_known(DespliegueCeroChallenges.EXTRACT)).is_true()


func test_una_zona_sin_retos_muestra_el_objetivo_generico() -> void:
	var base: ZoneBase = auto_free(load("res://scenes/zones/zone.tscn").instantiate())
	base.set_definition(ZoneDefinition.load_from("res://data/zones/el_enchufe.json"))
	base.world_mode = true
	add_child(base)
	await get_tree().process_frame
	assert_str(base.chat_topic()).is_equal(base.tr("ZONE_OBJECTIVE"))
	base.discover_challenge()
	assert_bool(base.investigation.has_known(DespliegueCeroChallenges.ENTER)).is_false()
