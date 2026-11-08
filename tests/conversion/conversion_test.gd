extends GdUnitTestSuite

var catalog: ConversionCatalog
var rng: RandomNumberGenerator


func before_test() -> void:
	catalog = ConversionCatalog.load_default()
	rng = RandomNumberGenerator.new()
	rng.seed = 7


func test_data_is_valid() -> void:
	assert_array(catalog.validate()).is_empty()
	assert_int(catalog.questions.size()).is_greater_equal(10)


func test_forge_never_fails_for_any_combination_or_score() -> void:
	for material: String in catalog.materials:
		for objective: String in catalog.objectives:
			for score: float in [0.0, 0.5, 1.0]:
				var piece: BodyPiece = PieceForge.forge(
					catalog, material, objective, BodyPiece.Kind.ARM, score, rng
				)
				assert_object(piece).is_not_null()
				assert_bool(piece.actions.is_empty()).is_false()
				assert_bool(piece.label.is_empty()).is_false()


func test_actions_belong_to_objective() -> void:
	var allowed: Array = catalog.objectives["sigilo"]["actions"]
	for attempt: int in range(50):
		var piece: BodyPiece = PieceForge.forge(
			catalog, "nanoacero", "sigilo", BodyPiece.Kind.LEG, 0.5, rng
		)
		for action: Dictionary in piece.actions:
			assert_bool(allowed.has(action["id"])).is_true()


func test_better_answers_give_better_power() -> void:
	var low: float = 0.0
	var high: float = 0.0
	for attempt: int in range(2000):
		low += PieceForge.roll_power(0.0, rng)
		high += PieceForge.roll_power(1.0, rng)
	assert_float(high).is_greater(low)


func test_better_answers_reduce_negative_properties() -> void:
	assert_int(_negatives(1.0)).is_less(_negatives(0.0))


func _negatives(score: float) -> int:
	var count: int = 0
	for attempt: int in range(1500):
		var piece: BodyPiece = PieceForge.forge(
			catalog, "madera_cuantica", "sigilo", BodyPiece.Kind.ARM, score, rng
		)
		if piece.effects.has("wear"):
			count += 1
	return count


func test_session_scores_correct_and_speed() -> void:
	var bank: Array = [_question(), _question()]
	var fast: ConversionSession = ConversionSession.new(bank, rng)
	fast.answer(0, ConversionSession.TIME_LIMIT)
	fast.answer(0, ConversionSession.TIME_LIMIT)
	assert_float(fast.score()).is_equal(1.0)
	var slow: ConversionSession = ConversionSession.new(bank, rng)
	slow.answer(0, 0.0)
	slow.answer(1, 3.0)
	assert_float(slow.score()).is_equal(0.25)


func test_timeout_counts_as_wrong() -> void:
	var session: ConversionSession = ConversionSession.new([_question(), _question()], rng)
	assert_bool(session.answer(-1, 0.0)).is_false()


func test_effects_survive_saving() -> void:
	var piece: BodyPiece = PieceForge.forge(
		catalog, "madera_cuantica", "hackeo", BodyPiece.Kind.ARM, 1.0, rng
	)
	var text: String = JSON.stringify(piece.to_dict())
	var restored: BodyPiece = BodyPiece.from_dict(JSON.parse_string(text))
	assert_str(restored.label).is_equal(piece.label)
	assert_int(restored.actions.size()).is_equal(piece.actions.size())
	assert_array(restored.effects.keys()).contains_exactly_in_any_order(piece.effects.keys())
	for key: String in piece.effects:
		assert_bool(is_equal_approx(restored.effects[key], piece.effects[key])).is_true()


func _question() -> Dictionary:
	return {"text": "x", "options": ["a", "b"], "answer": 0}
