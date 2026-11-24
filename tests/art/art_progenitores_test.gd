extends GdUnitTestSuite
## P-58: arte definitivo de los 15 progenitores, cinco vistas cada uno.
## Los SVG incrustan el raster generado; se comprueba tamaño, transparencia,
## contenido y que no queden restos del generador geométrico anterior.

const CARPETA: String = "res://art/shared/progenitores/"
const ORIGEN: String = "res://art/shared/progenitores/ORIGEN.md"
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
			assert_bool(texto.contains("<path")).is_false()
			assert_bool(texto.contains("<polygon")).is_false()
			assert_bool(texto.contains("<circle")).is_false()
			assert_bool(texto.contains("<rect")).is_false()
			assert_bool(texto.contains("<g ")).is_false()
			assert_bool(texto.contains('width="256"')).is_true()
			assert_bool(texto.contains('height="280"')).is_true()
			assert_int(texto.length()).is_greater(100_000)
			assert_bool(texto.contains("progenitores_gen.py")).is_false()


func test_cada_vista_tiene_un_raster_distinto() -> void:
	var globales: Array[String] = []
	for identificador: String in _progenitores():
		var locales: Array[String] = []
		for sufijo: String in SUFIJOS:
			var ruta: String = _ruta(identificador, sufijo)
			var texto: String = FileAccess.get_file_as_string(ruta)
			var incrustado: bool = texto.contains("data:image/png;base64,")
			assert_bool(incrustado).override_failure_message(ruta).is_true()
			var payload: String = _payload(texto)
			assert_int(payload.length()).override_failure_message(ruta).is_greater(100_000)
			var aviso: String = "%s%s repite el raster de otra vista" % [
				identificador, sufijo
			]
			assert_bool(locales.has(payload)).override_failure_message(aviso).is_false()
			assert_bool(globales.has(payload)).override_failure_message(aviso).is_false()
			locales.append(payload)
			globales.append(payload)
		assert_int(locales.size()).is_equal(SUFIJOS.size())
	assert_int(globales.size()).is_equal(75)


func test_ORIGEN_registra_las_75_vistas() -> void:
	var texto: String = FileAccess.get_file_as_string(ORIGEN)
	var filas: Array[String] = []
	for linea: String in texto.split("\n"):
		var limpia: String = linea.strip_edges()
		if limpia.begins_with("| `"):
			filas.append(limpia)
	assert_int(filas.size()).is_equal(75)
	var registradas: Dictionary = {}
	for fila: String in filas:
		var columnas: PackedStringArray = fila.split("|")
		assert_int(columnas.size()).is_greater_equal(5)
		if columnas.size() < 5:
			continue
		var archivo: String = columnas[1].strip_edges().replace("`", "")
		var modelo: String = columnas[3].strip_edges().replace("`", "")
		var referencia: String = columnas[4].strip_edges()
		assert_str(archivo).is_not_empty()
		assert_str(modelo).is_not_empty()
		assert_bool(modelo == "progenitores_gen.py").is_false()
		assert_str(referencia).is_not_empty()
		assert_bool(registradas.has(archivo)).is_false()
		registradas[archivo] = true
	var esperadas: Array[String] = []
	for identificador: String in _progenitores():
		for sufijo: String in SUFIJOS:
			esperadas.append(identificador + sufijo + ".svg")
	assert_int(esperadas.size()).is_equal(75)
	for nombre: String in esperadas:
		assert_bool(registradas.has(nombre)).override_failure_message(
			"Falta en ORIGEN.md: " + nombre
		).is_true()
	var huerfanas: Array[String] = []
	for nombre: String in registradas:
		if not esperadas.has(nombre):
			huerfanas.append(nombre)
	assert_array(huerfanas).is_empty()


func _payload(texto: String) -> String:
	var inicio: int = texto.find("base64,")
	if inicio < 0:
		return ""
	var fin: int = texto.find("\"", inicio + 7)
	if fin < 0:
		return ""
	return texto.substr(inicio + 7, fin - inicio - 7)


func test_la_ruta_de_arte_sigue_siendo_la_que_usa_guardvisual() -> void:
	for identificador: String in _progenitores():
		var datos: Dictionary = _progenitores()[identificador] as Dictionary
		assert_str(str(datos["art"])).is_equal("progenitores/" + identificador)
