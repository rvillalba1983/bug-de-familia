extends GdUnitTestSuite
## Gestor multi-zona: niveles, transiciones, viaje rápido y persistencia.

class StubZone extends ZoneBase:
	var _mounted: int = 0

	func _ready() -> void:
		_mounted += 1
	func _physics_process(_delta: float) -> void:
		pass

	func snapshot() -> Dictionary:
		var data: Dictionary = LevelSaveState.fresh(start_point(), Sandbox.forced_seed, Sandbox.default_body())
		data["world"] = {}
		return data

	func population_counts() -> Dictionary:
		return {}

	func after_enter(_from_zone: String) -> void:
		pass

	func freeze_player(_frozen: bool) -> void:
		pass

	func is_in_combat() -> bool:
		return false


var manager: ZoneManager
var host: Node2D


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}
	host = auto_free(Node2D.new())
	add_child(host)
	manager = ZoneManager.new()
	manager.setup(host)
	manager.zone_factory = func(_id: String) -> ZoneBase: return StubZone.new()
	manager.min_transition = 0.0
	add_child(manager)
	assert_bool(manager.start("beta")).is_true()


func after_test() -> void:
	get_tree().paused = false


func test_levels_by_hops_from_beta() -> void:
	assert_int(manager.level_of("beta")).is_equal(ZoneRecord.Level.FULL)
	assert_int(manager.level_of("cumbre")).is_equal(ZoneRecord.Level.SIMPLIFIED)
	assert_int(manager.level_of("cementerio")).is_equal(ZoneRecord.Level.STATISTICAL)


func test_transition_moves_to_destination() -> void:
	assert_bool(manager.enter("el_enchufe")).is_true()
	assert_str(manager.current_id).is_equal("el_enchufe")
	assert_int(manager.level_of("el_enchufe")).is_equal(ZoneRecord.Level.FULL)
	assert_int(manager.level_of("beta")).is_equal(ZoneRecord.Level.SIMPLIFIED)


func test_minimum_transition_waits_five_seconds() -> void:
	manager.min_transition = ZoneManager.MIN_TRANSITION
	manager.enter("cumbre")
	assert_str(manager.current_id).is_equal("beta")
	assert_bool(manager.loading).is_true()
	manager._process(4.9)
	assert_str(manager.current_id).is_equal("beta")
	manager._process(0.2)
	assert_str(manager.current_id).is_equal("cumbre")


func test_fast_travel_requires_visited_destination() -> void:
	manager.enter("el_enchufe")
	manager.enter("beta")
	assert_bool(manager.can_fast_travel("el_enchufe")).is_true()
	assert_int(manager.travel_destinations().size()).is_greater(0)
	var before: float = manager.world_seconds
	assert_bool(manager.fast_travel("el_enchufe")).is_true()
	assert_str(manager.current_id).is_equal("el_enchufe")
	assert_float(manager.world_seconds - before).is_equal(ZoneManager.TRAVEL_SECONDS_PER_HOP)


func test_unknown_destination_is_not_fast_travel() -> void:
	assert_bool(manager.can_fast_travel("cumbre")).is_false()


func test_persistence_round_trip() -> void:
	manager.enter("el_enchufe")
	manager.enter("beta")
	var second: ZoneManager = ZoneManager.new()
	var second_host: Node2D = Node2D.new()
	add_child(second_host)
	second.setup(second_host)
	second.zone_factory = func(_id: String) -> ZoneBase: return StubZone.new()
	second.min_transition = 0.0
	add_child(second)
	assert_bool(second.start("beta")).is_true()
	assert_str(second.current_id).is_equal("beta")
	assert_bool(second.is_known("el_enchufe")).is_true()


func test_statistical_zone_moves_toward_target() -> void:
	manager.enter("el_enchufe")
	manager.enter("beta")
	var record: ZoneRecord = manager.records.get("el_enchufe") as ZoneRecord
	record.population = {"jubilado": 8, "mohocrata": 8}
	manager.enter("archivo")
	assert_int(manager.level_of("el_enchufe")).is_equal(ZoneRecord.Level.STATISTICAL)
	manager._advance_world(100.0)
	assert_int(int(record.population.get("jubilado", 0))).is_equal(10)
	assert_int(int(record.population.get("mohocrata", 0))).is_equal(10)
