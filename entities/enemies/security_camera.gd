class_name SecurityCamera
extends Node2D
## Cámara fija que barre un sector y da la alarma.

signal alarm_raised(position: Vector2)

const ART: Array = ["camara", 60.0, 55.0]

## Valores provisionales, a ajustar al probar.
const VIEW_RANGE: float = 380.0
const VIEW_HALF_ANGLE: float = 18.0
const SWEEP_SPEED: float = 0.5
const COLOR_BODY: Color = Color("#d07030")

var detector: Detector = Detector.new(VIEW_RANGE, VIEW_HALF_ANGLE, false)
var target: Player
var disabled: bool = false

var _center: float = 0.0
var _amplitude: float = 0.0
var _phase: float = 0.0
var _view: VisionConeView
var _disabled_time: float = 0.0


func setup(at: Vector2, center_degrees: float, amplitude_degrees: float, ground: Node2D) -> void:
	position = at
	_center = deg_to_rad(center_degrees)
	_amplitude = deg_to_rad(amplitude_degrees)
	detector.facing_angle = _center
	_view = Sentinel.add_cone(self, ground, detector)
	detector.detected.connect(func(where: Vector2) -> void: alarm_raised.emit(where))


## Inutiliza el aparato durante un rato.
func blind(duration: float) -> void:
	_disabled_time = duration
	detector.reset()
	_view.visible = false


func _exit_tree() -> void:
	_view.queue_free()


func _physics_process(delta: float) -> void:
	if _disabled_time > 0.0:
		_disabled_time -= delta
		_view.visible = _disabled_time <= 0.0
		return
	_phase += delta * SWEEP_SPEED * TAU * 0.5
	detector.facing_angle = _center + sin(_phase) * _amplitude
	detector.update(global_position, get_world_2d(), target, delta)
	_view.refresh(global_position, get_world_2d())


func _draw() -> void:
	PropArt.draw_entry(self, ART)
