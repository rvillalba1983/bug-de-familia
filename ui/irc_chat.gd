class_name IrcChat
extends Control
## El canal de las IAs, al estilo de los scripts de IRC de los 90: colores, adornos y barra de estado.
## Solo se ven los últimos mensajes: no hay scroll ni historial al que volver.

## El lateral izquierdo es un panel uniforme: controles, cuerpo y chat tienen este ancho.
const AREA: Rect2 = Rect2(14.0, 592.0, 480.0, 474.0)
const NICKS_WIDTH: float = 160.0
const TITLE_HEIGHT: float = 24.0
const TOPIC_HEIGHT: float = 22.0
const VISIBLE_MESSAGES: int = 4
const TOOLBAR_HEIGHT: float = 22.0
const STATUS_HEIGHT: float = 22.0
const TOOLBAR_COLORS: Array[Color] = [
	Color("#ff4040"), Color("#ffd400"), Color("#40d040"), Color("#40d0ff"), Color("#c060ff"), Color("#ff60b0"),
]
const DECOR: String = "[color=#ff60b0]·[/color][color=#ffd400]¸[/color][color=#40d0ff]¸[/color][color=#40d040].[/color][color=#c060ff]·[/color]"
const FONT_SIZE: int = 15
const REFRESH: float = 1.0
const COLOR_FRAME: Color = Color("#c0c0c0")
const COLOR_TITLE: Color = Color("#000080")
const COLOR_BACK: Color = Color("#000000")
const COLOR_TOPIC: Color = Color("#1a1a40")
const COLOR_DARK: Color = Color("#808080")
const COLOR_TOOLBAR_SPARE: Color = Color("#ffd400")
const COLOR_SYSTEM: String = "#00c000"
const COLOR_TIME: String = "#808080"
const TEXT_EFFECTS: Dictionary = {
	"panico": "[shake rate=24 level=7]%s[/shake]",
	"sargento_bit": "[shake rate=12 level=4]%s[/shake]",
	"cupido": "[wave amp=18 freq=3]%s[/wave]",
	"lumi": "[rainbow freq=0.3 sat=0.7]%s[/rainbow]",
	"siestaware": "[fade start=0 length=60]%s[/fade]",
}
const CHANNEL_TITLE: String = "IRCabeza 3.1 - [#familia] [+nt]"

var team: AiTeam
var log_view: RichTextLabel
var nick_view: RichTextLabel
var topic_view: Label
var status_view: Label

var _mono: SystemFont
var _last_active: Array = []
var _refresh: float = 0.0
var _lines: Array[String] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mono = SystemFont.new()
	_mono.font_names = PackedStringArray(["Courier New", "Consolas", "DejaVu Sans Mono", "Liberation Mono", "monospace"])
	var top: float = TITLE_HEIGHT + TOOLBAR_HEIGHT + TOPIC_HEIGHT
	var body: Rect2 = Rect2(
		AREA.position + Vector2(4.0, top + 4.0),
		AREA.size - Vector2(8.0, top + STATUS_HEIGHT + 8.0)
	)
	log_view = _rich(Rect2(body.position, body.size - Vector2(NICKS_WIDTH + 4.0, 0.0)))
	nick_view = _rich(Rect2(
		Vector2(body.end.x - NICKS_WIDTH, body.position.y), Vector2(NICKS_WIDTH, body.size.y)
	))
	topic_view = Label.new()
	topic_view.position = AREA.position + Vector2(8.0, TITLE_HEIGHT + TOOLBAR_HEIGHT + 2.0)
	topic_view.size = Vector2(AREA.size.x - 16.0, TOPIC_HEIGHT)
	topic_view.clip_text = true
	topic_view.add_theme_font_override(&"font", _mono)
	topic_view.add_theme_font_size_override(&"font_size", 13)
	add_child(topic_view)
	status_view = Label.new()
	status_view.position = AREA.position + Vector2(8.0, AREA.size.y - STATUS_HEIGHT - 2.0)
	status_view.size = Vector2(AREA.size.x - 16.0, STATUS_HEIGHT)
	status_view.clip_text = true
	status_view.add_theme_font_override(&"font", _mono)
	status_view.add_theme_font_size_override(&"font_size", 13)
	status_view.add_theme_color_override(&"font_color", Color.BLACK)
	add_child(status_view)


