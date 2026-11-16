class_name PropArt
extends RefCounted
## Qué dibujo lleva cada objeto de la zona: [archivo, ancho, alto y, opcional, copias].

const FOLDER: String = "res://art/shared/props/"
const CHARACTER_ART: Array[String] = ["res://art/shared/jubilado_hierro.svg", "res://art/shared/mohocrata.svg"]
const BY_ID: Dictionary = {
	"paca": ["res://art/shared/jubilado_hierro.svg", 77.0, 77.0],
	"eusebio": ["res://art/shared/jubilado_hierro.svg", 77.0, 77.0],
	"seta": ["res://art/shared/mohocrata.svg", 77.0, 77.0],
	"anselmo": ["res://art/shared/mohocrata.svg", 77.0, 77.0],
	"cuadrilla_moho": ["res://art/shared/mohocrata.svg", 77.0, 77.0, 3],
	"patrulla_jub": ["res://art/shared/jubilado_hierro.svg", 77.0, 77.0, 3],
	"zapatilla_de_andar_por_casa_con_gps": ["zapatilla_de_andar_por_casa_con_gps", 70.0, 60.0],
	"paraguas_que_solo_abre_cuando_no_llueve": ["paraguas_que_solo_abre_cuando_no_llueve", 70.0, 60.0],
	"reloj_que_marca_la_hora_en_base_7": ["reloj_que_marca_la_hora_en_base_7", 70.0, 60.0],
	"cepillo_de_dientes_con_bluetooth": ["cepillo_de_dientes_con_bluetooth", 70.0, 60.0],
	"tostadora_que_solo_tuesta_por_un_lado": ["tostadora_que_solo_tuesta_por_un_lado", 70.0, 60.0],
	"par_de_calcetines_con_gps_integrado": ["par_de_calcetines_con_gps_integrado", 70.0, 60.0],
	"mando_a_distancia_que_solo_funciona_si_gritas": ["mando_a_distancia_que_solo_funciona_si_gritas", 70.0, 60.0],
	"lampara_que_se_apaga_cuando_hay_gente": ["lampara_que_se_apaga_cuando_hay_gente", 70.0, 60.0],
	"silla_que_se_mueve_sola": ["silla_que_se_mueve_sola", 70.0, 60.0],
	"espejo_que_te_hace_mas_guapo": ["espejo_que_te_hace_mas_guapo", 70.0, 60.0],
	"drone_que_solo_vuela_hacia_abajo": ["drone_que_solo_vuela_hacia_abajo", 70.0, 60.0],
	"teclado_que_escribe_lo_que_piensas": ["teclado_que_escribe_lo_que_piensas", 70.0, 60.0],
	"raton_de_ordenador_que_huye": ["raton_de_ordenador_que_huye", 70.0, 60.0],
	"pantalla_que_muestra_lo_que_quieres_ver_no_lo_que_hay": ["pantalla_que_muestra_lo_que_quieres_ver_no_lo_que_hay", 70.0, 60.0],
	"altavoz_que_solo_reproduce_silencio": ["altavoz_que_solo_reproduce_silencio", 70.0, 60.0],
	"camara_que_borra_lo_que_fotografia": ["camara_que_borra_lo_que_fotografia", 70.0, 60.0],
	"impresora_que_solo_imprime_en_invisible": ["impresora_que_solo_imprime_en_invisible", 70.0, 60.0],
	"router_que_solo_conecta_a_redes_inventadas": ["router_que_solo_conecta_a_redes_inventadas", 70.0, 60.0],
	"bateria_que_se_carga_con_aplausos": ["bateria_que_se_carga_con_aplausos", 70.0, 60.0],
	"cable_usb_que_solo_funciona_si_lo_giras_3_veces": ["cable_usb_que_solo_funciona_si_lo_giras_3_veces", 70.0, 60.0],
	"sombrero_que_te_hace_invisible_a_los_que_no_te_quieren": ["sombrero_que_te_hace_invisible_a_los_que_no_te_quieren", 70.0, 60.0],
	"guantes_que_escriben_lo_que_dices": ["guantes_que_escriben_lo_que_dices", 70.0, 60.0],
	"zapatos_que_te_llevan_donde_quieren": ["zapatos_que_te_llevan_donde_quieren", 70.0, 60.0],
	"gafas_que_ven_el_futuro_pero_solo_el_pasado": ["gafas_que_ven_el_futuro_pero_solo_el_pasado", 70.0, 60.0],
	"bufanda_que_se_calienta_cuando_mientes": ["bufanda_que_se_calienta_cuando_mientes", 70.0, 60.0],
	"cinturon_que_se_afloja_cuando_comes": ["cinturon_que_se_afloja_cuando_comes", 70.0, 60.0],
	"reloj_de_pulsera_que_marca_la_hora_en_la_que_deberias_haber_llegado": ["reloj_de_pulsera_que_marca_la_hora_en_la_que_deberias_haber_llegado", 70.0, 60.0],
	"anillo_que_se_agranda_cuando_estas_nervioso": ["anillo_que_se_agranda_cuando_estas_nervioso", 70.0, 60.0],
	"corbata_que_se_anuda_sola": ["corbata_que_se_anuda_sola", 70.0, 60.0],
	"calcetines_que_se_emparejan_solos": ["calcetines_que_se_emparejan_solos", 70.0, 60.0],
	"cuchara_que_mide_la_tristeza": ["cuchara_que_mide_la_tristeza", 70.0, 60.0],
	"tenedor_que_solo_pincha_lo_que_te_gusta": ["tenedor_que_solo_pincha_lo_que_te_gusta", 70.0, 60.0],
	"plato_que_se_limpia_solo_pero_solo_si_le_cantas": ["plato_que_se_limpia_solo_pero_solo_si_le_cantas", 70.0, 60.0],
	"vaso_que_nunca_se_vacia": ["vaso_que_nunca_se_vacia", 70.0, 60.0],
	"sarten_que_cocina_sola": ["sarten_que_cocina_sola", 70.0, 60.0],
	"nevera_que_te_juzga_por_lo_que_comes": ["nevera_que_te_juzga_por_lo_que_comes", 70.0, 60.0],
	"microondas_que_solo_calienta_en_el_centro": ["microondas_que_solo_calienta_en_el_centro", 70.0, 60.0],
	"batidora_que_solo_bate_en_silencio": ["batidora_que_solo_bate_en_silencio", 70.0, 60.0],
	"cafetera_que_solo_hace_te": ["cafetera_que_solo_hace_te", 70.0, 60.0],
	"tostador_que_solo_tuesta_por_un_lado": ["tostador_que_solo_tuesta_por_un_lado", 70.0, 60.0],
	"grapadora_que_grapas_en_el_aire": ["grapadora_que_grapas_en_el_aire", 70.0, 60.0],
	"boligrafo_que_solo_escribe_en_invisible": ["boligrafo_que_solo_escribe_en_invisible", 70.0, 60.0],
	"papelera_que_te_devuelve_lo_que_tiras": ["papelera_que_te_devuelve_lo_que_tiras", 70.0, 60.0],
	"grapadora_que_solo_grapa_en_el_vacio": ["grapadora_que_solo_grapa_en_el_vacio", 70.0, 60.0],
	"silla_de_oficina_que_se_mueve_sola": ["silla_de_oficina_que_se_mueve_sola", 70.0, 60.0],
	"mesa_que_se_inclina_cuando_estas_triste": ["mesa_que_se_inclina_cuando_estas_triste", 70.0, 60.0],
	"telefono_que_solo_llama_a_numeros_inventados": ["telefono_que_solo_llama_a_numeros_inventados", 70.0, 60.0],
	"fax_que_envia_a_otra_dimension": ["fax_que_envia_a_otra_dimension", 70.0, 60.0],
	"panel": ["panel", 72.0, 96.0],
	"zapatilla_gps": ["zapatilla_gps", 80.0, 60.0],
	"paraguas_rebelde": ["paraguas_rebelde", 80.0, 80.0],
	"tostadora_filosofica": ["tostadora_filosofica", 80.0, 70.0],
	"contestador": ["contestador", 96.0, 112.0],
	"mina_suelta": ["res://art/shared/mina_petanca.svg", 44.0, 44.0],
	"muro_agrietado": ["grieta", 70.0, 70.0],
	"generador": ["generador", 77.0, 77.0],
	"e_sombrero": ["sombrero", 60.0, 46.0],
	"e_acta": ["acta", 48.0, 55.0],
	"e_aceite": ["aceite", 100.0, 42.0],
	"e_manolo": ["robot_apagado", 105.0, 90.0],
	"e_placa": ["placa", 48.0, 48.0],
	"e_etiqueta": ["etiqueta", 48.0, 48.0],
	"e_soldadura_1": ["soldadura", 65.0, 55.0],
	"e_soldadura_2": ["soldadura", 65.0, 55.0],
}
const BY_KIND: Dictionary = {
	Interactable.Kind.CRATE: ["caja", 65.0, 60.0],
	Interactable.Kind.TERMINAL: ["terminal", 56.0, 84.0],
	Interactable.Kind.PICKUP_LEG: ["pierna", 60.0, 60.0],
	Interactable.Kind.PICKUP_ARM: ["brazo", 60.0, 60.0],
	Interactable.Kind.EVIDENCE: ["objeto_perdido", 60.0, 56.0],
	Interactable.Kind.NPC: ["objeto_perdido", 60.0, 56.0],
}
const COPY_OFFSET: Vector2 = Vector2(46.0, 16.0)

