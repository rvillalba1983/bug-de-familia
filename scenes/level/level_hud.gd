class_name LevelHud
extends CanvasLayer
## Textos fijos de la partida, avisos temporales, estado del cuerpo y barra de acciones.

const SAVED_NOTICE_TIME: float = 2.5
const NOTICE_TIME: float = 7.0

var pause_label: Label
var done_label: Label
var saved_label: Label
var notice_label: Label
var conversion_hint: Label
var action_bar: ActionBar

var _body_hud: BodyHud
var _saved_time: float = 0.0
var _notice_time: float = 0.0


## Crea etiquetas de pantalla con el estilo común. Sirve también a cada zona.
static func make_label(parent: CanvasLayer, key: String, at: Vector2, font_size: int) -> Label:
	var label: Label = Label.new()
	label.text = TranslationServer.translate(key)
	label.position = at
	label.add_theme_font_override(&"font", UiStyle.FONT_LOUD)
	label.add_theme_font_size_override(&"font_size", font_size)
	parent.add_child(label)
	return label


func _process(delta: float) -> void:
	if _saved_time > 0.0:
		_saved_time -= delta
		saved_label.visible = _saved_time > 0.0
	if _notice_time > 0.0:
		_notice_time -= delta
		notice_label.visible = _notice_time > 0.0


## Llamar ya dentro del árbol, con el cuerpo inicial.
func build(body: ModularBody, shows_help: bool, objective_key: String) -> void:
	pause_label = _hidden_label("UI_PAUSE", Vector2(860.0, 24.0), 32)
	done_label = _hidden_label("UI_CHALLENGE_DONE", Vector2(820.0, 70.0), 32)
	saved_label = _hidden_label("UI_SAVED", Vector2(860.0, 980.0), 26)
	notice_label = _hidden_label("UI_SAVED", Vector2(420.0, 110.0), 26)
	notice_label.process_mode = Node.PROCESS_MODE_ALWAYS
	if shows_help:
		make_label(self, "UI_SANDBOX_HELP", Vector2(24.0, 1040.0), 20)
		make_label(self, objective_key, Vector2(24.0, 16.0), 22)
	_body_hud = BodyHud.new()
	_body_hud.body = body
	add_child(_body_hud)
	action_bar = ActionBar.new()
	add_child(action_bar)
	action_bar.body = body
	if shows_help:
		make_label(self, "UI_SANDBOX_HELP2", Vector2(1560.0, 1040.0), 20)
	conversion_hint = _hidden_label("UI_CONVERT_NONE", Vector2(620.0, 70.0), 24)


func set_body(body: ModularBody) -> void:
	action_bar.body = body
	_body_hud.body = body
	body.changed.connect(_body_hud.queue_redraw)
	_body_hud.queue_redraw()


func show_saved() -> void:
	_saved_time = SAVED_NOTICE_TIME
	saved_label.visible = true


func show_notice(text: String) -> void:
	notice_label.text = text
	notice_label.visible = true
	_notice_time = NOTICE_TIME


func _hidden_label(key: String, at: Vector2, font_size: int) -> Label:
	var label: Label = make_label(self, key, at, font_size)
	label.visible = false
	return label
