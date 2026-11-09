class_name BodyHud
extends Control
## El cuerpo es la interfaz: la silueta del protagonista muestra el desgaste de cada pieza.
## Valores provisionales, a ajustar al probar.

const FEET: Vector2 = Vector2(124.0, 696.0)
const ART_SIZE: float = 0.17
const PLATE: Rect2 = Rect2(14.0, 486.0, 220.0, 226.0)
const PLATE_COLOR: Color = Color(0.106, 0.055, 0.165, 0.62)
const HIT_DROP: float = 0.02
const HIT_TIME: float = 0.3
const LOW_RATIO: float = 0.25
const LOW_PULSE_SPEED: float = 8.0

var body: ModularBody

var _ratios: Dictionary = {}
var _hits: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.changed.connect(_on_body_changed)
	_remember_ratios()


func _process(delta: float) -> void:
	var animating: bool = _any_low()
	for slot: int in _hits.keys():
		_hits[slot] = float(_hits[slot]) - delta
		animating = true
		if float(_hits[slot]) <= 0.0:
			_hits.erase(slot)
	if animating:
		queue_redraw()


func _draw() -> void:
	draw_rect(PLATE, PLATE_COLOR)
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * LOW_PULSE_SPEED)
	ProtagonistArt.draw_silhouette(self, FEET, ART_SIZE, body, _hits, pulse)


## Parte de un golpe: se marca la pieza que ha perdido vida de repente.
func was_just_hit(slot: ModularBody.Slot) -> bool:
	return _hits.has(slot)


func _on_body_changed() -> void:
	for slot: int in ModularBody.Slot.values():
		var ratio: float = _ratio_of(slot)
		if float(_ratios.get(slot, 0.0)) - ratio >= HIT_DROP:
			_hits[slot] = HIT_TIME
	_remember_ratios()
	queue_redraw()


func _remember_ratios() -> void:
	for slot: int in ModularBody.Slot.values():
		_ratios[slot] = _ratio_of(slot)


func _ratio_of(slot: int) -> float:
	var piece: BodyPiece = body.equipped(slot as ModularBody.Slot)
	return 0.0 if piece == null else piece.durability / BodyPiece.MAX_DURABILITY


func _any_low() -> bool:
	for slot: int in ModularBody.Slot.values():
		var ratio: float = _ratio_of(slot)
		if ratio > 0.0 and ratio < LOW_RATIO:
			return true
	return false
