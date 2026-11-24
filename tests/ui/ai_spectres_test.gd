extends GdUnitTestSuite
## P-26: los fantasmas siguen el estado de la pausa táctica, no el de las ventanas.


func before_test() -> void:
	TestSupport.reset_session()


func after_test() -> void:
	get_tree().paused = false


func _team() -> AiTeam:
	var team: AiTeam = AiTeam.new()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 5
	team.start(rng)
	team.active = ["panico", "mama", "troll"]
	return team


func _pause_view() -> Dictionary:
	var pause: TacticalPause = auto_free(TacticalPause.new())
	add_child(pause)
	var view: AiSpectres = auto_free(AiSpectres.new())
	view.team = _team()
	add_child(view)
	pause.paused_changed.connect(view.set_shown)
	return {"pause": pause, "view": view}


func test_la_pausa_tactica_ensena_y_oculta_los_fantasmas() -> void:
	var montaje: Dictionary = _pause_view()
	var pause: TacticalPause = montaje["pause"]
	var view: AiSpectres = montaje["view"]
	pause.set_paused(true)
	assert_bool(get_tree().paused).is_true()
	assert_bool(view.visible).is_true()
	assert_int(view.ghosts().size()).is_equal(3)
	pause.set_paused(false)
	assert_bool(get_tree().paused).is_false()
	assert_bool(view.visible).is_false()


func test_las_ventanas_modales_no_encienden_los_fantasmas() -> void:
	var montaje: Dictionary = _pause_view()
	var pause: TacticalPause = montaje["pause"]
	var view: AiSpectres = montaje["view"]
	pause.begin_modal()
	assert_bool(get_tree().paused).is_true()
	assert_bool(view.visible).is_false()
	pause.end_modal()
	assert_bool(get_tree().paused).is_false()
	assert_bool(view.visible).is_false()
	pause.set_paused(true)
	pause.begin_modal()
	pause.end_modal()
	assert_bool(get_tree().paused).is_true()
	assert_bool(view.visible).is_true()
