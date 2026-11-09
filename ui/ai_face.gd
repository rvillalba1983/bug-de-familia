class_name AiFace
extends RefCounted
## Ojos y boca de cada IA en la pausa, según su personalidad. Los datos: data/art/ai_faces.json.

const DATA_PATH: String = "res://data/art/ai_faces.json"
const EYE_TYPES: Array[String] = [
	"normales", "desorbitados", "entornados", "guino", "miopes", "estrellas", "pantalla", "corazones", "lado",
	"gafas", "cielo", "desiguales", "dormidos", "furiosos", "pestanas", "vacios", "gafas_cuadradas", "aro", "hambrientos",
]
const EYE_GAP: float = 25.0
const EYE_RADIUS: float = 15.0
const WHITE: Color = Color("#fff6e0")
const INK: Color = Color("#140a1e")
const PUPIL: Color = Color("#1b0e2a")
const CYAN: Color = Color("#00e5ff")
const PINK: Color = Color("#ff1f8f")
const GOLD: Color = Color("#ffd400")
const BROW_WIDTH: float = 5.0

static var _faces: Dictionary = {}


static func face_of(id: String) -> Dictionary:
	if _faces.is_empty():
		_faces = DataFile.load_dictionary(DATA_PATH)
	return _faces[id]


## clock mueve las miradas; center es el punto entre los dos ojos.
static func draw_eyes(canvas: CanvasItem, center: Vector2, face: Dictionary, clock: float) -> void:
	var kind: String = face["eyes"]
	var left: Vector2 = center + Vector2(-EYE_GAP, 0.0)
	var right: Vector2 = center + Vector2(EYE_GAP, 0.0)
	var drift: Vector2 = Vector2(sin(clock * 0.9), cos(clock * 0.6) * 0.4) * 3.0
	match kind:
		"desorbitados":
			_eye(canvas, left, 19.0, 3.0, drift * 2.0)
			_eye(canvas, right, 19.0, 3.0, -drift * 2.0)
		"entornados", "lado":
			var look: Vector2 = Vector2(5.0, 1.0) if kind == "lado" else drift * 0.4
			_lidded(canvas, left, look, 0.55)
			_lidded(canvas, right, look, 0.55)
		"guino":
			_eye(canvas, left, EYE_RADIUS, 7.0, drift)
			_closed_arc(canvas, right, -1.0)
		"miopes":
			_eye(canvas, left, 21.0, 4.0, drift)
			_eye(canvas, right, 13.0, 3.0, -drift)
			canvas.draw_arc(left, 23.0, 0.0, TAU, 28, INK, 5.0)
			canvas.draw_arc(right, 23.0, 0.0, TAU, 28, INK, 5.0)
		"estrellas":
			_star(canvas, left, 18.0, GOLD)
			_star(canvas, right, 18.0, GOLD)
		"pantalla":
			_screen(canvas, center, clock)
		"corazones":
			_heart(canvas, left, 15.0)
			_heart(canvas, right, 15.0)
		"gafas":
			_eye(canvas, left, EYE_RADIUS, 6.0, Vector2.ZERO)
			_eye(canvas, right, EYE_RADIUS, 6.0, Vector2.ZERO)
			_spiral(canvas, left, clock)
			_spiral(canvas, right, -clock)
			canvas.draw_arc(left, 20.0, 0.0, TAU, 28, INK, 5.0)
			canvas.draw_arc(right, 20.0, 0.0, TAU, 28, INK, 5.0)
			canvas.draw_line(left + Vector2(20.0, 0.0), right - Vector2(20.0, 0.0), INK, 5.0)
		"cielo":
			_eye(canvas, left, EYE_RADIUS, 6.0, Vector2(0.0, -9.0))
			_eye(canvas, right, EYE_RADIUS, 6.0, Vector2(0.0, -9.0))
		"desiguales":
			_eye(canvas, left, 22.0, 5.0, drift * 2.5)
			_eye(canvas, right, 9.0, 4.0, Vector2.ZERO)
		"dormidos":
			_closed_arc(canvas, left, 1.0)
			_closed_arc(canvas, right, 1.0)
		"furiosos":
			_eye(canvas, left, EYE_RADIUS, 5.0, Vector2(4.0, 2.0))
			_eye(canvas, right, EYE_RADIUS, 5.0, Vector2(-4.0, 2.0))
		"pestanas":
			_eye(canvas, left, EYE_RADIUS, 8.0, drift)
			_eye(canvas, right, EYE_RADIUS, 8.0, drift)
			_lashes(canvas, left, -1.0)
			_lashes(canvas, right, 1.0)
		"vacios":
			canvas.draw_circle(left, EYE_RADIUS, INK)
			canvas.draw_circle(right, EYE_RADIUS, INK)
		"gafas_cuadradas":
			_eye(canvas, left, 11.0, 5.0, Vector2.ZERO)
			_eye(canvas, right, 11.0, 5.0, Vector2.ZERO)
			for at: Vector2 in [left, right]:
				canvas.draw_rect(Rect2(at - Vector2(18.0, 14.0), Vector2(36.0, 28.0)), INK, false, 4.0)
		"aro":
			_eye(canvas, left, EYE_RADIUS, 8.0, drift)
			_eye(canvas, right, EYE_RADIUS, 8.0, drift)
			canvas.draw_arc(left, 5.0, 0.0, TAU, 16, CYAN, 2.0)
			canvas.draw_arc(right, 5.0, 0.0, TAU, 16, CYAN, 2.0)
		"hambrientos":
			_eye(canvas, left, EYE_RADIUS, 7.0, Vector2(0.0, 6.0))
			_eye(canvas, right, EYE_RADIUS, 7.0, Vector2(0.0, 6.0))
		_:
			_eye(canvas, left, EYE_RADIUS, 6.0, drift)
			_eye(canvas, right, EYE_RADIUS, 6.0, drift)
	_brows(canvas, left, right, float(face["brow"]), bool(face.get("raised", false)))


