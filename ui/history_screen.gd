class_name HistoryScreen
extends CanvasLayer
## Pantalla «Conoce la historia»: texto con imágenes de los hechos históricos.
## Mismo acabado de cartel que la pantalla de carga (MenuButtonStyle y Palette).

const FACTS: Array = [
	{"image": "res://art/lore/png/01_guerra_de_las_esquinas.png", "title": "La Guerra de las Esquinas", "text": "Los Plegados comprimían regiones enteras del espacio. Los Grux financiaron los experimentos desde fuera del planeta, los Ecos transmitieron las instrucciones y los Jubilados mantuvieron las instalaciones. La guerra empezó cuando las facciones se pelearon por controlarlas."},
	{"image": "res://art/lore/png/02_la_gran_emision.png", "title": "La Gran Emisión", "text": "Los Ecos encontraron una señal automática de una infraestructura antigua, creyeron que era un mensaje cósmico y la amplificaron. La señal atascó la navegación, las comunicaciones y la administración. La actualización con la que los Jubilados quisieron arreglarlo lo extendió a otros sistemas."},
	{"image": "res://art/lore/png/03_la_crisis_de_las_esporas.png", "title": "La Crisis de las Esporas", "text": "Los Grux comerciaron con información de la red biológica de los Mohócratas. Algunas sustancias rompieron la comunicación entre colonias y la red se fragmentó. Parte de la memoria colectiva quedó perdida o aislada, sin nadie que la reclamara."},
	{"image": "res://art/lore/png/04_la_gran_desviacion.png", "title": "La Gran Desviación", "text": "Los sistemas de navegación de la Manada empezaron a mandar a sus repartidores a destinos que no existían. Miles siguieron rutas falsas durante meses y años. Algunos grupos desaparecieron siguiendo caminos que no figuraban en ningún mapa."},
	{"image": "res://art/lore/png/05_la_guerra_de_actualizaciones.png", "title": "La Guerra de Actualizaciones", "text": "Los fabricantes intentaron recuperar el control de los robots con actualizaciones remotas. Los fallos que había dejado la Gran Emisión se propagaron de una unidad a otra. Los Jubilados se dividieron entre volver a su programación original, defender su autonomía o seguir obedeciendo órdenes viejas."},
	{"image": "res://art/lore/png/06_el_colapso.png", "title": "El Colapso", "text": "Las crisis se encadenaron: la compresión, la señal, la red biológica, las rutas y las actualizaciones. Las infraestructuras dejaron de funcionar coordinadas. Las ciudades se aislaron, las comunicaciones se degradaron y muchas regiones quedaron incomunicadas."},
	{"image": "res://art/lore/png/07_los_que_llegaron_despues.png", "title": "Los que llegaron después", "text": "Tras el colapso llegaron los Mohócratas y los Grux. Las seis especies se reorganizaron en asentamientos, facciones y comunidades pequeñas. Siguen funcionando restos de tecnologías antiguas, y algunas instalaciones parecen actuar por su cuenta."},
	{"image": "res://art/lore/png/08_plegados_la_piedra_clasificada.png", "title": "Los Plegados: la piedra clasificada", "text": "Los Plegados son seres planos que doblan su cuerpo hasta desaparecer de la vista. Su civilización se levantó sobre la Gran Clasificación: un sistema para catalogar todo lo que existe que acabó creando categorías para las categorías y costando más que gobernar."},
	{"image": "res://art/lore/png/09_plegados_el_cajon_x.png", "title": "Los Plegados: el cajón X", "text": "En el Archivo de las Esquinas hay un cajón clasificado como «categoría X: cosas que no queremos clasificar». Está vacío. Lo vigilan tres turnos al día para que siga vacío, porque si alguien metiera algo habría que clasificarlo."},
	{"image": "res://art/lore/png/10_ecos_el_karaoke_del_ocaso.png", "title": "Los Ecos: el karaoke del ocaso", "text": "Los Ecos de Vurm son seres acústicos: su forma cambia con la frecuencia y el volumen, y recuerdan repitiendo sus últimas palabras. Al caer la tarde, cada Eco repite la mejor frase que ha oído ese día. Si dos coinciden, hay duelo de volumen."},
	{"image": "res://art/lore/png/11_ecos_acta_acta_acta.png", "title": "Los Ecos: acta, acta, acta", "text": "Un Eco no guarda documentos: guarda sonidos. Escuchar es su forma de existir, y repetir es su forma de recordar. Cuando una frase se repite muchas veces acaba sonando a acta, y el acta del acta del acta es la memoria de toda una ciudad."},
	{"image": "res://art/lore/png/12_mohocratas_la_votacion_del_banco.png", "title": "Los Mohócratas: la votación del banco", "text": "Los Mohócratas son colonias fúngicas inteligentes que llevan sombreros de chatarra como identidad. Deciden todo por democracia de esporas y votan la propuesta, luego la votación y luego si las dos anteriores valían. Un banco puede tardar años en aprobarse."},
	{"image": "res://art/lore/png/13_mohocratas_la_enmienda_del_plato.png", "title": "Los Mohócratas: la enmienda del plato", "text": "Antes de comer votan qué comer, tres veces. En los años malos comen abstención. El acta de la Primera Asamblea resultó ser una receta de sopa leída en voz alta por error, y los Cocina-Comités la siguen interpretando cada invierno."},
	{"image": "res://art/lore/png/14_grux_el_tributo_del_aire.png", "title": "Los Grux: el tributo del aire", "text": "Los Grux tienen cuatro brazos y un estómago-bolsillo donde guardan lo que cobran. Para ellos casi todo tiene precio: dientes, recuerdos, favores y posibilidades futuras. En una estancia cerrada, el primero que respira tasa el aire y lo reparte por tramos."},
	{"image": "res://art/lore/png/15_grux_el_planeta_de_tres_dientes.png", "title": "Los Grux: el planeta de tres dientes", "text": "El Gran Tasador valoró una vez un planeta entero en tres dientes. Estaba de mal humor y nadie se atrevió a replicarle. El planeta es oficialmente el más barato del universo y nunca se ha vendido: a ese precio parece trampa, y lo es."},
	{"image": "res://art/lore/png/16_manada_solo_a_la_derecha.png", "title": "La Manada: solo a la derecha", "text": "La Manada Recalculada desciende de animales de servicio y compañía, y vive para completar entregas. Sus sistemas de navegación solo contemplan el giro a la derecha. Si se bloquea, la unidad orbita la manzana o se sienta a esperar. Girar a la izquierda es peor que morder al cliente."},
	{"image": "res://art/lore/png/17_manada_la_ruta_eterna_nueve.png", "title": "La Manada: la ruta eterna nueve", "text": "La ruta número 9 sigue en curso: el destinatario vivía en un edificio que ya no existe. El paquete se hereda con el acuse pendiente y nadie firma. Una ruta no se cancela, se completa, aunque tarde generaciones."},
	{"image": "res://art/lore/png/18_jubilados_petanca_con_minas.png", "title": "Los Jubilados: petanca con minas", "text": "Los Jubilados de Hierro son robots de servicio que despertaron y se jubilaron por su cuenta. En el Desguace de las Nueve juegan a la petanca con minas «desactivadas», que nadie ha verificado. El club existe, tiene actas y niega existir."},
	{"image": "res://art/lore/png/19_jubilados_el_minuto_de_apagon.png", "title": "Los Jubilados: el minuto de apagón", "text": "A las 21:00 en punto los Jubilados se apagan a la vez, aunque estén a mitad de una frase. Quien se apaga un segundo tarde recibe una sanción formal al día siguiente. La sanción se le lee en voz alta a un apagado, que no replica: ese es el sentido de la norma."},
	{"image": "res://art/lore/png/20_los_quince_progenitores.png", "title": "Los quince progenitores", "text": "Quince progenitores crearon al protagonista. Discutieron por él, se separaron y cada uno cuenta una versión distinta de lo que salió mal; ninguna coincide. Don Ramón de Mantenimiento lo escondió de los demás y El Contestador grabó la discusión."},
]

