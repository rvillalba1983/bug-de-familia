class_name BuildingFacade
extends Node2D
## Fachada de un edificio transitable. Se vuelve translúcida al acercarse el jugador,
## para que se vea el interior y se puedan leer las patrullas.

const FADE_NEAR: float = 160.0
const FADE_FAR: float = 460.0
const MIN_ALPHA: float = 0.28

var texture: Texture2D
## Zona que ocupa la fachada, relativa a este nodo.
var art_rect: Rect2
var interior: Rect2
var player: Player
## Puerta dibujada en la fachada y su hueco, relativo a este nodo.
var door_wall: Wall
var door_hole: Rect2
## Paredes interactivas tapadas por la fachada, para mantener visible su etiqueta.
var labeled_walls: Array[Wall] = []

var _door_was_open: bool = false


func _process(_delta: float) -> void:
	var distance: float = distance_to_rect(player.global_position, interior)
	modulate.a = remap(clampf(distance, FADE_NEAR, FADE_FAR), FADE_NEAR, FADE_FAR, MIN_ALPHA, 1.0)
	if door_wall != null and door_wall.is_open != _door_was_open:
		_door_was_open = door_wall.is_open
		queue_redraw()


func _draw() -> void:
	draw_texture_rect(texture, art_rect, false)
	if door_wall != null and door_wall.is_open:
		draw_rect(door_hole, Palette.INK)


static func distance_to_rect(point: Vector2, area: Rect2) -> float:
	var nearest: Vector2 = point.clamp(area.position, area.end)
	return point.distance_to(nearest)
