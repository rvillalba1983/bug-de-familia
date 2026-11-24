extends GdUnitTestSuite
## P-32: solo despliegue_cero tiene retos, así que solo su zona cambia el chat.
## Estas comprobaciones leen datos y fuentes: no montan ninguna zona.

const DATOS: String = "res://data/zones"
const CLAVES_RETO: Array[String] = ["challenges", "retos", "challenge"]
const IGNORADOS: Array[String] = [
	"addons", "tests", "tools", "build", "reports", ".godot", ".backups"
]
const IMPLEMENTACIONES: Array[String] = [
	"res://scenes/zones/zone_base.gd",
	"res://scenes/despliegue_cero/despliegue_cero_zone.gd",
]


func test_ninguna_zona_declara_retos_en_los_datos() -> void:
	var ficheros: PackedStringArray = DirAccess.get_files_at(DATOS)
	assert_int(ficheros.size()).is_equal(24)
	var aviso: String = ("si añades retos a una zona, implementa chat_topic()/"
		+ "discover_challenge() y actualiza esta prueba")
	var leidos: int = 0
	for nombre: String in ficheros:
		if not nombre.ends_with(".json"):
			continue
		leidos += 1
		var ruta: String = DATOS + "/" + nombre
		var datos: Variant = JSON.parse_string(FileAccess.get_file_as_string(ruta))
		assert_bool(datos is Dictionary).override_failure_message(ruta).is_true()
		if not datos is Dictionary:
			continue
		for clave: String in CLAVES_RETO:
			var prohibida: bool = (datos as Dictionary).has(clave)
			assert_bool(prohibida).override_failure_message(
				aviso + " (" + ruta + ")"
			).is_false()
	assert_int(leidos).is_equal(24)


func test_la_base_devuelve_el_objetivo_generico() -> void:
	var base: ZoneBase = auto_free(ZoneBase.new())
	assert_str(base.chat_topic()).is_not_empty()
	assert_str(base.objective_key()).is_equal("ZONE_OBJECTIVE")
	base.discover_challenge()


func test_solo_despliegue_cero_sobrescribe_el_tema_del_chat() -> void:
	var ficheros: Array[String] = []
	_recopilar_gd("res://", ficheros)
	assert_int(ficheros.size()).is_greater(20)
	var encontrados: Array[String] = []
	for ruta: String in ficheros:
		var texto: String = FileAccess.get_file_as_string(ruta)
		if (texto.contains("func chat_topic(")
			or texto.contains("func discover_challenge(")):
			encontrados.append(ruta)
	assert_array(encontrados).contains_exactly_in_any_order(IMPLEMENTACIONES)


func _recopilar_gd(carpeta: String, resultado: Array[String]) -> void:
	for nombre: String in DirAccess.get_directories_at(carpeta):
		if IGNORADOS.has(nombre):
			continue
		_recopilar_gd(carpeta.path_join(nombre), resultado)
	for nombre: String in DirAccess.get_files_at(carpeta):
		if nombre.ends_with(".gd"):
			resultado.append(carpeta.path_join(nombre))
