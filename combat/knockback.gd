class_name Knockback
extends RefCounted
## Retroceso al recibir daño, decidido por el director para separar a los que pelean.
## Valores provisionales: 4,5 metros, con un personaje de 1,7 m dibujado a 30 unidades de alto.

const DISTANCE: float = 80.0
const DURATION: float = 0.16

var _time_left: float = 0.0
var _velocity: Vector2 = Vector2.ZERO


func start(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	_velocity = direction.normalized() * DISTANCE / DURATION
	_time_left = DURATION


func is_active() -> bool:
	return _time_left > 0.0


## Velocidad de este paso de física; al acabar el retroceso deja de estar activo.
func tick(delta: float) -> Vector2:
	_time_left = maxf(_time_left - delta, 0.0)
	return _velocity
