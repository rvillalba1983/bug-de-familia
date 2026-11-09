extends GdUnitTestSuite
## El dibujo no retiene las texturas: cargarlas dentro de la llamada las libera y salen en blanco.

const FOLDERS: Array[String] = ["res://scenes", "res://entities", "res://ui"]


func test_no_texture_is_loaded_inside_a_draw_call() -> void:
	var offenders: Array[String] = []
	for folder: String in FOLDERS:
		_collect(folder, offenders)
	assert_array(offenders).is_empty()


func _collect(folder: String, offenders: Array[String]) -> void:
	for sub: String in DirAccess.get_directories_at(folder):
		_collect(folder.path_join(sub), offenders)
	for file: String in DirAccess.get_files_at(folder):
		if file.ends_with(".gd"):
			var path: String = folder.path_join(file)
			var regex: RegEx = RegEx.create_from_string("draw_\\w*texture\\w*\\(\\s*load\\(")
			if regex.search(FileAccess.get_file_as_string(path)) != null:
				offenders.append(path)