static func _eye(canvas: CanvasItem, at: Vector2, radius: float, pupil: float, look: Vector2) -> void:
	canvas.draw_circle(at, radius + 3.0, INK)
	canvas.draw_circle(at, radius, WHITE)
	canvas.draw_circle(at + look.limit_length(radius - pupil), pupil, PUPIL)


## cover: parte del ojo tapada por el párpado.
static func _lidded(canvas: CanvasItem, at: Vector2, look: Vector2, cover: float) -> void:
	_eye(canvas, at, EYE_RADIUS, 6.0, look)
	var height: float = (EYE_RADIUS + 3.0) * 2.0 * cover
	var top: Vector2 = at - Vector2(EYE_RADIUS + 3.0, EYE_RADIUS + 3.0)
	canvas.draw_rect(Rect2(top, Vector2((EYE_RADIUS + 3.0) * 2.0, height)), INK)


## up: 1 dibuja un párpado caído y -1 un ojo guiñado hacia arriba.
static func _closed_arc(canvas: CanvasItem, at: Vector2, up: float) -> void:
	var start: float = 0.0 if up > 0.0 else PI
	canvas.draw_arc(at, EYE_RADIUS, start, start + PI, 20, INK, 5.0)


static func _star(canvas: CanvasItem, at: Vector2, radius: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(10):
		var reach: float = radius if index % 2 == 0 else radius * 0.45
		points.append(at + Vector2.from_angle(TAU * float(index) / 10.0 - PI * 0.5) * reach)
	canvas.draw_colored_polygon(points, color)
	points.append(points[0])
	canvas.draw_polyline(points, INK, 3.0)


static func _heart(canvas: CanvasItem, at: Vector2, size: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(24):
		var angle: float = TAU * float(index) / 24.0
		var x: float = pow(sin(angle), 3.0)
		var y: float = -(13.0 * cos(angle) - 5.0 * cos(2.0 * angle) - 2.0 * cos(3.0 * angle) - cos(4.0 * angle)) / 16.0
		points.append(at + Vector2(x, y) * size)
	canvas.draw_colored_polygon(points, PINK)
	points.append(points[0])
	canvas.draw_polyline(points, INK, 3.0)


static func _screen(canvas: CanvasItem, center: Vector2, clock: float) -> void:
	var area: Rect2 = Rect2(center - Vector2(46.0, 16.0), Vector2(92.0, 32.0))
	canvas.draw_rect(area, Color("#06121e"))
	var bar: float = fmod(clock * 0.7, 1.0)
	canvas.draw_rect(Rect2(area.position + Vector2(4.0, 12.0), Vector2((area.size.x - 8.0) * bar, 8.0)), CYAN)
	canvas.draw_rect(area, INK, false, 4.0)


static func _spiral(canvas: CanvasItem, at: Vector2, clock: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for index: int in range(16):
		var step: float = float(index) / 15.0
		points.append(at + Vector2.from_angle(clock * 2.0 + step * TAU * 1.5) * step * 11.0)
	canvas.draw_polyline(points, CYAN, 2.0)


static func _lashes(canvas: CanvasItem, at: Vector2, side: float) -> void:
	for index: int in range(4):
		var angle: float = -PI * 0.5 + side * (0.25 + float(index) * 0.32)
		var base: Vector2 = at + Vector2.from_angle(angle) * 17.0
		canvas.draw_line(base, base + Vector2.from_angle(angle) * 12.0, INK, 3.0)


## tilt positivo: cejas enfadadas; negativo: cejas de preocupación.
static func _brows(canvas: CanvasItem, left: Vector2, right: Vector2, tilt: float, raised: bool) -> void:
	if is_zero_approx(tilt) and not raised:
		return
	var lift: Vector2 = Vector2(0.0, -26.0)
	var drop: Vector2 = Vector2(0.0, tilt * 12.0)
	var side: Vector2 = Vector2(17.0, 0.0)
	var left_up: Vector2 = Vector2(0.0, -12.0) if raised else Vector2.ZERO
	canvas.draw_line(left + lift - side - drop + left_up, left + lift + side + drop + left_up, INK, BROW_WIDTH)
	canvas.draw_line(right + lift - side + drop, right + lift + side - drop, INK, BROW_WIDTH)
