extends GdUnitTestSuite
## El contenido que pasó a datos se carga completo y se refiere a cosas que existen.


func test_each_zone_species_has_actor_data_and_a_rival_in_the_zone() -> void:
	var zone: Array[String] = DespliegueCeroLayout.zone.species()
	assert_array(zone).is_not_empty()
	for species: String in zone:
		assert_bool(SpeciesCatalog.has(species)).is_true()
		assert_bool(zone.has(SpeciesCatalog.rival(species))).is_true()
		assert_bool(ResourceLoader.exists("res://art/shared/%s.svg" % SpeciesCatalog.art(species))).is_true()
		assert_array(SpeciesCatalog.deaths(species)).is_not_empty()


func test_every_actor_route_and_identity_exists_in_the_zone() -> void:
	var zone: ZoneDefinition = DespliegueCeroLayout.zone
	for actor: Dictionary in zone.list("actors"):
		assert_int(zone.points(str(actor["route"])).size()).is_greater(1)
		if actor.has("species"):
			assert_bool(SpeciesCatalog.has(str(actor["species"]))).is_true()
		else:
			assert_bool(ProgenitorCatalog.has(str(actor["progenitor"]))).is_true()
		if actor.has("weapon"):
			assert_str(str(WeaponCatalog.enemy(str(actor["weapon"]))["kind"])).is_equal("ranged")


func test_every_zone_item_has_a_real_position_and_known_material() -> void:
	var zone: ZoneDefinition = DespliegueCeroLayout.zone
	var catalog: ConversionCatalog = ConversionCatalog.load_default()
	for item: Dictionary in zone.list("items"):
		assert_bool(DespliegueCeroLayout.floor_rect.has_point(zone.point(str(item["at"])))).is_true()
	for entry: Dictionary in zone.list("convertibles"):
		assert_bool(catalog.materials.has(str(entry["material"]))).is_true()


func test_progenitors_have_a_material_the_catalog_knows() -> void:
	var catalog: ConversionCatalog = ConversionCatalog.load_default()
	for id: String in [DespliegueCeroZone.ID_RAMON, DespliegueCeroZone.ID_CONTESTADOR]:
		assert_bool(catalog.materials.has(str(ProgenitorCatalog.entry(id)["material"]))).is_true()


func test_each_death_names_an_animation_that_exists() -> void:
	var clips: Dictionary = DataFile.load_dictionary(EnemyRig.CLIPS_PATH)
	assert_bool(clips.has(str(DeathCatalog.entry(DeathCatalog.DEFAULT_ID)["animation"]))).is_true()


func test_a_single_death_option_does_not_consume_the_game_seed() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var before: int = rng.state
	DeathCatalog.pick(["caida"], rng)
	assert_int(rng.state).is_equal(before)


func test_player_weapons_keep_integer_pellets_and_real_colors() -> void:
	for id: String in ["a101", "a102", "a103", "a104"]:
		var weapon: Dictionary = WeaponCatalog.player(id)
		assert_int(typeof(weapon["pellets"])).is_equal(TYPE_INT)
		assert_int(typeof(weapon["color"])).is_equal(TYPE_COLOR)
	assert_bool(WeaponCatalog.has_player_weapon(WeaponCatalog.THROWN_ID)).is_false()
