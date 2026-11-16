extends GdUnitTestSuite

var _motion_anterior: bool = false

func before_test() -> void:
	_motion_anterior = GameSettings.reduce_motion
	GameSettings.reduce_motion = false

func after_test() -> void:
	GameSettings.reduce_motion = _motion_anterior

func _fx(bbcode: String) -> RichTextEffect:
	match bbcode:
		"tartamuda":
			return TartamudaEffect.new()
		"enamorada":
			return EnamoradaEffect.new()
		"enfadada":
			return EnfadadaEffect.new()
		"corrupto":
			return CorruptoEffect.new()
	return null

func _transform() -> CharFXTransform:
	var fx: CharFXTransform = CharFXTransform.new()
	fx.elapsed_time = 0.5
	fx.relative_index = 3
	fx.color = Color.WHITE
	fx.offset = Vector2.ZERO
	return fx

func test_cada_efecto_tiene_su_bbcode() -> void:
	for bbcode: String in ["tartamuda", "enamorada", "enfadada", "corrupto"]:
		var efecto: RichTextEffect = _fx(bbcode)
		assert_str(str(efecto.get("bbcode"))).is_equal(bbcode)

func test_con_movimiento_el_efecto_modifica_el_transform() -> void:
	GameSettings.reduce_motion = false
	for bbcode: String in ["tartamuda", "enamorada", "enfadada", "corrupto"]:
		var efecto: RichTextEffect = _fx(bbcode)
		var antes: CharFXTransform = _transform()
		var despues: CharFXTransform = _transform()
		var ok: bool = efecto._process_custom_fx(despues)
		assert_bool(ok).is_true()
		var cambio: bool = despues.offset != antes.offset or despues.color != antes.color
		assert_bool(cambio).override_failure_message(
			"%s no modificó el transform con movimiento activo" % bbcode
		).is_true()

func test_con_movimiento_reducido_el_efecto_no_modifica() -> void:
	GameSettings.reduce_motion = true
	for bbcode: String in ["tartamuda", "enamorada", "enfadada", "corrupto"]:
		var efecto: RichTextEffect = _fx(bbcode)
		var antes: CharFXTransform = _transform()
		var despues: CharFXTransform = _transform()
		var ok: bool = efecto._process_custom_fx(despues)
		assert_bool(ok).is_true()
		assert_bool(despues.offset == antes.offset).override_failure_message(
			"%s movió el texto con reduce_motion" % bbcode
		).is_true()
		assert_bool(despues.color == antes.color).override_failure_message(
			"%s cambió el color con reduce_motion" % bbcode
		).is_true()
