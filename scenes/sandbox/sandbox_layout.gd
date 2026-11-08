class_name SandboxLayout
extends RefCounted
## Datos del primer reto: cruzar una zona vigilada. Se resuelve de al menos tres formas:
## pasar por las coberturas, atraer al guardia con ruido o abrir la puerta de servicio.

const FLOOR_RECT: Rect2 = Rect2(160.0, 90.0, 1600.0, 900.0)
const WALL_FRONT_HEIGHT: float = 48.0
const LOW_FRONT_HEIGHT: float = 18.0
const WALLS: Array[Rect2] = [
	Rect2(1040.0, 90.0, 40.0, 80.0),
	Rect2(1040.0, 270.0, 40.0, 210.0),
	Rect2(1040.0, 620.0, 40.0, 370.0),
	Rect2(640.0, 340.0, 400.0, 40.0),
	Rect2(420.0, 640.0, 300.0, 40.0),
	Rect2(1300.0, 300.0, 200.0, 40.0),
]
const LOW_COVERS: Array[Rect2] = [
	Rect2(800.0, 730.0, 210.0, 30.0),
]
const DOOR: Rect2 = Rect2(1040.0, 170.0, 40.0, 100.0)
const GOAL: Rect2 = Rect2(1600.0, 440.0, 160.0, 220.0)
const PLAYER_START: Vector2 = Vector2(240.0, 880.0)
const SAVE_POINTS: Array[Vector2] = [Vector2(240.0, 880.0), Vector2(1200.0, 550.0)]
const GUARD_PATROL: Array[Vector2] = [Vector2(880.0, 440.0), Vector2(880.0, 680.0)]
const DRONE_PATROL: Array[Vector2] = [Vector2(460.0, 500.0), Vector2(860.0, 500.0)]
const CAMERA_POSITION: Vector2 = Vector2(330.0, 130.0)
const CAMERA_CENTER_DEGREES: float = 20.0
const CAMERA_AMPLITUDE_DEGREES: float = 35.0
const CRATE: Vector2 = Vector2(470.0, 790.0)
const CRATE_NOISE_RADIUS: float = 640.0
const TERMINAL: Vector2 = Vector2(560.0, 195.0)
const PICKUP_LEG: Vector2 = Vector2(300.0, 520.0)
const PICKUP_ARM: Vector2 = Vector2(1400.0, 850.0)
