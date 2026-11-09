extends GdUnitTestSuite
## Motes de IAs y progenitores, y comentarios de Sujeto Sobrante.

const PATH: String = "res://scenes/beta/beta_zone.tscn"

var zone: BetaZone


func before_test() -> void:
	TestSupport.reset_session()
	BetaZone.forced_hour = 12
	zone = scene_runner(PATH).scene()
	zone.set_enemies_active(false)
	zone.ai.team.active = ["panico", "mama", "arbitro"]
	zone.ai.team.muted.clear()
	zone.ai.pending().clear()


func after_test() -> void:
	BetaZone.forced_hour = -1
	get_tree().paused = false


func _voice() -> ProtagonistVoice:
	return zone.protagonist


func _protagonist_lines() -> Array:
	return zone.ai.pending().filter(
		func(entry: Dictionary) -> bool: return entry["id"] == AiChatter.PROTAGONIST
	)


func _ready_to_speak() -> void:
	_voice().poll()
	zone.ai.pending().clear()
	_voice().global_left = 0.0


func test_every_ai_and_progenitor_has_nicknames() -> void:
	var owners: Dictionary = zone.ai.nicknames.by_owner
	assert_int(owners.size()).is_equal(22)
	for id: String in zone.ai.team.ais:
		assert_bool(owners.has(id)).is_true()


func test_no_line_keeps_the_mote_token_when_spoken() -> void:
	for id: String in zone.ai.team.ais:
		zone.ai.pending().clear()
		zone.ai._enqueue(id, "idle_insult")
		assert_str(zone.ai.pending()[0]["text"]).not_contains(Nicknames.TOKEN)


func test_insult_uses_a_nickname_of_that_ai() -> void:
	zone.ai._enqueue("arbitro", "idle_insult")
	var text: String = zone.ai.pending()[0]["text"]
	var found: bool = false
	for mote: String in zone.ai.nicknames.by_owner["arbitro"]:
		found = found or text.contains(mote)
	assert_bool(found).is_true()


func test_progenitor_dialogue_resolves_nickname() -> void:
	zone.investigation.open_dialogue("contestador")
	var text: String = zone.investigation.bubbles["contestador"].text
	assert_str(text).contains("Identificado como:")
	assert_str(text).not_contains(Nicknames.TOKEN)


func test_comment_does_not_spend_tokens() -> void:
	_ready_to_speak()
	var before: Dictionary = zone.ai.team.tokens.duplicate()
	assert_bool(_voice().comment("idle")).is_true()
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_str(zone.ai.bubble.text).starts_with(AiChatter.PROTAGONIST_NAME)
	assert_dict(zone.ai.team.tokens).is_equal(before)


func test_cooldown_blocks_repeat_but_story_passes() -> void:
	_ready_to_speak()
	assert_bool(_voice().comment("idle")).is_true()
	assert_bool(_voice().comment("crate")).is_false()
	assert_bool(_voice().comment("ramon_dead", 0.0, true)).is_true()


func test_flag_comments_once() -> void:
	_ready_to_speak()
	zone.investigation.set_flag("e_sombrero")
	_voice().poll()
	_voice().poll()
	assert_int(_protagonist_lines().size()).is_equal(1)


func test_flags_from_a_loaded_game_stay_silent() -> void:
	var voice: ProtagonistVoice = ProtagonistVoice.new()
	voice.level = zone
	voice.lines = _voice().lines
	zone.investigation.flags["e_manolo"] = true
	voice.poll()
	voice.poll()
	assert_array(_protagonist_lines()).is_empty()
	voice.free()


func test_losing_one_leg_has_its_own_comment() -> void:
	_ready_to_speak()
	zone.player.body.damage(ModularBody.Slot.LEG_LEFT, 9999.0)
	assert_array(_voice().lines["one_leg"]).contains(_protagonist_lines()[0]["text"])


func test_swapping_head_comments() -> void:
	_ready_to_speak()
	zone.player.body.swap(ModularBody.Slot.HEAD, 0)
	assert_array(_voice().lines["head_swap"]).contains(_protagonist_lines()[0]["text"])


func test_rain_comments() -> void:
	_ready_to_speak()
	zone.rain.started.emit()
	assert_int(_protagonist_lines().size()).is_equal(1)


func test_every_trigger_has_written_lines() -> void:
	for event: String in ProtagonistVoice.FLAG_EVENTS.values() + ProtagonistVoice.NEAR_EVENTS.values():
		assert_bool(_voice().lines.has(event)).is_true()
	for event: String in ProtagonistVoice.WAITING_FOR_SYSTEM:
		assert_bool(_voice().lines.has(event)).is_true()


func test_game_over_shows_a_last_line() -> void:
	zone.player.body.damage(ModularBody.Slot.HEAD, 9999.0)
	zone.player.body.damage(ModularBody.Slot.LEG_LEFT, 9999.0)
	zone.player.body.damage(ModularBody.Slot.LEG_RIGHT, 9999.0)
	assert_object(zone.overlay).is_not_null()
	var found: bool = false
	for line: String in _voice().lines["death"]:
		for label: Node in zone.overlay.find_children("*", "Label", true, false):
			found = found or (label as Label).text == line
	assert_bool(found).is_true()
