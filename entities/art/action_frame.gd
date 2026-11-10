class_name ActionFrame
extends RefCounted
## Fotograma actual de una acción del personaje (idle/ataque/recarga). Provisional, P-25.
## Usa el reloj del motor, no el RNG global: no altera la semilla de la partida.

var action: String = ActionFrameCatalog.DEFAULT
## Permite fijar el reloj en pruebas; si no es válida, usa el reloj del motor.
var time_source: Callable = Callable()

var _start: float = 0.0


func _init() -> void:
	_start = _now()


## Reinicia el reloj de la acción, también al inyectar un reloj de prueba.
func reset() -> void:
	_start = _now()


func set_action(next: String) -> void:
	if not ActionFrameCatalog.has_action(next) or next == action:
		return
	action = next
	_start = _now()


func elapsed() -> float:
	return maxf(_now() - _start, 0.0)


func current_index() -> int:
	var claves: Array[String] = ActionFrameCatalog.frames(action)
	if claves.is_empty():
		return 0
	return int(elapsed() * ActionFrameCatalog.fps(action)) % claves.size()


func current_key() -> String:
	var claves: Array[String] = ActionFrameCatalog.frames(action)
	return "" if claves.is_empty() else claves[current_index()]


func _now() -> float:
	if time_source.is_valid():
		return float(time_source.call())
	return float(Time.get_ticks_usec()) / 1000000.0