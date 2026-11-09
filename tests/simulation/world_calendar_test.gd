extends GdUnitTestSuite

const JAN_1_2027: int = 1798761600


func after_test() -> void:
	WorldCalendar.forced_local_unix = -1


func test_catalog_has_36_valid_festivals() -> void:
	var calendar: WorldCalendar = WorldCalendar.new()
	assert_int(calendar.festivals.size()).is_equal(36)
	assert_array(calendar.validate()).is_empty()


func test_festival_on_real_date() -> void:
	var calendar: WorldCalendar = WorldCalendar.new()
	var day: int = WorldCalendar.day_index(JAN_1_2027)
	assert_str(calendar.festival_on(day)["id"]).is_equal("ano_nuevo_oxidado")
	assert_dict(calendar.festival_on(day + 1)).is_empty()


func test_missed_festivals_only_between_days() -> void:
	var calendar: WorldCalendar = WorldCalendar.new()
	var day: int = WorldCalendar.day_index(JAN_1_2027)
	var missed: Array[Dictionary] = calendar.missed_between(day - 1, day + 13)
	assert_array(missed.map(func(e: Dictionary) -> String: return e["id"])).contains_exactly(
		["ano_nuevo_oxidado", "recuento_de_enero"]
	)
	assert_array(calendar.missed_between(day, day + 1)).is_empty()


func test_old_save_migrates_to_current_schema() -> void:
	TestSupport.reset_session()
	var file: FileAccess = FileAccess.open(SaveSystem.path, FileAccess.WRITE)
	file.store_string('{"version": 1, "dead": false, "body": {}}')
	file.close()
	var loaded: Dictionary = SaveSystem.read()
	assert_int(loaded["status"]).is_equal(SaveSystem.Status.OK)
	assert_dict(loaded["data"]["world"]).is_empty()
	assert_int(int(loaded["data"]["version"])).is_equal(SaveSystem.SCHEMA_VERSION)
