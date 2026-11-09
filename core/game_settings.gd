class_name GameSettings
extends RefCounted
## Opciones del jugador. Se guardan aparte de la partida.

const PATH: String = "user://opciones.cfg"
const TEXT_SCALES: Array[float] = [1.0, 1.25, 1.5]
const VOLUMES: Array[float] = [1.0, 0.5, 0.0]

static var path: String = PATH
static var text_scale: float = 1.0
static var reduce_motion: bool = false
static var high_contrast: bool = false
static var music_volume: float = 0.7
static var voice_volume: float = 1.0
static var _loaded: bool = false


static func ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	var file: ConfigFile = ConfigFile.new()
	if file.load(path) != OK:
		return
	text_scale = float(file.get_value("opciones", "texto", 1.0))
	reduce_motion = bool(file.get_value("opciones", "temblores", false))
	high_contrast = bool(file.get_value("opciones", "contraste", false))
	music_volume = float(file.get_value("opciones", "musica", 0.7))
	voice_volume = float(file.get_value("opciones", "voces", 1.0))


static func save() -> void:
	var file: ConfigFile = ConfigFile.new()
	file.set_value("opciones", "texto", text_scale)
	file.set_value("opciones", "temblores", reduce_motion)
	file.set_value("opciones", "contraste", high_contrast)
	file.set_value("opciones", "musica", music_volume)
	file.set_value("opciones", "voces", voice_volume)
	var result: Error = file.save(path)
	if result != OK:
		push_error("No se han podido guardar las opciones en %s: %s" % [path, error_string(result)])


## Vuelve a los valores de fábrica; lo usan las pruebas.
static func reset() -> void:
	text_scale = 1.0
	reduce_motion = false
	high_contrast = false
	music_volume = 0.7
	voice_volume = 1.0
	_loaded = true


static func font_size(base: int) -> int:
	return roundi(float(base) * text_scale)


static func cycle(values: Array[float], current: float) -> float:
	var index: int = values.find(current)
	return values[(index + 1) % values.size()]
