class_name BodyHud
extends Control
## El cuerpo es la interfaz: la silueta del protagonista muestra el desgaste de cada pieza.
## Valores provisionales, a ajustar al probar.

const FEET: Vector2 = Vector2(142.0, 572.0)
const ART_SIZE: float = 0.19
const PLATE: Rect2 = Rect2(14.0, 254.0, IrcChat.AREA.size.x, 330.0)
const TITLE_HEIGHT: float = 24.0
const CHANNEL_TITLE: String = "IRCabeza - [#cuerpo]"
const INFO_X: float = 276.0
const INFO_TOP: float = 306.0
const ROW_HEIGHT: float = 28.0
const INFO_FONT: int = 14
const BAR_X: float = 74.0
const BAR_SIZE: Vector2 = Vector2(58.0, 10.0)
const LEVEL_X: float = 138.0
const SPARE_X: float = 186.0
const COLOR_TEXT: Color = Color("#d8d8d8")
const COLOR_EMPTY: Color = Color("#404040")
const ROWS: Array = [
	[ModularBody.Slot.HEAD, "Cabeza"],
	[ModularBody.Slot.ARM_MAIN_LEFT, "Brazo I"],
	[ModularBody.Slot.ARM_MAIN_RIGHT, "Brazo D"],
	[ModularBody.Slot.ARM_EXTRA_LEFT, "Extra I"],
	[ModularBody.Slot.ARM_EXTRA_RIGHT, "Extra D"],
	[ModularBody.Slot.LEG_LEFT, "Pierna I"],
	[ModularBody.Slot.LEG_RIGHT, "Pierna D"],
]
const HIT_DROP: float = 0.02
const HIT_TIME: float = 0.3
const LOW_RATIO: float = 0.25
const LOW_PULSE_SPEED: float = 8.0

var body: ModularBody
var feet: Vector2 = FEET
var art_size: float = ART_SIZE
var plate: Rect2 = PLATE
## En la vista de piezas solo se usa la silueta.
var show_info: bool = true

var _ratios: Dictionary = {}
var _hits: Dictionary = {}
var _mono: SystemFont


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mono = SystemFont.new()
	_mono.font_names = PackedStringArray([
		"Courier New", "Consolas", "DejaVu Sans Mono", "Liberation Mono", "monospace"
	])
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
	if show_info:
		_draw_frame()
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * LOW_PULSE_SPEED)
	ProtagonistArt.draw_silhouette(self, feet, art_size, body, _hits, pulse)
	if show_info:
		_draw_info()


func _draw_frame() -> void:
	draw_rect(plate, IrcChat.COLOR_FRAME)
	draw_rect(plate, IrcChat.COLOR_DARK, false, 2.0)
	var title: Rect2 = Rect2(plate.position + Vector2(3.0, 3.0), Vector2(plate.size.x - 6.0, TITLE_HEIGHT - 4.0))
	draw_rect(title, IrcChat.COLOR_TITLE)
	draw_string(_mono, title.position + Vector2(6.0, 15.0), CHANNEL_TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)
	draw_rect(Rect2(plate.position + Vector2(3.0, TITLE_HEIGHT), plate.size - Vector2(6.0, TITLE_HEIGHT + 3.0)), IrcChat.COLOR_BACK)


## Lo mismo que enseñan las tarjetas: estado, nivel y repuestos, sin estadísticas ocultas.
func _draw_info() -> void:
	var y: float = INFO_TOP
	for row: Array in ROWS:
		_draw_row(row[0] as ModularBody.Slot, str(row[1]), y)
		y += ROW_HEIGHT
	var text: String = "Repuestos: %d de %d" % [body.spare_count(), ModularBody.Slot.size() * 4]
	_text(Vector2(INFO_X, y + 8.0), text, COLOR_TEXT)


func _draw_row(slot: ModularBody.Slot, label: String, y: float) -> void:
	var piece: BodyPiece = body.equipped(slot)
	_text(Vector2(INFO_X, y), label, COLOR_TEXT)
	var bar: Rect2 = Rect2(Vector2(INFO_X + BAR_X, y - BAR_SIZE.y), BAR_SIZE)
	draw_rect(bar, COLOR_EMPTY)
	if piece != null:
		var ratio: float = clampf(piece.durability / BodyPiece.MAX_DURABILITY, 0.0, 1.0)
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), ProtagonistArt.wear_color(ratio))
		_text(Vector2(INFO_X + LEVEL_X, y), "Nv%d%s" % [piece.level, "*" if piece.is_special() else ""], COLOR_TEXT)
	var spares: int = body.spares(slot).size()
	if spares > 0:
		_text(Vector2(INFO_X + SPARE_X, y), "+%d" % spares, IrcChat.COLOR_TOOLBAR_SPARE)


func _text(at: Vector2, text: String, color: Color) -> void:
	draw_string(_mono, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, INFO_FONT, color)


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
