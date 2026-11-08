extends GdUnitTestSuite

const LEFT: ModularBody.Slot = ModularBody.Slot.LEG_LEFT
const RIGHT: ModularBody.Slot = ModularBody.Slot.LEG_RIGHT
const ARM: ModularBody.Slot = ModularBody.Slot.ARM_MAIN_LEFT
const FULL: float = BodyPiece.MAX_DURABILITY


func test_starts_with_six_limbs_and_head() -> void:
	var body: ModularBody = ModularBody.new()
	for slot: int in ModularBody.Slot.values():
		assert_object(body.equipped(slot as ModularBody.Slot)).is_not_null()
	assert_int(ModularBody.Slot.size()).is_equal(7)


func test_inventory_holds_four_and_rejects_wrong_kind() -> void:
	var body: ModularBody = ModularBody.new()
	assert_bool(body.add_spare(LEFT, BodyPiece.new(BodyPiece.Kind.ARM))).is_false()
	for index: int in range(4):
		assert_bool(body.add_spare(LEFT, BodyPiece.new(BodyPiece.Kind.LEG))).is_true()
	assert_bool(body.add_spare(LEFT, BodyPiece.new(BodyPiece.Kind.LEG))).is_false()


func test_swap_rules_by_context() -> void:
	var body: ModularBody = ModularBody.new()
	assert_bool(body.can_swap(ARM)).is_true()
	body.context = ModularBody.Context.PRE_FIGHT
	assert_bool(body.can_swap(ARM)).is_true()
	body.context = ModularBody.Context.INTERACTING
	assert_bool(body.can_swap(ARM)).is_false()
	body.context = ModularBody.Context.FIGHTING
	assert_bool(body.can_swap(ARM)).is_false()
	body.damage(ARM, FULL)
	assert_bool(body.can_swap(ARM)).is_true()


func test_swap_exchanges_with_spare() -> void:
	var body: ModularBody = ModularBody.new()
	var spare: BodyPiece = BodyPiece.new(BodyPiece.Kind.ARM, 50.0)
	body.add_spare(ARM, spare)
	var old: BodyPiece = body.equipped(ARM)
	assert_bool(body.swap(ARM, 0)).is_true()
	assert_object(body.equipped(ARM)).is_same(spare)
	assert_object(body.spares(ARM)[0]).is_same(old)


func test_broken_head_without_spare_kills() -> void:
	var body: ModularBody = ModularBody.new()
	body.damage(ModularBody.Slot.HEAD, FULL)
	assert_bool(body.is_dead).is_true()


func test_broken_head_with_spare_can_be_replaced_in_fight() -> void:
	var body: ModularBody = ModularBody.new()
	var head: ModularBody.Slot = ModularBody.Slot.HEAD
	body.add_spare(head, BodyPiece.new(BodyPiece.Kind.HEAD))
	body.context = ModularBody.Context.FIGHTING
	body.damage(head, FULL)
	assert_bool(body.is_dead).is_false()
	assert_bool(body.can_swap(head)).is_true()
	assert_bool(body.swap(head, 0)).is_true()
	assert_object(body.equipped(head)).is_not_null()


func test_closing_without_choosing_head_equips_spare() -> void:
	var body: ModularBody = ModularBody.new()
	var head: ModularBody.Slot = ModularBody.Slot.HEAD
	body.add_spare(head, BodyPiece.new(BodyPiece.Kind.HEAD))
	body.damage(head, FULL)
	body.ensure_head()
	assert_object(body.equipped(head)).is_not_null()


func test_hits_rarely_land_on_head() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var head_hits: int = 0
	for attempt: int in range(1000):
		var body: ModularBody = ModularBody.new()
		body.damage_random(1.0, rng)
		if body.equipped(ModularBody.Slot.HEAD).durability < FULL:
			head_hits += 1
	assert_int(head_hits).is_between(10, 90)


func test_one_leg_slows_and_no_legs_kills() -> void:
	var body: ModularBody = ModularBody.new()
	body.add_spare(RIGHT, BodyPiece.new(BodyPiece.Kind.LEG))
	body.damage(LEFT, FULL)
	assert_bool(body.is_dead).is_false()
	assert_float(body.speed_factor()).is_equal(ModularBody.ONE_LEG_SPEED_FACTOR)
	body.damage(RIGHT, FULL)
	assert_bool(body.is_dead).is_true()


func test_losing_arms_does_not_kill() -> void:
	var body: ModularBody = ModularBody.new()
	body.damage(ARM, FULL)
	assert_bool(body.is_dead).is_false()
	assert_float(body.speed_factor()).is_equal(1.0)


func test_walking_wears_legs() -> void:
	var body: ModularBody = ModularBody.new()
	body.wear_legs(108000.0)
	assert_object(body.equipped(LEFT)).is_null()
	body = ModularBody.new()
	body.wear_legs(1000.0)
	assert_float(body.equipped(LEFT).durability).is_less(FULL)
	assert_float(body.equipped(ARM).durability).is_equal(FULL)


func test_discard_notifies_for_tokens() -> void:
	var body: ModularBody = ModularBody.new()
	body.add_spare(ARM, BodyPiece.new(BodyPiece.Kind.ARM))
	var discarded: Array[BodyPiece] = []
	body.piece_discarded.connect(func(piece: BodyPiece) -> void: discarded.append(piece))
	body.discard_spare(ARM, 0)
	assert_int(discarded.size()).is_equal(1)
	assert_int(body.spares(ARM).size()).is_equal(0)


func test_serialization_roundtrip() -> void:
	var body: ModularBody = ModularBody.new()
	body.add_spare(ARM, BodyPiece.new(BodyPiece.Kind.ARM, 33.0))
	body.damage(LEFT, FULL)
	var text: String = JSON.stringify(body.to_dict())
	var restored: ModularBody = ModularBody.from_dict(JSON.parse_string(text))
	assert_object(restored.equipped(LEFT)).is_null()
	assert_float(restored.spares(ARM)[0].durability).is_equal(33.0)


func test_invalid_data_is_rejected() -> void:
	assert_object(ModularBody.from_dict({"0": "roto"})).is_null()
	assert_object(ModularBody.from_dict("nada")).is_null()
