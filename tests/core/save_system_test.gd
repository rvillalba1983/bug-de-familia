extends GdUnitTestSuite


func before_test() -> void:
	TestSupport.reset_session()


func test_write_and_read() -> void:
	assert_bool(SaveSystem.write({"dead": false, "body": {}})).is_true()
	var loaded: Dictionary = SaveSystem.read()
	assert_int(loaded["status"]).is_equal(SaveSystem.Status.OK)
	assert_bool(FileAccess.file_exists(SaveSystem.path + ".tmp")).is_false()


func test_overwrites_single_slot() -> void:
	SaveSystem.write({"dead": false, "body": {}, "marca": 1})
	SaveSystem.write({"dead": false, "body": {}, "marca": 2})
	assert_int(int(SaveSystem.read()["data"]["marca"])).is_equal(2)


func test_missing_save() -> void:
	assert_int(SaveSystem.read()["status"]).is_equal(SaveSystem.Status.NONE)


func test_corrupt_and_wrong_version() -> void:
	var file: FileAccess = FileAccess.open(SaveSystem.path, FileAccess.WRITE)
	file.store_string("[1, 2]")
	file.close()
	assert_int(SaveSystem.read()["status"]).is_equal(SaveSystem.Status.CORRUPT)
	file = FileAccess.open(SaveSystem.path, FileAccess.WRITE)
	file.store_string('{"version": 999, "dead": false, "body": {}}')
	file.close()
	assert_int(SaveSystem.read()["status"]).is_equal(SaveSystem.Status.CORRUPT)


func test_death_is_recorded() -> void:
	SaveSystem.write({"dead": false, "body": {}})
	SaveSystem.mark_dead()
	assert_bool(SaveSystem.read()["data"]["dead"]).is_true()
