class_name VisionConeView
extends Node2D
## Dibuja un cono de visión recortado por las paredes.

const RAY_COUNT: int = 16
const COLOR_CALM: Color = Color(0.5, 0.9, 0.5, 0.22)
const COLOR_ALERT: Color = Color(1.0, 0.25, 0.2, 0.42)

var detector: Detector

var _origin: Vector2 = Vector2.ZERO
var _points: PackedVector2Array = PackedVector2Array()


func refresh(origin: Vector2, world: World2D) -> void:
	_origin = origin
	_points.clear()
	for index: int in range(RAY_COUNT + 1):
		var step: float = float(index) / float(RAY_COUNT)
		var angle: float = detector.facing_angle + lerpf(-detector.half_angle, detector.half_angle, step)
		var tip: Vector2 = origin + Vector2.from_angle(angle) * detector.view_range
		_points.append(Detector.ray_end(origin, tip, world, PhysicsLayers.WALLS))
	queue_redraw()


func _draw() -> void:
	var color: Color = COLOR_CALM.lerp(COLOR_ALERT, detector.meter)
	var colors: PackedColorArray = PackedColorArray([color, color, color])
	for index: int in range(_points.size() - 1):
		var triangle: PackedVector2Array = PackedVector2Array(
			[_origin, _points[index], _points[index + 1]]
		)
		draw_primitive(triangle, colors, PackedVector2Array())
	if detector.meter > 0.0 and _points.size() > 1:
		var edge: PackedVector2Array = _points.duplicate()
		var suspicion: Color = COLOR_ALERT.lerp(Color("#ffd24a"), 1.0 - detector.meter)
		draw_polyline(edge, Color(suspicion, 0.9), 2.0 + 4.0 * detector.meter)
