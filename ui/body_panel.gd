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

## Provisional: la misma silueta del juego, en grande junto a la lista.
const SILHOUETTE_FEET: Vector2 = Vector2(265.0, 800.0)
const SILHOUETTE_SIZE: float = 0.44
const SILHOUETTE_PLATE: Rect2 = Rect2(30.0, 270.0, 470.0, 560.0)

var body: ModularBody
var pause: TacticalPause
var is_open: bool = false
var mode: Mode = Mode.NORMAL

var _root: VBoxContainer
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
	_backdrop.color = Color(0.05, 0.05, 0.08, 0.88)
	_backdrop.size = Vector2(1920.0, 1080.0)
	add_child(_backdrop)
	_silhouette = BodyHud.new()
	_silhouette.body = body
	_silhouette.feet = SILHOUETTE_FEET
	_silhouette.art_size = SILHOUETTE_SIZE
	_silhouette.plate = SILHOUETTE_PLATE
	add_child(_silhouette)
	_root = VBoxContainer.new()
	_root.position = Vector2(520.0, 150.0)
	_root.custom_minimum_size = Vector2(880.0, 0.0)
	_root.add_theme_constant_override(&"separation", 8)
	add_child(_root)
	var title: Label = Label.new()
	title.text = tr(TITLES[mode] as String)
	title.add_theme_font_size_override(&"font_size", 28)
	_root.add_child(title)
	for slot: int in ModularBody.Slot.values():
		_root.add_child(_build_row(slot as ModularBody.Slot))
	var close_button: Button = Button.new()
	close_button.text = tr("UI_BODY_START_FIGHT" if mode == Mode.PRE_FIGHT else "UI_BODY_CLOSE")
	close_button.pressed.connect(close)
	_root.add_child(close_button)


func _build_row(slot: ModularBody.Slot) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	var label: Label = Label.new()
	var piece: BodyPiece = body.equipped(slot)
	var state: String = tr("UI_BODY_EMPTY") if piece == null else "%d%%" % roundi(piece.durability)
	var worn: String = "" if piece == null else piece.label
	label.text = "%s: %s %s" % [tr("SLOT_%d" % slot), state, worn]
	label.custom_minimum_size = Vector2(380.0, 0.0)
	row.add_child(label)
	label.tooltip_text = "" if piece == null else piece.description
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	var spares: Array[BodyPiece] = body.spares(slot)
	for index: int in range(spares.size()):
		var button: Button = Button.new()
		button.text = "%s %d%% %s" % [
			tr("UI_BODY_EQUIP"), roundi(spares[index].durability), spares[index].label
		]
		button.disabled = not body.can_swap(slot)
		button.tooltip_text = spares[index].description
		button.pressed.connect(swap_spare.bind(slot, index))
		row.add_child(button)
		var drop: Button = Button.new()
		drop.text = tr("UI_BODY_DISCARD")
		drop.pressed.connect(discard_spare.bind(slot, index))
		row.add_child(drop)
	return row
