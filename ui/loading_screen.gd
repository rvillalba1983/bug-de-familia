class_name LoadingScreen
extends CanvasLayer
## Pantalla de carga inicial: el protagonista en pose gamberra rodeado de NPCs de cada especie.

const NPC_IMAGES: Array = [
	"res://art/shared/jubilado.svg",
	"res://art/shared/mohocrata.svg",
	"res://art/shared/plegado.svg",
	"res://art/shared/eco.svg",
	"res://art/shared/grux.svg",
	"res://art/shared/manada.svg",
]

var _progress: float = 0.0
var _timer: float = 0.0


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
	title.position = Vector2(0.0, 100.0)
	title.size = Vector2(1920.0, 60.0)
	add_child(title)

	# Subtítulo
	var subtitle: Label = Label.new()
	subtitle.text = "Cargando..."
	subtitle.add_theme_font_size_override(&"font_size", 24)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.position = Vector2(0.0, 900.0)
	subtitle.size = Vector2(1920.0, 40.0)
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

	# NPCs alrededor (placeholders)
	var npc_container: HBoxContainer = HBoxContainer.new()
	npc_container.position = Vector2(360.0, 400.0)
	npc_container.custom_minimum_size = Vector2(1200.0, 0.0)
	npc_container.add_theme_constant_override(&"separation", 40)
	add_child(npc_container)

	for img_path: String in NPC_IMAGES:
		var tex_rect: TextureRect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(120.0, 120.0)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var texture: Texture2D = load(img_path) as Texture2D
		if texture != null:
			tex_rect.texture = texture
		npc_container.add_child(tex_rect)


func _process(delta: float) -> void:
	_timer += delta
	_progress = clampf(_timer / 3.0, 0.0, 1.0)
	var fg: ColorRect = get_node_or_null("ProgressFg") as ColorRect
	if fg != null:
		fg.size = Vector2(600.0 * _progress, 20.0)
	if _progress >= 1.0:
		queue_free()