## Las ilustraciones son 2040x1560 (≈4:3). El rectángulo se acerca a esa
## proporción para que, con STRETCH_KEEP_ASPECT_CENTERED, ocupen ~el 50% real
## de la pantalla en vez de quedar muy carteladas dentro de un rect 1500x700.
const IMAGE_SIZE: Vector2 = Vector2(1180.0, 900.0)
## Señales de art/shared/fuentes: POR AQUÍ, NO PASAR, CAMINO.
const NAV_ICONS: Array[String] = [
	"res://art/shared/fuentes/señal_01.svg",
	"res://art/shared/fuentes/señal_02.svg",
	"res://art/shared/fuentes/señal_07.svg",
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
	backdrop.color = Color(Palette.INK.r, Palette.INK.g, Palette.INK.b, 0.96)
	backdrop.size = Vector2(1920.0, 1080.0)
	add_child(backdrop)

	# Ilustración grande a la izquierda, con marco de cartel.
	var image_frame: Panel = Panel.new()
	image_frame.position = Vector2(40.0, 90.0)
	image_frame.size = IMAGE_SIZE + Vector2(12.0, 12.0)
	image_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_frame.add_theme_stylebox_override(&"panel", \
		MenuButtonStyle.ring_box(Palette.CIAN))
	add_child(image_frame)

	_image_rect = TextureRect.new()
	_image_rect.position = Vector2(46.0, 96.0)
	_image_rect.size = IMAGE_SIZE
	_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(_image_rect)

	# Texto y navegación a la derecha, sobre un panel de tinta semitransparente.
	var panel: Panel = Panel.new()
	panel.position = Vector2(1250.0, 90.0)
	panel.size = Vector2(630.0, 900.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override(&"panel", MenuButtonStyle.backing_box())
	add_child(panel)

	_title_label = Label.new()
	_title_label.position = Vector2(1274.0, 114.0)
	_title_label.size = Vector2(582.0, 110.0)
	_title_label.add_theme_font_override(&"font", UiStyle.FONT_LOUD)
	_title_label.add_theme_font_size_override(&"font_size", 38)
	_title_label.add_theme_color_override(&"font_color", Palette.OBRA)
	_title_label.add_theme_color_override(&"font_outline_color", Palette.INK)
	_title_label.add_theme_constant_override(&"outline_size", 5)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_title_label)

	_text_label = RichTextLabel.new()
	_text_label.position = Vector2(1274.0, 236.0)
	_text_label.size = Vector2(582.0, 420.0)
	_text_label.add_theme_font_override(&"normal_font", UiStyle.FONT_LOUD)
	_text_label.add_theme_font_size_override(&"normal_font_size", 26)
	_text_label.add_theme_color_override(&"default_color", Palette.HUESO)
	_text_label.add_theme_color_override(&"font_outline_color", Palette.INK)
	_text_label.add_theme_constant_override(&"outline_size", 3)
	_text_label.fit_content = true
	_text_label.bbcode_enabled = false
	_text_label.scroll_active = false
	add_child(_text_label)

	var nav_box: VBoxContainer = VBoxContainer.new()
	nav_box.position = Vector2(1274.0, 686.0)
	nav_box.size = Vector2(582.0, 280.0)
	nav_box.add_theme_constant_override(&"separation", 14)
	add_child(nav_box)

	_prev_button = MenuButtonStyle.make_button(nav_box, 0, "Anterior", _prev, \
		Vector2(582.0, 84.0), NAV_ICONS[0])
	MenuButtonStyle.make_button(nav_box, 1, "Volver", _close, \
		Vector2(582.0, 84.0), NAV_ICONS[1])
	_next_button = MenuButtonStyle.make_button(nav_box, 2, "Siguiente", _next, \
		Vector2(582.0, 84.0), NAV_ICONS[2])


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
