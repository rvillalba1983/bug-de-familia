class_name Sandbox
extends Node2D
## Escena de prueba con gráficos sencillos, en vista alta inclinada.
##
## Se dibuja por código a propósito: sirve de base para probar movimiento
## y sigilo antes de que exista arte definitivo.

const FLOOR_RECT: Rect2 = Rect2(160.0, 90.0, 1600.0, 900.0)
## Altura visible del frente de las paredes, que da la inclinación.
const WALL_FRONT_HEIGHT: float = 48.0
const WALLS: Array[Rect2] = [
	Rect2(400.0, 240.0, 420.0, 40.0),
	Rect2(1040.0, 240.0, 40.0, 320.0),
	Rect2(520.0, 620.0, 300.0, 40.0),
	Rect2(1240.0, 700.0, 280.0, 40.0),
]
const PLAYER_START: Vector2 = Vector2(320.0, 840.0)
const PLAYER_RADIUS: float = 24.0

const COLOR_BACKGROUND: Color = Color("#1d1b26")
const COLOR_FLOOR: Color = Color("#3b4a3a")
const COLOR_WALL_TOP: Color = Color("#8f8aa8")
const COLOR_WALL_FRONT: Color = Color("#55506e")
const COLOR_SHADOW: Color = Color(0.0, 0.0, 0.0, 0.35)
const COLOR_PLAYER: Color = Color("#e0651f")
const COLOR_PLAYER_EYE: Color = Color("#35e0ff")


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1920.0, 1080.0)), COLOR_BACKGROUND)
	draw_rect(FLOOR_RECT, COLOR_FLOOR)
	_draw_player_placeholder()
	for wall: Rect2 in WALLS:
		_draw_wall(wall)


func _draw_wall(wall: Rect2) -> void:
	var front: Rect2 = Rect2(wall.position + Vector2(0.0, wall.size.y), Vector2(wall.size.x, WALL_FRONT_HEIGHT))
	var shadow: Rect2 = Rect2(front.position + Vector2(0.0, WALL_FRONT_HEIGHT), Vector2(wall.size.x, 14.0))
	draw_rect(shadow, COLOR_SHADOW)
	draw_rect(front, COLOR_WALL_FRONT)
	draw_rect(wall, COLOR_WALL_TOP)


func _draw_player_placeholder() -> void:
	draw_circle(PLAYER_START + Vector2(0.0, PLAYER_RADIUS * 0.9), PLAYER_RADIUS * 0.8, COLOR_SHADOW)
	draw_circle(PLAYER_START, PLAYER_RADIUS, COLOR_PLAYER)
	draw_circle(PLAYER_START + Vector2(10.0, -4.0), 6.0, COLOR_PLAYER_EYE)
