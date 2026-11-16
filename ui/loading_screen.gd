class_name LoadingScreen
extends CanvasLayer
## Pantalla de carga inicial: el protagonista en pose gamberra rodeado de NPCs de cada especie.
## Al terminar la carga, sin cambiar el fondo, aparecen las opciones del menú.

const NPC_IMAGES: Array = [
	"res://art/shared/jubilado_hierro.svg",
	"res://art/shared/mohocrata.svg",
	"res://art/shared/plegado.svg",
	"res://art/shared/eco.svg",
	"res://art/shared/grux.svg",
	"res://art/shared/manada.svg",
]

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
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = Color(0.1, 0.1, 0.15, 1.0)
	backdrop.size = Vector2(1920.0, 1080.0)
	add_child(backdrop)

	# Título
	var title: Label = Label.new()
	title.text = "Bug de Familia"
	title.add_theme_font_size_override(&"font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0.0, 60.0)
	title.size = Vector2(1920.0, 60.0)
	add_child(title)

	# Protagonista en pose gamberra (centro)
	var protagonist: TextureRect = TextureRect.new()
	protagonist.custom_minimum_size = Vector2(400.0, 400.0)
	protagonist.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	protagonist.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	protagonist.position = Vector2(760.0, 340.0)
	var prot_tex: Texture2D = load("res://art/loading/protagonist_gamberra.png") as Texture2D
	if prot_tex != null:
		protagonist.texture = prot_tex
	add_child(protagonist)

	# NPCs alrededor, decenas de distintos tamaños
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1234
	var center: Vector2 = Vector2(960.0, 540.0)
	for i: int in range(24):
		var img_path: String = NPC_IMAGES[rng.randi() % NPC_IMAGES.size()]
		var tex_rect: TextureRect = TextureRect.new()
		var size: float = rng.randf_range(48.0, 160.0)
		tex_rect.custom_minimum_size = Vector2(size, size)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var angle: float = rng.randf() * TAU
		var radius: float = rng.randf_range(220.0, 460.0)
		var pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
		tex_rect.position = pos - Vector2(size * 0.5, size * 0.5)
		var texture: Texture2D = load(img_path) as Texture2D
		if texture != null:
			tex_rect.texture = texture
		tex_rect.modulate.a = rng.randf_range(0.6, 1.0)
		add_child(tex_rect)

	# Subtítulo
	var subtitle: Label = Label.new()
	subtitle.text = "Cargando..."
	subtitle.add_theme_font_size_override(&"font_size", 24)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(0.0, 900.0)
	subtitle.size = Vector2(1920.0, 40.0)
	subtitle.name = "Subtitle"
	add_child(subtitle)

	# Barra de progreso
	var progress_bg: ColorRect = ColorRect.new()
	progress_bg.color = Color(0.2, 0.2, 0.2, 1.0)
	progress_bg.position = Vector2(660.0, 960.0)
	progress_bg.size = Vector2(600.0, 20.0)
	add_child(progress_bg)

	var progress_fg: ColorRect = ColorRect.new()
	progress_fg.color = Color(0.3, 0.8, 0.4, 1.0)
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

	var btn_container: VBoxContainer = VBoxContainer.new()
	btn_container.position = Vector2(760.0, 820.0)
	btn_container.size = Vector2(400.0, 200.0)
	btn_container.add_theme_constant_override(&"separation", 16)
	add_child(btn_container)

	var labels: Array[String] = ["UI_MENU_CONTINUE", "UI_MENU_NEW", "UI_MENU_HISTORY"]
	var callbacks: Array[Callable] = [on_continue, on_new, on_history]
	for i: int in range(labels.size()):
		var btn: Button = Button.new()
		btn.text = tr(labels[i])
		btn.custom_minimum_size = Vector2(400.0, 48.0)
		var cb: Callable = callbacks[i]
		if cb.is_valid():
			btn.pressed.connect(cb)
		btn_container.add_child(btn)
		_menu_buttons.append(btn)


func menu_button_count() -> int:
	return _menu_buttons.size()
