extends GdUnitTestSuite
## Migración de partidas anteriores al renombrado beta -> despliegue_cero.
##
## Las partidas guardadas antes del renombrado apuntan a la zona «beta», que ya no
## existe en el índice. Al cargarlas, el identificador se traduce y la partida
## sigue en la misma zona, con su contenido.


func before_test() -> void:
	TestSupport.reset_session()
	Sandbox.pending_save = {}


func _legacy_save() -> Dictionary:
	return {
		"dead": false,
		"body": {},
		"seed": 1234,
		"world_seconds": 42.0,
		"world_zones": {
			"current": "beta",
			"records": {
				"beta": {
					"zone_id": "beta",
					"visited": true,
					"level": 0,
					"level_state": {"seed": 1234},
					"world": {},
					"population": {"jubilado": 18, "mohocrata": 18},
					"changes": {},
					"last_seen_day": 3,
				},
			},
		},
	}


func test_legacy_zone_id_is_translated() -> void:
	assert_str(SaveSystem.migrate_zone_id("beta")).is_equal("despliegue_cero")
	assert_str(SaveSystem.migrate_zone_id("despliegue_cero")).is_equal("despliegue_cero")
	assert_str(SaveSystem.migrate_zone_id("el_enchufe")).is_equal("el_enchufe")


func test_a_legacy_save_starts_in_the_renamed_zone() -> void:
	assert_bool(SaveSystem.write(_legacy_save())).is_true()
	var manager: ZoneManager = ZoneManager.new()
	var host: Node2D = Node2D.new()
	add_child(host)
	manager.setup(host)
	manager.zone_factory = func(_id: String) -> ZoneBase: return null
	manager.min_transition = 0.0
	add_child(manager)
	manager._restore(_legacy_save())
	assert_str(manager.current_id).is_equal("despliegue_cero")
	assert_bool(manager.records.has("despliegue_cero")).is_true()
	assert_bool(manager.records.has("beta")).is_false()
	var record: ZoneRecord = manager.records["despliegue_cero"] as ZoneRecord
	assert_str(record.zone_id).is_equal("despliegue_cero")
	assert_int(record.population.get("jubilado", 0)).is_equal(18)


func test_a_save_of_the_current_zone_is_not_touched() -> void:
	var save: Dictionary = _legacy_save()
	var zones: Dictionary = save["world_zones"]
	zones["current"] = "despliegue_cero"
	var records: Dictionary = zones["records"]
	var record: Dictionary = records["beta"]
	record["zone_id"] = "despliegue_cero"
	records.erase("beta")
	records["despliegue_cero"] = record
	var manager: ZoneManager = ZoneManager.new()
	add_child(manager)
	manager._restore(save)
	assert_str(manager.current_id).is_equal("despliegue_cero")
	assert_bool(manager.records.has("despliegue_cero")).is_true()
	assert_int(manager.records.size()).is_equal(1)
