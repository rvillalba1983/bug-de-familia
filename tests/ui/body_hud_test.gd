extends GdUnitTestSuite


func _hud() -> BodyHud:
	var hud: BodyHud = auto_free(BodyHud.new())
	hud.body = ModularBody.new()
	add_child(hud)
	return hud


func test_wear_color_goes_from_green_to_red() -> void:
	assert_object(ProtagonistArt.wear_color(1.0)).is_equal(Palette.ACIDO)
	assert_object(ProtagonistArt.wear_color(0.5)).is_equal(Palette.OBRA)
	assert_object(ProtagonistArt.wear_color(0.0)).is_equal(Palette.ROSA)


func test_sudden_damage_marks_only_that_piece() -> void:
	var hud: BodyHud = _hud()
	var arm: BodyPiece = hud.body.equipped(ModularBody.Slot.ARM_MAIN_LEFT)
	arm.durability -= 30.0
	hud.body.changed.emit()
	assert_bool(hud.was_just_hit(ModularBody.Slot.ARM_MAIN_LEFT)).is_true()
	assert_bool(hud.was_just_hit(ModularBody.Slot.HEAD)).is_false()


func test_slow_wear_does_not_look_like_a_hit() -> void:
	var hud: BodyHud = _hud()
	hud.body.equipped(ModularBody.Slot.LEG_LEFT).durability -= 0.5
	hud.body.changed.emit()
	assert_bool(hud.was_just_hit(ModularBody.Slot.LEG_LEFT)).is_false()


func test_hit_mark_expires() -> void:
	var hud: BodyHud = _hud()
	hud.body.equipped(ModularBody.Slot.HEAD).durability -= 30.0
	hud.body.changed.emit()
	hud._process(BodyHud.HIT_TIME + 0.1)
	assert_bool(hud.was_just_hit(ModularBody.Slot.HEAD)).is_false()
