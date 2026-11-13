class_name BetaAmbient
extends Node2D
## Fondo, solo visual: charcos, cables, plantas y copas de árbol a otra velocidad, todo quieto
## por rendimiento (docs/adr/0017). Se dibuja solo cerca del jugador.

const REDRAW_DISTANCE: float = 6.0
const NEAR: float = 1200.0
const PUDDLES: Array[Vector2] = [Vector2(1400.0, 1290.0), Vector2(2150.0, 1360.0), Vector2(900.0, 1500.0), Vector2(2900.0, 1250.0)]
const CABLES: Array[Array] = [
	[Vector2(1320.0, 1160.0), Vector2(1560.0, 1140.0)], [Vector2(1900.0, 1140.0), Vector2(2140.0, 1160.0)],
	[Vector2(1340.0, 1500.0), Vector2(1600.0, 1520.0)],
]
const PLANTS: Array[Vector2] = [Vector2(1180.0, 1000.0), Vector2(1120.0, 1560.0), Vector2(2260.0, 1100.0), Vector2(860.0, 1240.0), Vector2(2780.0, 1500.0)]
const CANOPIES: Array[Vector2] = [Vector2(220.0, 420.0), Vector2(440.0, 1100.0), Vector2(260.0, 1900.0), Vector2(640.0, 2300.0), Vector2(3480.0, 500.0), Vector2(3600.0, 2100.0), Vector2(860.0, 280.0)]
const CANOPY_PARALLAX: float = 0.09
const CANOPY_CLEAR: float = 170.0
const COLOR_WATER: Color = Color(0.3, 0.8, 0.9, 0.55)
const COLOR_FLY: Color = Color("#1b0e2a")
const COLOR_CABLE: Color = Color("#1b0e2a")
const COLOR_PLANT: Color = Color("#2fbf71")
const COLOR_CANOPY: Color = Color(0.1, 0.32, 0.22, 0.72)

var follow: Node2D

var _drawn_at: Vector2 = Vector2.INF


func _ready() -> void:
	z_index = 1
	z_as_relative = false


func _process(_delta: float) -> void:
	if is_instance_valid(follow) and follow.global_position.distance_to(_drawn_at) >= REDRAW_DISTANCE:
		queue_redraw()


func _draw() -> void:
	if not is_instance_valid(follow):
		return
	var feet: Vector2 = follow.global_position
	_drawn_at = feet
	for at: Vector2 in PUDDLES:
		if at.distance_to(feet) < NEAR:
			_puddle(at)
	for cable: Array in CABLES:
		if (cable[0] as Vector2).distance_to(feet) < NEAR:
			_cable(cable[0], cable[1])
	for at: Vector2 in PLANTS:
		if at.distance_to(feet) < NEAR:
			_plant(at)
	var drift: Vector2 = (feet - DespliegueCeroLayout.world_size * 0.5) * CANOPY_PARALLAX
	for index: int in range(CANOPIES.size()):
		var top: Vector2 = CANOPIES[index] - drift
		if top.distance_to(feet) < NEAR * 1.3:
			_canopy(top, index, _canopy_alpha(top, feet))


func _puddle(at: Vector2) -> void:
	draw_set_transform(at, 0.0, Vector2(1.0, 0.4))
	CircleDot.draw(self, Vector2.ZERO, 62.0, Color(0.18, 0.3, 0.4, 0.55))
	draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 24, Color(COLOR_WATER, COLOR_WATER.a * 0.5), 2.0)
	draw_set_transform(Vector2.ZERO)


func _cable(from: Vector2, to: Vector2) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(13):
		var step: float = float(index) / 12.0
		var sag: float = 40.0 * 4.0 * step * (1.0 - step)
		points.append(from.lerp(to, step) + Vector2(0.0, sag - 90.0))
	draw_polyline(points, COLOR_CABLE, 3.0)


func _plant(at: Vector2) -> void:
	for blade: int in range(5):
		var lean: float = float(blade - 2) * 0.28
		var tip: Vector2 = at + Vector2.UP.rotated(lean) * (32.0 + 7.0 * float(blade % 3))
		draw_line(at, tip, COLOR_FLY, 6.0)
		draw_line(at, tip, COLOR_PLANT, 3.0)


## Nunca tapa al protagonista: al acercarse, la copa se vuelve casi transparente.
func _canopy_alpha(top: Vector2, feet: Vector2) -> float:
	return lerpf(0.08, COLOR_CANOPY.a, clampf((top.distance_to(feet) - CANOPY_CLEAR) / CANOPY_CLEAR, 0.0, 1.0))


func _canopy(at: Vector2, index: int, alpha: float) -> void:
	for blob: int in range(5):
		var angle: float = TAU * float(blob) / 5.0 + float(index)
		CircleDot.draw(self, at + Vector2.from_angle(angle) * 54.0, 62.0, Color(COLOR_CANOPY, alpha))
