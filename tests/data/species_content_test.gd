extends GdUnitTestSuite
## Cada especie tiene texto para cada situación, línea para cada oficio y lore.

const PATH: String = "res://data/world/species.json"
const CLAVES: Array[String] = [
	"greet", "opener", "nothing", "angry", "praised", "weird", "sad",
]
const MINIMO_LINEAS: int = 4
const MINIMO_POR_ROL: int = 2
const MINIMO_LORE: int = 8


func _especies() -> Dictionary:
	return DataFile.load_dictionary(PATH)


func test_every_species_has_a_line_for_every_situation() -> void:
	for id: String in _especies():
		var info: Dictionary = _especies()[id]
		for clave: String in CLAVES:
			var lines: Array = info.get(clave, [])
			assert_int(lines.size()).is_greater_equal(MINIMO_LINEAS).override_failure_message(
				"%s: la clave «%s» tiene %d líneas" % [id, clave, lines.size()]
			)
			for linea: String in lines:
				assert_str(linea.strip_edges()).is_not_empty().override_failure_message(
					"%s: la clave «%s» tiene una línea vacía" % [id, clave]
				)


func test_every_species_has_a_line_for_each_role() -> void:
	for id: String in _especies():
		var info: Dictionary = _especies()[id]
		var por_rol: Dictionary = info.get("role_lines", {})
		for rol: String in info["roles"]:
			var lines: Array = por_rol.get(rol, [])
			assert_int(lines.size()).is_greater_equal(MINIMO_POR_ROL).override_failure_message(
				"%s: el oficio «%s» tiene %d líneas" % [id, rol, lines.size()]
			)
			for linea: String in lines:
				assert_str(linea.strip_edges()).is_not_empty()


func test_every_species_has_enough_lore() -> void:
	for id: String in _especies():
		var lore: Array = _especies()[id]["lore"]
		assert_int(lore.size()).is_greater_equal(MINIMO_LORE).override_failure_message(
			"%s: solo %d hechos de lore" % [id, lore.size()]
		)
		for hecho: Dictionary in lore:
			assert_str(str(hecho["text"]).strip_edges()).is_not_empty()
			assert_bool(hecho.has("true")).is_true()
