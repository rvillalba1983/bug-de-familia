class_name ThreatEdges
extends Control
## Avisos en el borde: flecha si te detectan fuera de vista y marca de ruido lejano.

const MARGIN: float = 46.0
const NOISE_TIME: float = 1.2
const VIEW: Rect2 = Rect2(0.0, 0.0, 1920.0, 1080.0)
const COLOR_ALERT: Color = Color("#ff4a3a")
const COLOR_NOISE: Color = Color("#ffe14a")

var level: BetaZone

var _noises: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	level.noise_bus.noise_emitted.connect(_on_noise)


func _process(delta: float) -> void:
	for noise: Array in _noises:
		noise[1] = float(noise[1]) - delta
	_noises = _noises.filter(func(noise: Array) -> bool: return float(noise[1]) > 0.0)
	queue_redraw()


func offscreen_threats() -> int:
	var count: int = 0
	var view: Transform2D = get_viewport().get_canvas_transform()
	for guard: Guard in level.guards():
		if _is_threat(guard) and not VIEW.has_point(view * guard.global_position):
			count += 1
	return count


func _is_threat(guard: Guard) -> bool:
	return not guard.is_down() and not guard.passive and (guard.is_alert() or guard.detector.meter > 0.5)


func _on_noise(origin: Vector2, radius: float) -> void:
	if origin.distance_to(level.player.global_position) <= radius:
		_noises.append([origin, NOISE_TIME])


func _draw() -> void:
	var view: Transform2D = get_viewport().get_canvas_transform()
	for guard: Guard in level.guards():
		var at: Vector2 = view * guard.global_position
		if _is_threat(guard) and not VIEW.has_point(at):
			_arrow(at, COLOR_ALERT)
	for noise: Array in _noises:
		var at: Vector2 = view * (noise[0] as Vector2)
		if not VIEW.has_point(at):
			var edge: Vector2 = _edge_point(at)
			var color: Color = COLOR_NOISE
			color.a = float(noise[1]) / NOISE_TIME
			draw_arc(edge, 26.0, 0.0, TAU, 20, color, 5.0)
			draw_arc(edge, 42.0, 0.0, TAU, 20, color, 3.0)


func _edge_point(at: Vector2) -> Vector2:
	var center: Vector2 = VIEW.get_center()
	var offset: Vector2 = at - center
	var limit: Vector2 = center - Vector2(MARGIN, MARGIN)
	var factor: float = minf(limit.x / maxf(absf(offset.x), 1.0), limit.y / maxf(absf(offset.y), 1.0))
	return center + offset * minf(factor, 1.0)


func _arrow(at: Vector2, color: Color) -> void:
	var tip: Vector2 = _edge_point(at)
	var direction: Vector2 = VIEW.get_center().direction_to(at)
	var side: Vector2 = direction.orthogonal() * 18.0
	var back: Vector2 = tip - direction * 34.0
	draw_colored_polygon(PackedVector2Array([tip, back + side, back - side]), color)
