class_name BodyPanel
extends CanvasLayer
## Ventana para cambiar piezas. Pausa el juego mientras está abierta.

signal closed(mode: Mode)

enum Mode { NORMAL, PRE_FIGHT, REPLACE }

const TITLES: Dictionary = {
	Mode.NORMAL: "UI_BODY_TITLE",
	Mode.PRE_FIGHT: "UI_BODY_PRE_FIGHT",
	Mode.REPLACE: "UI_BODY_REPLACE",
}

var body: ModularBody
var pause: TacticalPause
var is_open: bool = false
var mode: Mode = Mode.NORMAL

var _root: VBoxContainer
var _backdrop: ColorRect


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


func _clear() -> void:
	if _root != null:
		_root.queue_free()
		_root = null
		_backdrop.queue_free()
		_backdrop = null


func _rebuild() -> void:
	_clear()
	_backdrop = ColorRect.new()
	_backdrop.color = Color(0.05, 0.05, 0.08, 0.88)
	_backdrop.size = Vector2(1920.0, 1080.0)
	add_child(_backdrop)
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
	label.text = "%s: %s" % [tr("SLOT_%d" % slot), state]
	label.custom_minimum_size = Vector2(380.0, 0.0)
	row.add_child(label)
	var spares: Array[BodyPiece] = body.spares(slot)
	for index: int in range(spares.size()):
		var button: Button = Button.new()
		button.text = "%s %d%%" % [tr("UI_BODY_EQUIP"), roundi(spares[index].durability)]
		button.disabled = not body.can_swap(slot)
		button.pressed.connect(swap_spare.bind(slot, index))
		row.add_child(button)
	return row
