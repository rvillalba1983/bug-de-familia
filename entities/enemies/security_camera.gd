class_name SecurityCamera
extends Node2D
## Cámara fija que barre un sector y da la alarma.

signal alarm_raised(position: Vector2)

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


func setup(at: Vector2, center_degrees: float, amplitude_degrees: float, ground: Node2D) -> void:
	position = at
	_center = deg_to_rad(center_degrees)
	_amplitude = deg_to_rad(amplitude_degrees)
	detector.facing_angle = _center
	_view = Sentinel.add_cone(self, ground, detector)
	detector.detected.connect(func(where: Vector2) -> void: alarm_raised.emit(where))


func _physics_process(delta: float) -> void:
	_phase += delta * SWEEP_SPEED * TAU * 0.5
	detector.facing_angle = _center + sin(_phase) * _amplitude
	detector.update(global_position, get_world_2d(), target, delta)
	_view.refresh(global_position, get_world_2d())


func _draw() -> void:
	draw_rect(Rect2(-12.0, -60.0, 24.0, 24.0), COLOR_BODY)
