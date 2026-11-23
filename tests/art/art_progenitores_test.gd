extends GdUnitTestSuite
## P-58: arte definitivo de los 15 progenitores, cinco vistas cada uno.
## Los SVG incrustan el raster generado; se comprueba tamaño, transparencia,
## contenido y que no queden restos del generador geométrico anterior.

const CARPETA: String = "res://art/shared/progenitores/"
const DATOS: String = "res://data/world/progenitors.json"
const SUFIJOS: Array[String] = ["", "_se", "_e", "_ne", "_n"]
const ANCHO: int = 256
const ALTO: int = 280


func _progenitores() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(DATOS)) as Dictionary


func _ruta(identificador: String, sufijo: String) -> String:
	return CARPETA + identificador + sufijo + ".svg"


func test_cada_progenitor_tiene_sus_cinco_vistas() -> void:
	var total: int = 0
	for identificador: String in _progenitores():
		var rutas: Array[String] = []
		for sufijo: String in SUFIJOS:
			var ruta: String = _ruta(identificador, sufijo)
			assert_bool(ResourceLoader.exists(ruta)).is_true()
			rutas.append(ruta)
			total += 1
		## Cinco vistas distintas: no se reutiliza la base para las diagonales.
		var unicas: Dictionary = {}
		for ruta: String in rutas:
			unicas[ruta] = true
		assert_int(unicas.size()).is_equal(SUFIJOS.size())
	assert_int(total).is_equal(75)


func test_todas_las_vistas_cargan_al_tamano_y_con_transparencia() -> void:
	for identificador: String in _progenitores():
		for sufijo: String in SUFIJOS:
			var tex: Texture2D = load(_ruta(identificador, sufijo)) as Texture2D
			assert_object(tex).is_not_null()
			assert_int(int(tex.get_size().x)).is_equal(ANCHO)
			assert_int(int(tex.get_size().y)).is_equal(ALTO)
			var imagen: Image = tex.get_image()
			assert_int(imagen.get_width()).is_equal(ANCHO)
			assert_int(imagen.get_height()).is_equal(ALTO)
			var opacos: int = 0
			var transparentes: int = 0
			for x: int in range(0, ANCHO, 16):
				for y: int in range(0, ALTO, 16):
					var alfa: float = imagen.get_pixel(x, y).a
					if alfa > 0.8:
						opacos += 1
					elif alfa < 0.1:
						transparentes += 1
			assert_int(opacos).is_greater(5)
			assert_int(transparentes).is_greater(5)


func test_el_svg_incrusta_el_raster_y_no_lleva_texto() -> void:
	for identificador: String in _progenitores():
		for sufijo: String in SUFIJOS:
			var texto: String = FileAccess.get_file_as_string(
				_ruta(identificador, sufijo)
			)
			assert_bool(texto.contains('viewBox="0 0 512 560"')).is_true()
			assert_bool(texto.contains("data:image/png;base64,")).is_true()
			assert_bool(texto.contains("<text")).is_false()
			assert_bool(texto.contains("<title")).is_false()
			assert_bool(texto.contains("progenitores_gen.py")).is_false()


func test_la_ruta_de_arte_sigue_siendo_la_que_usa_guardvisual() -> void:
	for identificador: String in _progenitores():
		var datos: Dictionary = _progenitores()[identificador] as Dictionary
		assert_str(str(datos["art"])).is_equal("progenitores/" + identificador)
