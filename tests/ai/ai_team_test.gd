extends GdUnitTestSuite

var team: AiTeam
var rng: RandomNumberGenerator


func before_test() -> void:
	team = AiTeam.new()
	rng = RandomNumberGenerator.new()
	rng.seed = 11
	team.start(rng)


func test_six_ais_with_three_active() -> void:
	assert_int(team.ais.size()).is_equal(6)
	assert_int(team.active.size()).is_equal(AiTeam.ACTIVE_COUNT)


func test_running_out_of_tokens_rotates() -> void:
	var id: String = team.active[0]
	team.tokens[id] = 0.1
	team.spend(id, rng)
	assert_bool(team.has_active(id)).is_false()
	assert_int(team.active.size()).is_equal(AiTeam.ACTIVE_COUNT)


func test_more_effort_costs_more() -> void:
	team.tokens = {"abuela": 100.0, "dr_desprecio": 100.0}
	team.active = ["abuela", "dr_desprecio"]
	team.spend("abuela", rng)
	team.spend("dr_desprecio", rng)
	assert_float(team.tokens["dr_desprecio"]).is_less(team.tokens["abuela"])


func test_three_grave_offenses_lose_ai_forever() -> void:
	var id: String = team.active[0]
	team.ais[id]["tolerance"] = 3
	assert_bool(team.offend(id, rng)).is_false()
	assert_bool(team.can_speak(id)).is_false()
	team.offend(id, rng)
	assert_bool(team.offend(id, rng)).is_true()
	assert_bool(team.lost.has(id)).is_true()
	while not team.active.is_empty():
		var other: String = team.active[0]
		team.tokens[other] = 0.1
		team.spend(other, rng)
		assert_bool(team.has_active(id)).is_false()


func test_offended_ai_speaks_again_after_a_while() -> void:
	var id: String = team.active[0]
	team.ais[id]["tolerance"] = 3
	team.offend(id, rng)
	team.tick(AiTeam.OFFENDED_MUTE_TIME + 0.1)
	assert_bool(team.can_speak(id)).is_true()


func test_recharge_goes_to_sleeping_ai_only_a_little() -> void:
	var sleeper: String = ""
	for id: String in team.ais:
		if not team.has_active(id):
			sleeper = id
	team.tokens[sleeper] = 0.0
	assert_str(team.recharge_sleeping()).is_equal(sleeper)
	assert_float(team.tokens[sleeper]).is_equal(AiTeam.DISCARD_RECHARGE)


func test_state_roundtrip() -> void:
	var text: String = JSON.stringify(team.to_dict())
	var other: AiTeam = AiTeam.new()
	other.restore(JSON.parse_string(text), rng)
	assert_array(other.active).is_equal(team.active)
