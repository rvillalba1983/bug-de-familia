class_name Drone
extends Node2D
## Dron de patrulla que vuela sobre las coberturas y da la alarma.

signal alarm_raised(position: Vector2)

## Valores provisionales, a ajustar al probar.
const SPEED: float = 130.0
const VIEW_RANGE: float = 200.0
const VIEW_HALF_ANGLE: float = 40.0
const FLY_HEIGHT: float = 70.0
const ART_FOLDER: String = "res://art/shared/"
const ART_BASE: String = "dron_viejo"
const ART_SIZE: float = 64.0

var detector: Detector = Detector.new(VIEW_RANGE, VIEW_HALF_ANGLE, false)
var target: Player

## Una textura por vista, en el orden de `GuardVisual`: sur, sureste, este,
## nordeste y norte. El dron comparte con los guardias el reparto de 8 direcciones.
var _views: Array[Texture2D] = []
var _patrol: Array[Vector2] = []
var _patrol_index: int = 0
var _view: VisionConeView
var _disabled_time: float = 0.0


func _init() -> void:
	for view: int in GuardVisual.VIEW_SUFFIX.size():
		_views.append(texture_of(view))


func setup(points: Array[Vector2], ground: Node2D) -> void:
	_patrol = points
	position = points[0]
	_view = Sentinel.add_cone(self, ground, detector)
	detector.detected.connect(func(at: Vector2) -> void: alarm_raised.emit(at))


## Inutiliza el aparato durante un rato.
func confuse(duration: float) -> void:
	_disabled_time = duration
	detector.reset()
	_view.visible = false


## Textura de esa dirección; pública para las pruebas.
func art_for(direction: Vector2) -> Texture2D:
	return _views[GuardVisual.view_for(direction)]


## Cierto si esa dirección dibuja la vista lateral espejada.
func mirrored_for(direction: Vector2) -> bool:
	return GuardVisual.is_mirrored(direction)


func _exit_tree() -> void:
	_view.queue_free()


func _physics_process(delta: float) -> void:
	if _disabled_time > 0.0:
		_disabled_time -= delta
		_view.visible = _disabled_time <= 0.0
		return
	var goal: Vector2 = _patrol[_patrol_index]
	if global_position.distance_to(goal) < 4.0:
		_patrol_index = (_patrol_index + 1) % _patrol.size()
	else:
		var direction: Vector2 = global_position.direction_to(goal)
		global_position = global_position.move_toward(goal, SPEED * delta)
		detector.facing_angle = direction.angle()
	detector.update(global_position, get_world_2d(), target, delta)
	_view.refresh(global_position, get_world_2d())


func _draw() -> void:
	var corner: Vector2 = Vector2(-ART_SIZE * 0.5, -FLY_HEIGHT - ART_SIZE * 0.5)
	var direction: Vector2 = Vector2.from_angle(detector.facing_angle)
	var size: Vector2 = Vector2(ART_SIZE, ART_SIZE)
	if mirrored_for(direction):
		corner.x = ART_SIZE * 0.5
		size.x = -ART_SIZE
	draw_texture_rect(art_for(direction), Rect2(corner, size), false)
	draw_line(Vector2.ZERO, Vector2(0.0, -FLY_HEIGHT), Color(1.0, 1.0, 1.0, 0.2), 1.0)


## Ruta del archivo de una vista.
static func path_of(view: int) -> String:
	return ART_FOLDER + ART_BASE + GuardVisual.VIEW_SUFFIX[view] + ".svg"


## Textura de una vista, cargada de su archivo. Desde P-52 el arte dibuja las cinco
## vistas: no hay respaldo con la lateral, así que un archivo que falte da nulo.
static func texture_of(view: int) -> Texture2D:
	return load(path_of(view)) as Texture2D
