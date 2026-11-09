class_name ControlsWindow
extends Control
## Ventana de controles, con el mismo aspecto que el chat, arriba a la izquierda.

const AREA: Rect2 = Rect2(14.0, 14.0, IrcChat.AREA.size.x, 232.0)
const TITLE_HEIGHT: float = 24.0
const FONT_SIZE: int = 15
const CHANNEL_TITLE: String = "IRCabeza - [#controles] F1: todos"
const COLOR_KEY: String = "#ffcf40"

var view: RichTextLabel

var _mono: SystemFont


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mono = SystemFont.new()
	_mono.font_names = PackedStringArray([
		"Courier New", "Consolas", "DejaVu Sans Mono", "Liberation Mono", "monospace"
	])
	view = RichTextLabel.new()
	view.position = AREA.position + Vector2(8.0, TITLE_HEIGHT + 6.0)
	view.size = AREA.size - Vector2(16.0, TITLE_HEIGHT + 12.0)
	view.bbcode_enabled = true
	view.scroll_active = false
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.add_theme_font_override(&"normal_font", _mono)
	view.add_theme_font_size_override(&"normal_font_size", FONT_SIZE)
	add_child(view)
	var rows: PackedStringArray = PackedStringArray()
	for row: Variant in ControlsPanel.load_rows("compact"):
		rows.append("[color=%s]%s[/color] %s" % [COLOR_KEY, str(row[0]).rpad(10), row[1]])
	view.text = "\n".join(rows)


func _draw() -> void:
	draw_rect(AREA, IrcChat.COLOR_FRAME)
	draw_rect(AREA, IrcChat.COLOR_DARK, false, 2.0)
	var title: Rect2 = Rect2(AREA.position + Vector2(3.0, 3.0), Vector2(AREA.size.x - 6.0, TITLE_HEIGHT - 4.0))
	draw_rect(title, IrcChat.COLOR_TITLE)
	draw_string(
		_mono, title.position + Vector2(6.0, 15.0), CHANNEL_TITLE,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE
	)
	draw_rect(
		Rect2(AREA.position + Vector2(3.0, TITLE_HEIGHT), AREA.size - Vector2(6.0, TITLE_HEIGHT + 3.0)),
		IrcChat.COLOR_BACK
	)
