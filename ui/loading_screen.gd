class_name LoadingScreen
extends CanvasLayer
## Pantalla de carga inicial: arte a pantalla completa con el protagonista y todos los NPCs.
## Al terminar la carga, sin cambiar el fondo, aparecen las opciones del menú.
## Origen del arte: imagen facilitada por el director en el chat, 16-nov-2026.
## Herramienta: copia local desde ~/Downloads (no generada por IA en este repo).
## El menú usa la paleta «Cuñado Radiactivo» (Palette) y señales de art/shared/fuentes.

## Señales existentes usadas como iconos: REFUGIO, SALIDA, SALIDA.
const SIGN_ICONS: Array[String] = [
	"res://art/shared/fuentes/señal_03.svg",
	"res://art/shared/fuentes/señal_04.svg",
	"res://art/shared/fuentes/señal_09.svg",
]
const MENU_WIDTH: float = 500.0
const ROW_HEIGHT: float = 84.0

var _progress: float = 0.0
var _timer: float = 0.0
var _menu_shown: bool = false
var _menu_buttons: Array[Button] = []

var on_continue: Callable = Callable()
var on_new: Callable = Callable()
var on_history: Callable = Callable()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Fondo a pantalla completa: recorta un poco sin distorsionar (proporción 16:9).
	var carga_tex: Texture2D = load("res://art/loading/carga_con_npcs.png") as Texture2D
	if carga_tex != null:
		var background: TextureRect = TextureRect.new()
		background.texture = carga_tex
		background.position = Vector2.ZERO
		background.size = Vector2(1920.0, 1080.0)
		background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(background)
	else:
		# Respaldo oscuro si falta el archivo de imagen.
		var backdrop: ColorRect = ColorRect.new()
		backdrop.color = Palette.INK
		backdrop.size = Vector2(1920.0, 1080.0)
		add_child(backdrop)

	# Título
	var title: Label = Label.new()
	title.text = "Bug de Familia"
	title.add_theme_font_size_override(&"font_size", 48)
	title.add_theme_color_override(&"font_outline_color", Palette.INK)
	title.add_theme_constant_override(&"outline_size", 6)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0.0, 60.0)
	title.size = Vector2(1920.0, 60.0)
	add_child(title)

	# Subtítulo
	var subtitle: Label = Label.new()
	subtitle.text = "Cargando..."
	subtitle.add_theme_font_size_override(&"font_size", 24)
	subtitle.add_theme_color_override(&"font_outline_color", Palette.INK)
	subtitle.add_theme_constant_override(&"outline_size", 5)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(0.0, 900.0)
	subtitle.size = Vector2(1920.0, 40.0)
	subtitle.name = "Subtitle"
	add_child(subtitle)

	# Barra de progreso
	var progress_bg: ColorRect = ColorRect.new()
	progress_bg.color = Color(Palette.INK.r, Palette.INK.g, Palette.INK.b, 0.8)
	progress_bg.position = Vector2(660.0, 960.0)
	progress_bg.size = Vector2(600.0, 20.0)
	add_child(progress_bg)

	var progress_fg: ColorRect = ColorRect.new()
	progress_fg.color = Palette.ACIDO
	progress_fg.position = Vector2(660.0, 960.0)
	progress_fg.size = Vector2(0.0, 20.0)
	progress_fg.name = "ProgressFg"
	add_child(progress_fg)


func _process(delta: float) -> void:
	_timer += delta
	_progress = clampf(_timer / 3.0, 0.0, 1.0)
	var fg: ColorRect = get_node_or_null("ProgressFg") as ColorRect
	if fg != null:
		fg.size = Vector2(600.0 * _progress, 20.0)
	if _progress >= 1.0 and not _menu_shown:
		_menu_shown = true
		_show_menu_buttons()


func _show_menu_buttons() -> void:
	var subtitle: Label = get_node_or_null("Subtitle") as Label
	if subtitle != null:
		subtitle.visible = false
	var fg: ColorRect = get_node_or_null("ProgressFg") as ColorRect
	if fg != null:
		fg.visible = false

	# Panel semitransparente para que las señales se lean sobre la imagen.
	var backing: Panel = Panel.new()
	backing.position = Vector2(690.0, 764.0)
	backing.size = Vector2(540.0, 304.0)
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backing.add_theme_stylebox_override(&"panel", MenuButtonStyle.backing_box())
	add_child(backing)

	var btn_container: VBoxContainer = VBoxContainer.new()
	btn_container.position = Vector2(710.0, 778.0)
	btn_container.size = Vector2(MENU_WIDTH, ROW_HEIGHT * 3.0 + 28.0)
	btn_container.add_theme_constant_override(&"separation", 14)
	add_child(btn_container)

	var labels: Array[String] = ["UI_MENU_CONTINUE", "UI_MENU_NEW", "UI_MENU_HISTORY"]
	var callbacks: Array[Callable] = [on_continue, on_new, on_history]
	for i: int in range(labels.size()):
		var btn: Button = MenuButtonStyle.make_button(
			btn_container, i, tr(labels[i]), callbacks[i],
			Vector2(MENU_WIDTH, ROW_HEIGHT), SIGN_ICONS[i]
		)
		_menu_buttons.append(btn)


func menu_button_count() -> int:
	return _menu_buttons.size()