func _process(delta: float) -> void:
	_refresh -= delta
	if _refresh <= 0.0 and team != null:
		_refresh = REFRESH
		_update_users()


func _draw() -> void:
	draw_rect(AREA, COLOR_FRAME)
	draw_rect(AREA, COLOR_DARK, false, 2.0)
	var title: Rect2 = Rect2(AREA.position + Vector2(3.0, 3.0), Vector2(AREA.size.x - 6.0, TITLE_HEIGHT - 4.0))
	draw_rect(title, COLOR_TITLE)
	draw_string(
		_mono, title.position + Vector2(6.0, 15.0), CHANNEL_TITLE,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE
	)
	for index: int in range(TOOLBAR_COLORS.size()):
		var button: Rect2 = Rect2(
			AREA.position + Vector2(6.0 + float(index) * 22.0, TITLE_HEIGHT + 2.0), Vector2(18.0, 17.0)
		)
		draw_rect(button, TOOLBAR_COLORS[index])
		draw_rect(button, COLOR_DARK, false, 1.0)
	var topic: Rect2 = Rect2(
		AREA.position + Vector2(3.0, TITLE_HEIGHT + TOOLBAR_HEIGHT), Vector2(AREA.size.x - 6.0, TOPIC_HEIGHT)
	)
	draw_rect(topic, COLOR_TOPIC)
	draw_rect(_body_rect(), COLOR_BACK)


func set_topic(text: String) -> void:
	topic_view.text = "Topic: " + text


## Entradas y salidas van a la barra de estado: el canal es solo para lo que escriben las IAs.
func add_system(text: String) -> void:
	status_view.text = "*** " + text


func add_message(id: String, text: String) -> void:
	var info: Dictionary = team.ais[id]
	var color: String = info["color"]
	_append("%s [color=%s]%s [lb]@%s][/color] %s" % [
		DECOR, color, _safe(str(info["face"])), _safe(str(info["name"])), _styled(id, _safe(text))
	])


## Cada IA escribe a su manera; sin movimiento si el jugador lo ha pedido.
func _styled(id: String, text: String) -> String:
	if GameSettings.reduce_motion or not TEXT_EFFECTS.has(id):
		return text
	return (TEXT_EFFECTS[id] as String) % text


func lines() -> Array[String]:
	return _lines


func _body_rect() -> Rect2:
	var top: float = TITLE_HEIGHT + TOOLBAR_HEIGHT + TOPIC_HEIGHT
	return Rect2(AREA.position + Vector2(3.0, top + 3.0), AREA.size - Vector2(6.0, top + STATUS_HEIGHT + 6.0))


func _rich(area: Rect2) -> RichTextLabel:
	var view: RichTextLabel = RichTextLabel.new()
	view.position = area.position
	view.size = area.size
	view.bbcode_enabled = true
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	view.scroll_active = false
	view.add_theme_font_override(&"normal_font", _mono)
	view.add_theme_font_size_override(&"normal_font_size", GameSettings.font_size(FONT_SIZE))
	add_child(view)
	return view


func _append(body: String) -> void:
	var clock: Dictionary = Time.get_datetime_dict_from_unix_time(WorldCalendar.now_local())
	var stamp: String = "«%02d:%02d»" % [int(clock["hour"]), int(clock["minute"])]
	var line: String = "[color=%s]%s[/color] %s" % [COLOR_TIME, stamp, body]
	_lines.append(line)
	if _lines.size() > VISIBLE_MESSAGES:
		_lines.pop_front()
	log_view.text = "\n".join(_lines)


func _safe(text: String) -> String:
	return text.replace("[", "[lb]")


func _update_users() -> void:
	if team.active != _last_active:
		_announce_changes()
		_last_active = team.active.duplicate()
	var rows: PackedStringArray = PackedStringArray()
	for id: String in team.active:
		var info: Dictionary = team.ais[id]
		rows.append("[color=%s]@%s" % [info["color"], _safe(str(info["name"]))])
		for row: Variant in info["avatar"]:
			rows.append(_safe(str(row)))
		rows.append("[/color]")
	nick_view.text = "\n".join(rows)
	queue_redraw()


func _announce_changes() -> void:
	for id: String in team.active:
		if not _last_active.has(id):
			add_system("%s ha entrado en #familia" % team.ais[id]["name"])
	for id: String in _last_active:
		if not team.active.has(id):
			add_system("%s ha salido (sin tokens o con rencor)" % team.ais[id]["name"])
