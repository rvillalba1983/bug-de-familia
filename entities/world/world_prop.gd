class_name WorldProp
extends Node2D
## Objeto del decorado que solo existe para verse y, si acaso, convertirse.

var _texture: Texture2D
var _size: Vector2


func setup(art: String, at: Vector2, size: Vector2) -> void:
	_texture = PropArt.texture(art)
	_size = size
	position = at


func _draw() -> void:
	draw_circle(Vector2(0.0, 2.0), 16.0, Color(0.0, 0.0, 0.0, 0.3))
	draw_texture_rect(_texture, Rect2(Vector2(-_size.x * 0.5, -_size.y), _size), false)
