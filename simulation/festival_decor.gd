class_name FestivalDecor
extends Node2D
## Adorno de la fiesta del día. Si el jugador la revienta, se queda hecho polvo.

const COLOR_POLE: Color = Color("#3a2c55")
const FLAGS: Array[Color] = [Color("#ff2d8a"), Color("#00e5ff"), Color("#c6ff00"), Color("#ffd400")]
const COLOR_RUIN: Color = Color("#6a5f70")
const COLOR_LOST: Color = Color("#ffd400")
const WIDTH: float = 180.0
const POLE_HEIGHT: float = 120.0
const FLAG_COUNT: int = 8

var title: String = ""
var ruined: bool = false


func show_at(at: Vector2, new_title: String, is_ruined: bool) -> void:
	position = at
	title = new_title
	ruined = is_ruined
	queue_redraw()


func _draw() -> void:
	for side: float in [-WIDTH, WIDTH]:
		draw_line(Vector2(side, 0.0), Vector2(side, -POLE_HEIGHT), COLOR_POLE, 7.0)
	for index: int in range(FLAG_COUNT):
		var t: float = (float(index) + 0.5) / float(FLAG_COUNT)
		var x: float = lerpf(-WIDTH, WIDTH, t)
		var sag: float = 26.0 * (1.0 - pow(2.0 * t - 1.0, 2.0))
		var y: float = -POLE_HEIGHT + sag + (40.0 if ruined and index % 2 == 0 else 0.0)
		var color: Color = COLOR_RUIN if ruined else FLAGS[index % FLAGS.size()]
		draw_colored_polygon(
			PackedVector2Array([Vector2(x - 13.0, y), Vector2(x + 13.0, y), Vector2(x, y + 30.0)]), color
		)
	WorldLabel.draw_on(self, title, Vector2(0.0, -POLE_HEIGHT - 16.0))
