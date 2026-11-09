class_name GuardImpacts
extends RefCounted
## Temblor, parón y deformación al golpear o derribar a un guardia. Valores provisionales.

const HIT_SHAKE: float = 5.0
const HIT_STOP: float = 0.04
const HIT_SQUASH: Vector2 = Vector2(0.82, 1.14)
const FALL_SHAKE: float = 9.0
const FALL_STOP: float = 0.08
const LAND_DELAY: float = 0.45
const LAND_SHAKE: float = 6.0
const LAND_SQUASH: Vector2 = Vector2(1.2, 0.72)

## Lo que le pasa a un habitante por su cuenta no sacude la pantalla del jugador.
var quiet: bool = false

var _guard: Guard


func _init(guard: Guard) -> void:
	_guard = guard


func on_hit() -> void:
	if not _guard.is_inside_tree():
		return
	ImpactFx.shake(_guard.get_viewport(), HIT_SHAKE)
	ImpactFx.hit_stop(_guard.get_tree(), HIT_STOP)
	var root: Node2D = _guard.visual.rig_root
	if root == null:
		return
	ImpactFx.flash(root)
	ImpactFx.squash(root, "scale", HIT_SQUASH)


func on_fall() -> void:
	if not _guard.is_inside_tree() or quiet:
		return
	ImpactFx.shake(_guard.get_viewport(), FALL_SHAKE)
	ImpactFx.hit_stop(_guard.get_tree(), FALL_STOP)
	if _guard.visual.rig_root == null:
		return
	var tween: Tween = _guard.create_tween()
	tween.tween_interval(LAND_DELAY)
	tween.tween_callback(_on_landing)


## El golpe contra el suelo al terminar de caer.
func _on_landing() -> void:
	ImpactFx.shake(_guard.get_viewport(), LAND_SHAKE)
	ImpactFx.squash(_guard.visual.rig_root, "scale", LAND_SQUASH)
