extends GdUnitTestSuite
## Muertes bestiales (P-27): catálogo, reparto por semilla y efectos sin romper la partida.

const SEED: int = 1234

var _runner: GdUnitSceneRunner
var _sandbox: Sandbox


func before_test() -> void:
	TestSupport.reset_session()
	_runner = scene_runner("res://scenes/sandbox/sandbox.tscn")
	_sandbox = _runner.scene()
	_sandbox.set_enemies_active(false)


func after_test() -> void:
	get_tree().paused = false


func test_catalog_has_all_deaths_with_required_fields() -> void:
	var expected: Array[String] = [
		"caida", "trozos", "cohete", "confeti", "congelado", "estatua", "muelle",
		"apagon", "oxidacion", "origami", "burbujas", "prensa", "dispersion",
	]
	for id: String in expected:
		var death: Dictionary = DeathCatalog.entry(id)
		assert_str(str(death["animation"])).is_equal("caer")
		assert_str(str(death["effect"])).is_not_empty()
		assert_float(float(death["corpse_time"])).is_greater(0.0)
		assert_float(float(death["effect_duration"])).is_greater_equal(0.0)


func test_pick_is_reproducible_with_seed() -> void:
	var ids: Array = ["trozos", "cohete", "confeti", "congelado", "estatua", "muelle", "apagon"]
	var rng_a: RandomNumberGenerator = RandomNumberGenerator.new()
	var rng_b: RandomNumberGenerator = RandomNumberGenerator.new()
	rng_a.seed = SEED
	rng_b.seed = SEED
	for i: int in range(20):
		var a: Dictionary = DeathCatalog.pick(ids, rng_a)
		var b: Dictionary = DeathCatalog.pick(ids, rng_b)
		assert_str(str(a["effect"])).is_equal(str(b["effect"]))


func test_pick_consumes_rng_only_when_several_options() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	var before: int = rng.state
	DeathCatalog.pick(["caida"], rng)
	assert_int(rng.state).is_equal(before)
	DeathCatalog.pick(["trozos", "cohete"], rng)
	assert_int(rng.state).is_not_equal(before)


func test_each_species_has_generic_and_own_death() -> void:
	var own: Dictionary = {
		"jubilado": "apagon",
		"mohocrata": "oxidacion",
		"plegado": "origami",
		"eco": "burbujas",
		"grux": "prensa",
		"manada": "dispersion",
	}
	var generics: Array[String] = ["trozos", "cohete", "confeti", "congelado", "estatua", "muelle"]
	for species: String in own:
		var deaths: Array = SpeciesCatalog.deaths(species)
		for g: String in generics:
			assert_bool(deaths.has(g)).is_true()
		assert_bool(deaths.has(own[species])).is_true()


func test_every_death_effect_can_play_on_a_guard() -> void:
	var guard: Guard = _sandbox.guard
	for id: String in DeathCatalog.ids():
		guard.death = DeathCatalog.entry(id)
		var fx: DeathEffect = DeathEffect.new()
		guard.add_child(fx)
		fx.play(guard.death, GuardVisual.COLOR_BODY)
		for frame: int in range(5):
			await get_tree().process_frame
		fx.queue_free()
		await get_tree().process_frame
		# restaura estado mínimo por si el efecto movió el cuerpo visual
		if guard.visual.rig_root != null:
			guard.visual.rig_root.position = Vector2.ZERO
			guard.visual.rig_root.scale = Vector2.ONE
			guard.visual.rig_root.modulate = Color.WHITE


func test_falling_spawns_effect_and_keeps_corpse_time() -> void:
	var guard: Guard = _sandbox.guard
	guard.death = DeathCatalog.entry("confeti")
	guard.die_quietly()
	await get_tree().process_frame
	assert_int(guard.state).is_equal(Guard.State.DOWN)
	assert_float(guard._corpse_time).is_equal(float(guard.death["corpse_time"]))
	var found: bool = false
	for child: Node in guard.get_children():
		if child is DeathEffect:
			found = true
			break
	assert_bool(found).is_true()