static var _cache: Dictionary = {}


static func texture(name_or_path: String) -> Texture2D:
	var path: String = name_or_path
	if not path.begins_with("res://"):
		path = "%s%s.svg" % [FOLDER, name_or_path]
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


static func entry_for(item_id: String, kind: Interactable.Kind) -> Array:
	if item_id.begins_with("rastro_"):
		return ["restos_fiesta", 90.0, 60.0]
	return BY_ID.get(item_id, BY_KIND[kind])


## Dibuja el objeto con los pies en el origen del nodo.
## Los personajes con nombre se dibujan al mismo tamaño que los demás.
static func scale_of(entry: Array) -> float:
	return CharacterScale.value if CHARACTER_ART.has(str(entry[0])) else 1.0


static func draw_entry(node: CanvasItem, entry: Array) -> void:
	var factor: float = scale_of(entry)
	var size: Vector2 = Vector2(float(entry[1]), float(entry[2])) * factor
	var copies: int = int(entry[3]) if entry.size() > 3 else 1
	for index: int in range(copies):
		var shift: Vector2 = COPY_OFFSET * factor * Vector2(float(index) - float(copies - 1) * 0.5, float(index % 2))
		node.draw_texture_rect(texture(entry[0]), Rect2(shift - Vector2(size.x * 0.5, size.y), size), false)
