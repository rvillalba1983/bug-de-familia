extends GdUnitTestSuite

const EVENTS: Array[String] = [
	"idle_advice", "idle_insult", "idle_reproach", "danger", "fight", "piece_lost",
	"right", "wrong", "converted", "offended", "taunt",
]


func _team(active: Array) -> AiTeam:
	var team: AiTeam = AiTeam.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	team.start(rng)
	team.active = active.duplicate()
	return team


func test_las_veinte_tienen_todos_sus_datos() -> void:
	var team: AiTeam = AiTeam.new()
	for id: String in team.ais:
		var info: Dictionary = team.ais[id]
		for event: String in EVENTS:
			assert_bool((info["lines"] as Dictionary).has(event)).override_failure_message(id + " " + event).is_true()
		assert_int((info["spectre"] as Array).size()).is_greater(1)
		assert_bool(info.has("avatar") and info.has("face")).is_true()
	for pair: Dictionary in team.pairs:
		assert_bool(team.ais.has(pair["a"]) and team.ais.has(pair["b"])).is_true()


func test_nihil_da_dos_segundos() -> void:
	assert_float(AiPerks.new(_team(["nihil"])).question_time()).is_equal(7.0)
	assert_float(AiPerks.new(_team(["panico"])).question_time()).is_equal(5.0)


func test_sargento_potencia_cuerpo_a_cuerpo() -> void:
	assert_float(AiPerks.new(_team(["sargento_bit"])).melee_factor()).is_equal(1.25)


func test_mama_calla_con_desprecio() -> void:
	assert_bool(AiPerks.new(_team(["mama"])).mama_warns()).is_true()
	assert_bool(AiPerks.new(_team(["mama", "dr_desprecio"])).mama_warns()).is_false()


func test_cupido_se_enamora_con_la_racha() -> void:
	var perks: AiPerks = AiPerks.new(_team(["cupido"]))
	perks.streak = 2
	assert_bool(perks.in_love()).is_false()
	perks.streak = 3
	assert_bool(perks.in_love()).is_true()


func test_siestaware_casi_no_gasta() -> void:
	var team: AiTeam = _team(["siestaware", "nihil", "panico"])
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	team.spend("siestaware", rng)
	team.spend("nihil", rng)
	assert_float(float(team.tokens["siestaware"])).is_greater(float(team.tokens["nihil"]) + 2.0)


func test_ia_agotada_necesita_muchas_recargas() -> void:
	var team: AiTeam = _team(["panico", "mama", "troll"])
	for id: String in team.ais:
		team.tokens[id] = 0.0
	team.active.erase("troll")
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var discards: int = 0
	while team.active.size() < 3 and discards < 400:
		team.recharge_sleeping(rng)
		discards += 1
	assert_int(discards).is_greater(50)


func test_espectros_no_gastan_ni_incluyen_perdidas() -> void:
	var team: AiTeam = _team(["panico", "mama", "troll"])
	team.lost.append("abuela")
	var before: Dictionary = team.tokens.duplicate()
	var view: AiSpectres = auto_free(AiSpectres.new())
	view.team = team
	add_child(view)
	view.set_shown(true)
	view._process(0.1)
	assert_int(view.ghosts().size()).is_equal(19)
	assert_bool(view.ghosts().has("abuela")).is_false()
	assert_int(view.speaking().size()).is_equal(3)
	assert_dict(team.tokens).is_equal(before)
