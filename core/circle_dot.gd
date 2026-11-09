class_name CircleDot
extends RefCounted
## Círculos dibujados con una textura compartida. Con draw_circle cada uno es un polígono propio,
## muy caro en gráficas integradas (medido en docs/adr/0016); con textura se agrupan.

const BIG_SIZE: int = 256
const SMALL_SIZE: int = 32
const SMALL_RADIUS: float = 12.0

static var _big: ImageTexture
static var _small: ImageTexture


static func draw(canvas: CanvasItem, center: Vector2, radius: float, color: Color) -> void:
	var side: Vector2 = Vector2(radius, radius)
	canvas.draw_texture_rect(_texture_for(radius), Rect2(center - side, side * 2.0), false, color)


static func _texture_for(radius: float) -> ImageTexture:
	if _big == null:
		_big = _bake(BIG_SIZE)
		_small = _bake(SMALL_SIZE)
	return _small if radius < SMALL_RADIUS else _big


static func _bake(size: int) -> ImageTexture:
	var image: Image = Image.create(size, size, false, Image.FORMAT_LA8)
	var center: float = float(size) * 0.5
	for y: int in range(size):
		for x: int in range(size):
			var distance: float = Vector2(float(x) + 0.5, float(y) + 0.5).distance_to(Vector2(center, center))
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(center - distance, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)
