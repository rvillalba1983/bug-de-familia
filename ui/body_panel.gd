class_name BodyPanel
extends CanvasLayer
## Ventana para cambiar piezas. Pausa el juego mientras está abierta.

signal closed(mode: Mode)
signal discarded

enum Mode { NORMAL, PRE_FIGHT, REPLACE }

const TITLES: Dictionary = {
	Mode.NORMAL: "UI_BODY_TITLE",
	Mode.PRE_FIGHT: "UI_BODY_PRE_FIGHT",
	Mode.REPLACE: "UI_BODY_REPLACE",
}

## Provisional: la silueta ocupa casi toda la pantalla, con las piezas a los lados.
const SILHOUETTE_FEET: Vector2 = Vector2(960.0, 1060.0)
const SILHOUETTE_SIZE: float = 0.88
const COLUMN_X: Array[float] = [20.0, 1410.0]
const ROW_Y: Array[float] = [70.0, 300.0, 530.0, 760.0]
const COLUMNS: Array = [
	[ModularBody.Slot.HEAD, ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_EXTRA_LEFT, ModularBody.Slot.LEG_LEFT],
	[null, ModularBody.Slot.ARM_MAIN_RIGHT, ModularBody.Slot.ARM_EXTRA_RIGHT, ModularBody.Slot.LEG_RIGHT],
]

var body: ModularBody
var pause: TacticalPause
var is_open: bool = false
var mode: Mode = Mode.NORMAL

var _root: Control
var _backdrop: ColorRect
var _silhouette: BodyHud


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"character") or event.is_echo():
		return
	if is_open:
		close()
	elif not get_tree().paused:
		open(Mode.NORMAL)


func open(new_mode: Mode) -> void:
	if body.is_dead:
		return
	mode = new_mode
	if not is_open:
		is_open = true
		pause.begin_modal()
	_rebuild()


func close() -> void:
	if not is_open:
		return
	is_open = false
	body.ensure_head()
	_clear()
	pause.end_modal()
	closed.emit(mode)


func swap_spare(slot: ModularBody.Slot, index: int) -> void:
	if body.swap(slot, index):
		_rebuild()


func discard_spare(slot: ModularBody.Slot, index: int) -> void:
	body.discard_spare(slot, index)
	discarded.emit()
	_rebuild()


func _clear() -> void:
	if _root != null:
		_root.queue_free()
		_root = null
		_backdrop.queue_free()
		_backdrop = null
		_silhouette.queue_free()
		_silhouette = null


func _rebuild() -> void:
	_clear()
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0.05, 0.04, 0.08, 0.95)
	_backdrop.size = Vector2(1920.0, 1080.0)
	add_child(_backdrop)
	_silhouette = BodyHud.new()
	_silhouette.body = body
	_silhouette.feet = SILHOUETTE_FEET
	_silhouette.art_size = SILHOUETTE_SIZE
	_silhouette.plate = Rect2()
	add_child(_silhouette)
	_root = Control.new()
	_root.theme = UiStyle.make_theme()
	add_child(_root)
	_build_header()
	for index: int in range(COLUMNS.size()):
		_build_column(COLUMNS[index], COLUMN_X[index])


func _build_header() -> void:
	var title: Label = Label.new()
	title.text = tr(TITLES[mode] as String)
	title.position = Vector2(COLUMN_X[1], ROW_Y[0] - 40.0)
	title.add_theme_font_size_override(&"font_size", 26)
	_root.add_child(title)
	var legend: Label = Label.new()
	legend.text = "Marco = nivel  ·  Estrella = especial\nClic: poner  ·  Clic derecho: descartar"
	legend.position = Vector2(COLUMN_X[1], ROW_Y[0] + 28.0)
	legend.add_theme_font_size_override(&"font_size", 18)
	_root.add_child(legend)
	for level: int in range(1, PieceCard.LEVEL_COLORS.size() + 1):
		var swatch: ColorRect = ColorRect.new()
		swatch.color = PieceCard.level_color(level)
		swatch.position = Vector2(COLUMN_X[1] + float(level - 1) * 84.0, ROW_Y[0] + 88.0)
		swatch.size = Vector2(76.0, 26.0)
		_root.add_child(swatch)
		var number: Label = Label.new()
		number.text = "Nv %d" % level
		number.position = Vector2(14.0, 0.0)
		number.add_theme_color_override(&"font_color", Color.BLACK)
		swatch.add_child(number)
	var close_button: Button = Button.new()
	close_button.text = tr("UI_BODY_START_FIGHT" if mode == Mode.PRE_FIGHT else "UI_BODY_CLOSE")
	close_button.position = Vector2(COLUMN_X[1], ROW_Y[0] + 126.0)
	close_button.pressed.connect(close)
	_root.add_child(close_button)


func _build_column(slots: Array, x: float) -> void:
	for slot: Variant in slots:
		if slot != null:
			_build_slot(slot as ModularBody.Slot, Vector2(x, ROW_Y[slots.find(slot)]))


func _build_slot(slot: ModularBody.Slot, at: Vector2) -> void:
	var heading: Label = Label.new()
	heading.text = tr("SLOT_%d" % slot)
	heading.position = at
	heading.add_theme_font_size_override(&"font_size", 22)
	_root.add_child(heading)
	var row: HBoxContainer = HBoxContainer.new()
	row.position = at + Vector2(0.0, 36.0)
	row.add_theme_constant_override(&"separation", 6)
	_root.add_child(row)
	var worn: BodyPiece = body.equipped(slot)
	if worn != null:
		row.add_child(_card(worn, slot, true, -1))
	var spares: Array[BodyPiece] = body.spares(slot)
	for index: int in range(spares.size()):
		row.add_child(_card(spares[index], slot, false, index))


func _card(piece: BodyPiece, slot: ModularBody.Slot, worn: bool, index: int) -> PieceCard:
	var card: PieceCard = PieceCard.new()
	card.piece = piece
	card.slot = slot
	card.is_worn = worn
	card.can_equip = body.can_swap(slot)
	if not worn:
		card.equip_requested.connect(swap_spare.bind(slot, index))
		card.discard_requested.connect(discard_spare.bind(slot, index))
	return card
