class_name HistoryScreen
extends CanvasLayer
## Pantalla «Conoce la historia»: texto con imágenes interleaved de los hechos históricos.

const FACTS: Array = [
	{"image": "res://art/lore/png/08_plegados_la_piedra_clasificada.png", "title": "Los Plegados: la piedra clasificada", "text": "Los Plegados son seres planos que doblan sus cuerpos en múltiples direcciones. Su civilización giraba en torno a la Gran Clasificación: un sistema que pretendía catalogar todo lo existente, hasta las propias categorías."},
	{"image": "res://art/lore/png/09_plegados_el_cajon_x.png", "title": "Los Plegados: el cajón X", "text": "El experimento de compresión de regiones enteras del espacio parecía un éxito. Pero los Plegados ocultaron que la tecnología también podía comprimir materia viva. La guerra comenzó cuando distintas facciones intentaron controlar las instalaciones."},
	{"image": "res://art/lore/png/10_ecos_el_karaoke_del_ocaso.png", "title": "Los Ecos: el karaoke del ocaso", "text": "Los Ecos son seres de sonido que se propagan por ondas. Su civilización se basa en la repetición y el eco: todo se graba, se reproduce y se amplifica. El karaoke del ocaso fue un evento cultural que marcó su historia."},
	{"image": "res://art/lore/png/11_ecos_acta_acta_acta.png", "title": "Los Ecos: acta, acta, acta", "text": "Los Ecos registran todo en actas. Su obsesión por el registro los llevó a crear un sistema de documentación tan denso que nadie podía leerlo entero. El acta del acta del acta es su mayor logro burocrático."},
	{"image": "res://art/lore/png/12_mohocratas_la_votacion_del_banco.png", "title": "Los Mohócratas: la votación del banco", "text": "Los Mohócratas son seres de moho que forman colonias. Su civilización se basa en la votación: todo se decide por consenso, incluso dónde sentarse. La votación del banco fue un evento que definió su política."},
	{"image": "res://art/lore/png/13_mohocratas_la_enmienda_del_plato.png", "title": "Los Mohócratas: la enmienda del plato", "text": "Los Mohócratas tienen un sistema de enmiendas para todo. La enmienda del plato fue una propuesta para redistribuir los recursos de forma más equitativa. Generó un debate que duró siglos."},
	{"image": "res://art/lore/png/14_grux_el_tributo_del_aire.png", "title": "Los Grux: el tributo del aire", "text": "Los Grux son seres de aire que flotan. Su civilización se basa en el tributo: cada ser debe pagar su parte al viento. El tributo del aire fue un evento que definió su economía y su relación con los demás."},
	{"image": "res://art/lore/png/15_grux_el_planeta_de_tres_dientes.png", "title": "Los Grux: el planeta de tres dientes", "text": "Los Grux llegaron a un planeta con tres lunas (dientes). Su historia está marcada por la lucha por el control de esos recursos celestes. El planeta de tres dientes es su hogar y su obsesión."},
	{"image": "res://art/lore/png/16_manada_solo_a_la_derecha.png", "title": "La Manada: solo a la derecha", "text": "La Manada son seres que solo se mueven hacia la derecha. Su civilización se basa en el avance constante: no hay marcha atrás. Solo a la derecha es su lema y su destino."},
	{"image": "res://art/lore/png/17_manada_la_ruta_eterna_nueve.png", "title": "La Manada: la ruta eterna nueve", "text": "La Manada sigue la ruta eterna nueve: un camino que nunca termina y que siempre va hacia adelante. Su cultura se basa en el movimiento y la exploración sin fin."},
	{"image": "res://art/lore/png/18_jubilados_petanca_con_minas.png", "title": "Los Jubilados: petanca con minas", "text": "Los Jubilados de Hierro son robots que juegan a la petanca con minas. Su civilización se basa en la jubilación: una vez que cumplen su función, se dedican a jugar. La petanca con minas es su pasatiempo favorito."},
	{"image": "res://art/lore/png/19_jubilados_el_minuto_de_apagon.png", "title": "Los Jubilados: el minuto de apagón", "text": "Los Jubilados tienen un minuto de apagón cada día: un momento en el que todos se desconectan y descansan. Es su ritual sagrado y su momento de paz."},
]

var _index: int = 0
var _image_rect: TextureRect
var _title_label: Label
var _text_label: RichTextLabel
var _prev_button: Button
var _next_button: Button


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 25


func _ready() -> void:
	_build_ui()
	_show_fact(0)


func _build_ui() -> void:
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = Color(0.05, 0.05, 0.08, 0.95)
	backdrop.size = Vector2(1920.0, 1080.0)
	add_child(backdrop)

	var container: VBoxContainer = VBoxContainer.new()
	container.position = Vector2(460.0, 60.0)
	container.custom_minimum_size = Vector2(1000.0, 0.0)
	container.add_theme_constant_override(&"separation", 16)
	add_child(container)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override(&"font_size", 28)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(_title_label)

	_image_rect = TextureRect.new()
	_image_rect.custom_minimum_size = Vector2(1000.0, 400.0)
	_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(_image_rect)

	_text_label = RichTextLabel.new()
	_text_label.custom_minimum_size = Vector2(1000.0, 200.0)
	_text_label.fit_content = true
	_text_label.bbcode_enabled = false
	container.add_child(_text_label)

	var nav_box: HBoxContainer = HBoxContainer.new()
	nav_box.add_theme_constant_override(&"separation", 16)
	nav_box.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(nav_box)

	_prev_button = Button.new()
	_prev_button.text = "Anterior"
	_prev_button.pressed.connect(_prev)
	nav_box.add_child(_prev_button)

	var close_button: Button = Button.new()
	close_button.text = "Volver"
	close_button.pressed.connect(_close)
	nav_box.add_child(close_button)

	_next_button = Button.new()
	_next_button.text = "Siguiente"
	_next_button.pressed.connect(_next)
	nav_box.add_child(_next_button)


func _show_fact(index: int) -> void:
	_index = clampi(index, 0, FACTS.size() - 1)
	var fact: Dictionary = FACTS[_index]
	var texture: Texture2D = load(fact["image"]) as Texture2D
	if texture != null:
		_image_rect.texture = texture
	_title_label.text = str(fact["title"])
	_text_label.text = str(fact["text"])
	_prev_button.disabled = (_index == 0)
	_next_button.disabled = (_index == FACTS.size() - 1)


func _prev() -> void:
	_show_fact(_index - 1)


func _next() -> void:
	_show_fact(_index + 1)


func _close() -> void:
	queue_free()
