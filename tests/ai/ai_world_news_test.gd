extends GdUnitTestSuite
## P-59: avisos de mundo de las IAs. La IA temática habla si está activa, el
## aviso no gasta tokens, respeta la cadencia y no inunda el chat.

const SANDBOX_PATH: String = "res://scenes/sandbox/sandbox.tscn"


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _scene() -> Sandbox:
	var runner: GdUnitSceneRunner = scene_runner(SANDBOX_PATH)
	var sandbox: Sandbox = runner.scene()
	sandbox.set_enemies_active(false)
	return sandbox


func _force_active(sandbox: Sandbox, ids: Array) -> void:
	sandbox.ai.team.active = ids
	sandbox.ai.team.muted.clear()


func test_rumor_news_is_spoken_by_conspi() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["conspi", "panico", "mama"])
	assert_bool(sandbox.ai.announce_rumor(7, "Paco vendió un tornillo")).is_true()
	var entry: Dictionary = sandbox.ai.pending()[0]
	assert_str(str(entry["id"])).is_equal("conspi")
	assert_bool(bool(entry["free"])).is_true()
	assert_str(str(entry["text"])).contains("Paco vendió un tornillo")


func test_migration_news_is_spoken_by_matriz_with_names() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["matriz", "panico", "mama"])
	assert_bool(sandbox.ai.announce_migration(
		"cumbre", "La Cumbre", "jubilado", "Jubilados", 2
	)).is_true()
	var text: String = str(sandbox.ai.pending()[0]["text"])
	assert_str(text).contains("Jubilados")
	assert_str(text).contains("La Cumbre")
	assert_str(text).contains("entran en")


func test_news_falls_back_to_an_active_ai() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["panico", "mama", "arbitro"])
	assert_bool(sandbox.ai.announce_rumor(8, "algo ha pasado")).is_true()
	var speaker: String = str(sandbox.ai.pending()[0]["id"])
	assert_bool(["panico", "mama", "arbitro"].has(speaker)).is_true()


func test_news_does_not_spend_tokens() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["conspi", "panico", "mama"])
	var before: float = sandbox.ai.team.tokens["conspi"]
	sandbox.ai.announce_rumor(9, "un rumor cualquiera")
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_float(sandbox.ai.team.tokens["conspi"]).is_equal(before)


func test_news_respects_its_cadence_and_does_not_repeat() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["conspi", "panico", "mama"])
	assert_bool(sandbox.ai.announce_rumor(10, "primero")).is_true()
	assert_bool(sandbox.ai.announce_rumor(10, "primero")).is_false()
	assert_bool(sandbox.ai.announce_rumor(11, "segundo")).is_false()
	sandbox.ai._rumor_news_time = 0.0
	assert_bool(sandbox.ai.announce_rumor(10, "primero")).is_false()
	assert_bool(sandbox.ai.announce_rumor(11, "segundo")).is_true()


func test_news_is_silent_when_the_chat_is_full() -> void:
	var sandbox: Sandbox = _scene()
	_force_active(sandbox, ["conspi", "panico", "mama"])
	for index: int in range(AiChatter.NEWS_MAX_QUEUE):
		sandbox.ai.pending().append({"id": "panico", "text": "ruido %d" % index})
	assert_int(sandbox.ai.pending().size()).is_equal(AiChatter.NEWS_MAX_QUEUE)
	assert_bool(sandbox.ai.announce_rumor(12, "no cabe")).is_false()
