class_name ZoneBase
extends Sandbox
## Zona genérica del mundo (ADR 0027). La escena es fija y la geometría, la
## población y los objetos se declaran en data/zones/<id>.json.
##
## La zona de despliegue cero conserva su escena propia (`DespliegueCeroZone
## extends ZoneBase`). Las zonas provisionales usan `scenes/zones/zone.tscn`, que
## monta el suelo, los bloques de forma, los corredores y los puntos de guardado
## del JSON.

signal transition_requested(to_zone: String)

const ART_FOLDER: String = "res://art/shared/"
const FAST_TRAVEL_LABEL: String = "UI_FAST_TRAVEL"
const FAST_TRAVEL_ITEM: String = "fast_travel_"
const SIGN_LABEL: String = "UI_ZONE_SIGN"
const SIGN_SHOW_TIME: float = 3.0
## Altura de los muros de corredor: por encima de las 48 u de las salas, para que
## el frente oculte el tramo siguiente en la proyección y el pasillo tenga identidad.
const CORRIDOR_WALL_HEIGHT: float = 200.0
## Profundidad de la lengüeta del fondo de las bocas sur: la justa para que su
## tejado no llegue a los pies de quien aparece en el pasillo.
const BACKDROP_LIP: float = 16.0
## Distancia de la señal de la boca hacia dentro de la sala.
const SIGN_LIFT: float = 150.0
## Catálogo de señales del director: `señal_01`..`señal_10`. Si el corredor no
## declara `sign`, se elige una por el destino (ADR 0034).
const SIGN_PREFIX: String = "señal_"
const SIGN_COUNT: int = 10
## Nombre de la zona destino que se superpone al cartel de la señal: tipografía
## grande con contorno de tinta y fondo semitransparente para que se lea encima.
const SIGN_NAME_SIZE: int = 26
const SIGN_NAME_OUTLINE: int = 6
## Desplazamiento del nombre respecto al ancla de la señal: 0 lo centra sobre el
## cartel (la señal mide 200 × 125 u con la proporción 512 × 320).
const SIGN_NAME_DROP: float = 0.0
## Fondo del nombre: tinta semitransparente para que el cartel se siga viendo
## detrás del texto, con el contorno de tinta del arte.
const SIGN_NAME_BG_ALPHA: float = 0.35
## Los textos de la boca van por encima de los muros; el nombre, sobre la señal.
const SIGN_SPRITE_Z: int = 1
const SIGN_NAME_Z: int = 2
## Fachadas genéricas de corredor (P-53), dibujadas por el agente `arte` el 17-nov
## (registro en `docs/36_pipeline_graficos.md`). Se alternan por orden de montaje.
## Son el **fallback** para las zonas que no tienen fachadas propias (hoy solo
## `despliegue_cero`, según la directriz del director del 17-nov: P-56).
const CORRIDOR_FACADE_ART_DEFAULT: Array[String] = [
	"res://art/shared/fachada_corredor_01.svg",
	"res://art/shared/fachada_corredor_02.svg",
	"res://art/shared/fachada_corredor_03.svg",
	"res://art/shared/fachada_corredor_04.svg",
]
## Fachadas propias por zona (P-56): cada zona con identidad visual propia declara
## aquí sus 4 SVGs. Si una zona no aparece, se usa `CORRIDOR_FACADE_ART_DEFAULT`.
## Único punto donde cambiar el juego de fachadas de un zona: no se toca ni datos
## (JSON) ni la lógica de montaje (`_build_corridor_facades`).
const CORRIDOR_FACADE_ART_BY_ZONE: Dictionary = {
	"cumbre": [
		"res://art/shared/fachada_corredor_cumbre_01.svg",
		"res://art/shared/fachada_corredor_cumbre_02.svg",
		"res://art/shared/fachada_corredor_cumbre_03.svg",
		"res://art/shared/fachada_corredor_cumbre_04.svg",
	],
	"desguace": [
		"res://art/shared/fachada_corredor_desguace_01.svg",
		"res://art/shared/fachada_corredor_desguace_02.svg",
		"res://art/shared/fachada_corredor_desguace_03.svg",
		"res://art/shared/fachada_corredor_desguace_04.svg",
	],
	"encrucijada": [
		"res://art/shared/fachada_corredor_encrucijada_01.svg",
		"res://art/shared/fachada_corredor_encrucijada_02.svg",
		"res://art/shared/fachada_corredor_encrucijada_03.svg",
		"res://art/shared/fachada_corredor_encrucijada_04.svg",
	],
	"gran_cruce": [
		"res://art/shared/fachada_corredor_gran_cruce_01.svg",
		"res://art/shared/fachada_corredor_gran_cruce_02.svg",
		"res://art/shared/fachada_corredor_gran_cruce_03.svg",
		"res://art/shared/fachada_corredor_gran_cruce_04.svg",
	],
	"gran_mercado": [
		"res://art/shared/fachada_corredor_gran_mercado_01.svg",
		"res://art/shared/fachada_corredor_gran_mercado_02.svg",
		"res://art/shared/fachada_corredor_gran_mercado_03.svg",
		"res://art/shared/fachada_corredor_gran_mercado_04.svg",
	],
	"paso": [
		"res://art/shared/fachada_corredor_paso_01.svg",
		"res://art/shared/fachada_corredor_paso_02.svg",
		"res://art/shared/fachada_corredor_paso_03.svg",
		"res://art/shared/fachada_corredor_paso_04.svg",
	],
	"poligono": [
		"res://art/shared/fachada_corredor_poligono_01.svg",
		"res://art/shared/fachada_corredor_poligono_02.svg",
		"res://art/shared/fachada_corredor_poligono_03.svg",
		"res://art/shared/fachada_corredor_poligono_04.svg",
	],
	"taller": [
		"res://art/shared/fachada_corredor_taller_01.svg",
		"res://art/shared/fachada_corredor_taller_02.svg",
		"res://art/shared/fachada_corredor_taller_03.svg",
		"res://art/shared/fachada_corredor_taller_04.svg",
	],
}
## Provisional: distancia a la que un grupo se mete en la pelea de los suyos.
const GROUP_REACT_RADIUS: float = 250.0

var definition: ZoneDefinition = null
var live_world: LiveWorld = null
var battles: BattleDirector = null

var _zone_enemy_ids: Dictionary = {}
var _zone_materials: Dictionary = {}
var _corridor_areas: Array[Area2D] = []
## Edificios que delimitan los corredores (P-53). No van en `walls`: esa lista es
## la que se atenúa al tapar a un personaje y estas fachadas nunca se atenúan.
var corridor_facades: Array[CorridorFacade] = []
## Nombre de la zona destino de cada boca, por id de la zona destino.
var _zone_signs: Dictionary = {}


func zone_definition() -> ZoneDefinition:
	return definition


func set_definition(zone: ZoneDefinition) -> void:
	definition = zone


func world_size() -> Vector2:
	return _definition().world_size()


func floor_rect() -> Rect2:
	return _definition().floor_rect()


func start_point() -> Vector2:
	return _definition().start()


func wall_rects() -> Array[Rect2]:
	if not _definition().has("walls"):
		return []
	return _definition().rects("walls")


func low_cover_rects() -> Array[Rect2]:
	if not _definition().has("low_covers"):
		return []
	return _definition().rects("low_covers")


func door_rects() -> Array[Rect2]:
	return []


func save_point_positions() -> Array[Vector2]:
	if not _definition().has("save_points"):
		return [start_point()]
	return _definition().points("save_points")


func open_spots() -> Array[Vector2]:
	if not _definition().has("open_spots"):
		return [start_point()]
	return _definition().points("open_spots")


func shape_blocks() -> Array[Rect2]:
	return _definition().shape_blocks()


func corridor_rects() -> Array[Rect2]:
	var result: Array[Rect2] = []
	for corridor: Dictionary in _definition().corridors():
		result.append(corridor["rect"])
	return result


## Estado del mundo vivo, para que el gestor lo persista al salir de la zona.
func world_state() -> Dictionary:
	return live_world.to_dict() if live_world != null else {}


func population_counts() -> Dictionary:
	var counts: Dictionary = {}
	if live_world == null:
		return counts
	for id: String in live_world.sim.npc_ids:
		var npc: NpcState = live_world.sim.npcs[id]
		if npc.alive:
			counts[npc.species] = int(counts.get(npc.species, 0)) + 1
	return counts


## El gestor llama a esto después de montar la escena y aplicar el guardado.
func after_enter(from_zone: String) -> void:
	if not from_zone.is_empty():
		player.global_position = _definition().entry_point(from_zone)
	freeze_player(false)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_apply_night_peace()


func local_hour() -> int:
	return posmod(WorldCalendar.now_local() / 3600, 24)


func _apply_night_peace() -> void:
	var hour: int = local_hour()
	var night: bool = hour >= 21 or hour < 8
	for enemy: Guard in guards():
		if enemy.detector.faction != "jubilado":
			continue
		if night:
			if not enemy.no_attack:
				enemy.no_attack = true
				if enemy.is_alert():
					enemy.flee_to(enemy.global_position)
		else:
			if enemy.no_attack:
				enemy.no_attack = false
				enemy.set_passive(false)


func freeze_player(frozen: bool) -> void:
	if not is_instance_valid(player):
		return
	player.set_physics_process(not frozen)
	player.set_process_unhandled_input(not frozen)


func is_in_combat() -> bool:
	return fight != null and fight.phase != FightDirector.Phase.CALM


func _build_world() -> void:
	super()
	_build_corridors()
	_build_fast_travel()


func _build_boundaries() -> void:
	LevelBounds.build(self, floor_rect(), corridor_rects())


func _build_walls() -> void:
	for rect: Rect2 in wall_rects():
		_add_wall(rect, SandboxLayout.WALL_FRONT_HEIGHT, Wall.Kind.SOLID)
	for rect: Rect2 in low_cover_rects():
		_add_wall(rect, SandboxLayout.LOW_FRONT_HEIGHT, Wall.Kind.LOW)
	for rect: Rect2 in shape_blocks():
		_add_blocker(rect)
	var doors: Array[Rect2] = door_rects()
	if not doors.is_empty():
		door = _add_wall(doors[0], SandboxLayout.WALL_FRONT_HEIGHT, Wall.Kind.DOOR)
		door.label_key = "ITEM_DOOR"


## Los bloques de forma no se dibujan como muro: cierran el paso y oscurecen.
func _add_blocker(rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.collision_layer = PhysicsLayers.WALLS
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = rect.size
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	collider.position = rect.get_center()
	body.add_child(collider)
	add_child(body)


func _build_corridors() -> void:
	for corridor: Dictionary in _definition().corridors():
		var area: Area2D = Area2D.new()
		area.collision_layer = 0
		area.collision_mask = PhysicsLayers.PLAYER
		area.monitoring = true
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = (corridor["rect"] as Rect2).size
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = shape
		collider.position = (corridor["rect"] as Rect2).get_center()
		area.add_child(collider)
		area.body_entered.connect(_on_corridor_entered.bind(str(corridor["to"])))
		add_child(area)
		_corridor_areas.append(area)
		_build_corridor_walls(corridor)
		_build_corridor_facades(corridor)
		_build_corridor_backdrop(corridor)
		_build_zone_sign(corridor)


## Muros del pasillo físico: cierran el paso (blockers de NavGrid) y se dibujan
## como muro real (oclusión y y-sort), a diferencia de los shape_blocks.
## Es la forma legacy (ADR 0034); la forma normal desde P-53 son las fachadas.
func _build_corridor_walls(corridor: Dictionary) -> void:
	for wall_rect: Rect2 in corridor.get("walls", []):
		_add_wall(wall_rect, CORRIDOR_WALL_HEIGHT, Wall.Kind.SOLID)


## Delimitación por edificios (P-53): cada rect se monta como una fachada de
## corredor del alto de los muros. Igual que ellos, colisiona y entra en
## `_all_blockers()`, así que `NavGrid` la respeta; a diferencia de la fachada de
## un edificio transitable, nunca se atenúa: tiene que ocultar lo que hay más allá
## del pasillo. Las texturas son provisionales (ver `CORRIDOR_FACADE_ART`).
func _build_corridor_facades(corridor: Dictionary) -> void:
	for facade_rect: Rect2 in corridor.get("facades", []):
		var facade: CorridorFacade = CorridorFacade.new()
		facade.setup(facade_rect, CORRIDOR_WALL_HEIGHT, _corridor_facade_texture())
		actors.add_child(facade)
		corridor_facades.append(facade)


## Catálogo de fachadas que toca a esta zona: el propio si tiene identidad visual
## (P-56) y, si no, el fallback genérico (solo `despliegue_cero`).
func _corridor_facade_art() -> Array:
	var zone_id: String = ""
	if definition != null:
		zone_id = definition.id
	if CORRIDOR_FACADE_ART_BY_ZONE.has(zone_id):
		var value: Array = CORRIDOR_FACADE_ART_BY_ZONE[zone_id]
		return value
	return CORRIDOR_FACADE_ART_DEFAULT


## Textura de la fachada de corredor: se alternan los modelos del catálogo para
## que dos edificios seguidos no salgan iguales. Devuelve null si falta el SVG, y
## la fachada se dibuja igualmente (el error queda visible en el registro).
func _corridor_facade_texture() -> Texture2D:
	var art: Array = _corridor_facade_art()
	if art.is_empty():
		push_error("ZoneBase: catálogo de fachadas vacío para %s" % (definition.id if definition != null else "?"))
		return null
	var index: int = corridor_facades.size() % art.size()
	var path: String = art[index]
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		push_error("ZoneBase: no se encontro la fachada de corredor %s" % path)
	return texture


## Cierre visual de la boca en las salidas que la proyección no oculta.
##
## En esta proyección el frente de un muro se dibuja hacia el norte de su base
## (`entities/world/wall.gd`), así que los muros laterales del pasillo no tapan
## lo que queda al sur ni al este: por esas dos bocas se veía el pasillo cortado
## en el borde del mapa, sin nada que cerrara la vista.
##
## El fondo es un muro real (entra en `walls` para la oclusión y en `actors` para
## el y-sort) pero de tipo `BACKDROP`: no colisiona, porque el hueco del pasillo
## tiene que seguir abierto y la transición ya la dispara el Area2D del corredor.
## Su frente mide la dimensión Y del rect del corredor y arranca en el borde del
## mapa, así que queda justo sobre ese rect en pantalla y cierra la vista.
##
## No entra en `_all_blockers()` a propósito: el rect del corredor tiene que
## seguir siendo caminable en NavGrid (`test_corridor_walls_keep_gap_walkable`).
##
## Es opt-in: solo lo llevan los corredores que declaran algún delimitador
## (`walls` legacy o `facades`), así que las zonas sin pasillos físicos no cambian.
func _build_corridor_backdrop(corridor: Dictionary) -> void:
	var edge: String = str(corridor.get("edge", ""))
	if edge != "south" and edge != "east":
		return
	if (corridor.get("walls", []) as Array).is_empty() \
			and (corridor.get("facades", []) as Array).is_empty():
		return
	var rect: Rect2 = corridor["rect"] as Rect2
	var backdrop: Wall = _add_wall(
		_backdrop_footprint(rect, edge), rect.size.y, Wall.Kind.BACKDROP
	)
	# Su frente no cubre a nadie: atenuarlo descubriría justo el corte que tapa.
	backdrop.always_opaque = true


## Huella del fondo. La salida sur gasta una lengüeta corta porque el tejado del
## muro se dibuja hacia el norte, sobre el pasillo, y con la huella entera taparía
## los pies de quien aparece en la boca (el punto de entrada está 48 u dentro). En
## la salida este el tejado cae fuera del pasillo y puede ser el rect completo.
func _backdrop_footprint(rect: Rect2, edge: String) -> Rect2:
	if edge == "south":
		var lip: float = minf(BACKDROP_LIP, rect.size.y)
		return Rect2(rect.position.x, rect.end.y - lip, rect.size.x, lip)
	return rect


## Boca del pasillo: cartel SVG del director y, delante, el nombre de la zona
## destino. Sustituye al panel de texto viejo («Bienvenido a… / Seguir el camino»),
## que se retira (P-55). Toda boca lleva cartel, también las que no declaran `sign`
## (despliegue_cero): se elige por el destino con el fallback del ADR 0034.
func _build_zone_sign(corridor: Dictionary) -> void:
	var sign_id: String = _corridor_sign_id(corridor)
	_add_corridor_sign_sprite(sign_id, corridor)
	_add_corridor_sign_name(corridor)


## Señal de la boca: la que declara el corredor o, si falta, la que toca por el
## destino (`hash(to_zone) % 10 + 1`), para que ninguna boca quede sin cartel.
func _corridor_sign_id(corridor: Dictionary) -> String:
	var declared: String = str(corridor.get("sign", ""))
	if not declared.is_empty():
		return declared
	var index: int = posmod(hash(str(corridor["to"])), SIGN_COUNT) + 1
	return SIGN_PREFIX + "%02d" % index


func _add_corridor_sign_sprite(sign_id: String, corridor: Dictionary) -> void:
	var path: String = "res://art/shared/fuentes/%s.svg" % sign_id
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		push_warning("ZoneBase: no se encontro la senal %s en %s" % [sign_id, path])
		return
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = texture
	var target_width: float = 200.0
	sprite.scale = Vector2(target_width / texture.get_width(), target_width / texture.get_width())
	sprite.position = corridor_sign_position(corridor)
	# Por encima de los muros del pasillo y de su fondo: si no, en las salidas
	# norte y este queda tapada y la boca pierde su identidad.
	sprite.z_index = SIGN_SPRITE_Z
	actors.add_child(sprite)


## Nombre de la zona destino superpuesto al cartel de la señal: el SVG queda
## detrás y el texto delante (`z_index` mayor). Hijo de `actors` para el y-sort.
func _add_corridor_sign_name(corridor: Dictionary) -> void:
	var to_zone: String = str(corridor["to"])
	var label: Label = Label.new()
	label.text = _destination_name(to_zone)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override(&"font", UiStyle.FONT_LOUD)
	label.add_theme_font_size_override(&"font_size", SIGN_NAME_SIZE)
	label.add_theme_color_override(&"font_color", Palette.HUESO)
	label.add_theme_color_override(&"font_outline_color", Palette.INK)
	label.add_theme_constant_override(&"outline_size", SIGN_NAME_OUTLINE)
	label.add_theme_stylebox_override(&"normal", _sign_name_box())
	label.size = label.get_combined_minimum_size()
	label.position = corridor_sign_position(corridor) + Vector2(
		0.0, SIGN_NAME_DROP
	) - label.size * 0.5
	label.z_index = SIGN_NAME_Z
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actors.add_child(label)
	_zone_signs[to_zone] = label


## Fondo del nombre: tinta semitransparente (el cartel se sigue viendo detrás) con
## el contorno de tinta del arte.
func _sign_name_box() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(Palette.INK.r, Palette.INK.g, Palette.INK.b, SIGN_NAME_BG_ALPHA)
	box.border_color = Color(Palette.INK.r, Palette.INK.g, Palette.INK.b, 0.85)
	box.set_border_width_all(3)
	box.set_corner_radius_all(10)
	box.set_content_margin_all(6.0)
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	return box


## Nombre de la zona destino: el del registro de zonas si la monta el gestor y, si
## no hay definición, el propio identificador.
func _destination_name(to_zone: String) -> String:
	var registry: ZoneRegistry = null
	if zone_manager != null:
		registry = zone_manager.get(&"registry") as ZoneRegistry
	if registry == null:
		return to_zone
	var zone: ZoneDefinition = registry.zone(to_zone)
	return zone.display_name if zone != null else to_zone


## Posición de la señal de la boca: `SIGN_LIFT` unidades hacia dentro de la sala.
## En las salidas norte el corredor está en el borde superior del mapa, así que el
## desplazamiento va hacia el sur; con el desplazamiento hacia el norte la señal
## caía fuera del límite de la cámara y no se veía nunca.
func corridor_sign_position(corridor: Dictionary) -> Vector2:
	var rect: Rect2 = corridor["rect"] as Rect2
	var offset: float = -SIGN_LIFT
	if str(corridor.get("edge", "")) == "north":
		offset = SIGN_LIFT
	return rect.get_center() + Vector2(0.0, offset)


func _on_corridor_entered(body: Node2D, to_zone: String) -> void:
	if body != player:
		return
	transition_requested.emit(to_zone)


func _build_fast_travel() -> void:
	for index: int in range(save_points.size()):
		var point: SavePoint = save_points[index]
		var item: Interactable = Interactable.new()
		item.setup(FAST_TRAVEL_ITEM + str(index), Interactable.Kind.TERMINAL, point.position + Vector2(36.0, 0.0))
		item.custom_label = tr(FAST_TRAVEL_LABEL)
		item.reusable = true
		item.activated.connect(_on_fast_travel)
		actors.add_child(item)


func _on_fast_travel(_item: Interactable) -> void:
	if zone_manager == null or not zone_manager.has_method("travel_destinations"):
		return
	var destinations: Array = zone_manager.travel_destinations()
	if destinations.is_empty():
		show_notice(tr("UI_FAST_TRAVEL_EMPTY"))
		return
	var screen: MessageScreen = MessageScreen.new()
	var entries: Array = []
	for entry: Dictionary in destinations:
		entries.append([str(entry["name"]), _travel_to.bind(str(entry["id"]), screen)])
	entries.append([tr("UI_FAST_TRAVEL_BACK"), _close_travel.bind(screen)])
	screen.setup(FAST_TRAVEL_LABEL, entries)
	pause.begin_modal()
	add_child(screen)


func _travel_to(zone_id: String, screen: MessageScreen) -> void:
	_close_travel(screen)
	if zone_manager != null and not zone_manager.fast_travel(zone_id):
		show_notice(tr("UI_FAST_TRAVEL_BLOCKED"))


func _close_travel(screen: MessageScreen) -> void:
	screen.queue_free()
	pause.end_modal()


func _build_enemies() -> void:
	for actor: Dictionary in _definition().list_optional("actors"):
		_spawn_actor(actor)


## Pone en escena a un personaje guionado de la zona (pasivo, con ruta fija).
func _spawn_actor(actor: Dictionary) -> void:
	var zone_def: ZoneDefinition = _definition()
	var id: String = str(actor.get("id", ""))
	var route_key: String = str(actor.get("route", ""))
	if id.is_empty() or route_key.is_empty():
		push_error("%s: actor sin id o sin ruta: %s" % [zone_def.path, actor])
		return
	var species: String = str(actor.get("species", ""))
	var weapon_id: String = str(actor.get("weapon", ""))
	if not zone_def.has(route_key):
		push_error("%s: el actor «%s» no tiene la ruta «%s»" % [zone_def.path, id, route_key])
		return
	var route: Array[Vector2] = zone_def.points(route_key)
	if route.is_empty():
		push_error("%s: la ruta «%s» del actor «%s» está vacía" % [
			zone_def.path, route_key, id
		])
		return
	var look: Dictionary = _look_of(actor)
	if look.is_empty():
		return
	var guard_node: Guard = _add_zone_guard(id, route, look, weapon_id)
	guard_node.set_passive(true)
	_add_convertible(id, guard_node, str(_zone_materials.get(guard_node, "")))
	# La caída la conecta el Sandbox en _connect_enemies, con el id del JSON.
	if not species.is_empty():
		guard_node.attacked.connect(_on_zone_citizen_attacked.bind(guard_node, species))


## Aspecto de un actor: especie o progenitor, igual que en la zona de despliegue cero.
## Devuelve un diccionario vacío si el actor no se puede identificar.
func _look_of(actor: Dictionary) -> Dictionary:
	if actor.has("species"):
		return _species_look(str(actor["species"]))
	var progenitor: String = str(actor.get("progenitor", ""))
	if not ProgenitorCatalog.has(progenitor):
		push_error("%s: actor sin especie ni progenitor conocido: %s" % [
			_definition().path, actor
		])
		return {}
	var entry: Dictionary = ProgenitorCatalog.entry(progenitor)
	return {
		"species": "", "color": Color(str(entry["color"])), "art": entry["art"],
		"material": entry["material"], "deaths": entry["deaths"],
	}


func _build_investigation() -> void:
	ai = AiChatter.new()
	ai.level = self
	add_child(ai)
	investigation = InvestigationDirector.new()
	investigation.level = self
	investigation.enabled = false
	add_child(investigation)
	live_world = LiveWorld.new()
	live_world.level = self
	add_child(live_world)


func _register_convertibles() -> void:
	for entry: Dictionary in _definition().list("convertibles"):
		var id: String = str(entry["id"])
		if items.has(id):
			_add_convertible(id, items[id], str(entry["material"]))
	_build_props()


func _build_items() -> void:
	for entry: Dictionary in _definition().list("items"):
		var id: String = str(entry["id"])
		var at: Vector2 = _definition().point(str(entry["at"]))
		match str(entry["type"]):
			"named":
				_add_named(id, at, str(entry.get("label", id)), bool(entry.get("reusable", true)))
				if entry.has("art"):
					(items[id] as Interactable).art = load(str(entry["art"])) as Texture2D
			"crate":
				_add_item(id, Interactable.Kind.CRATE, at)
			"leg":
				_add_item(id, Interactable.Kind.PICKUP_LEG, at)
			"arm":
				_add_item(id, Interactable.Kind.PICKUP_ARM, at)
			_:
				push_error("%s: tipo de objeto desconocido en «%s»" % [_definition().path, id])


func _add_named(id: String, at: Vector2, label: String, reusable: bool) -> void:
	_add_item(id, Interactable.Kind.TERMINAL, at)
	var item: Interactable = items[id]
	item.custom_label = label
	item.reusable = reusable


func _build_props() -> void:
	for entry: Dictionary in _definition().list("props"):
		var spots: Array[Vector2] = _definition().points(str(entry["at"]))
		var size: Vector2 = Vector2(float(entry["size"][0]), float(entry["size"][1]))
		for index: int in range(spots.size()):
			var prop: WorldProp = WorldProp.new()
			prop.setup(str(entry["prop"]), spots[index], size)
			actors.add_child(prop)
			_add_convertible("%s_%d" % [str(entry["id_prefix"]), index], prop, str(entry["material"]))


## Pone en escena a un habitante del mundo vivo.
func add_citizen(id: String, species: String, at: Vector2, home: Rect2) -> Guard:
	var route: Array[Vector2] = [at, at + Vector2(90.0, 0.0)]
	route[1] = route[1].clamp(home.position, home.end)
	var guard_node: Guard = _add_zone_guard(id, route, _species_look(species))
	guard_node.set_passive(true)
	_add_convertible(id, guard_node, str(_zone_materials.get(guard_node, "")))
	fight.track(guard_node)
	# Los ciudadanos se crean después de que el Sandbox conectara a sus enemigos,
	# así que aquí se les conecta su caída y su cadáver. El id es el del mundo vivo:
	# el guardado los reconoce y no vuelven a aparecer.
	guard_node.fell.connect(_on_enemy_fell)
	guard_node.corpse_expired.connect(_on_corpse_expired)
	guard_node.attacked.connect(_on_zone_citizen_attacked.bind(guard_node, species))
	return guard_node


func guards() -> Array[Guard]:
	var result: Array[Guard] = []
	for enemy: Variant in _zone_enemy_ids:
		if is_instance_valid(enemy):
			result.append(enemy as Guard)
	return result


func id_of_guard(enemy: Guard) -> String:
	return str(_zone_enemy_ids.get(enemy, ""))


## El Sandbox usa _id_of para guardar caídos y retirar cadáveres; aquí la identidad
## es la del JSON (ciudadanos y actores), no el «guard/shooter» del nivel de prueba.
func _id_of(enemy: Guard) -> String:
	return id_of_guard(enemy)


func attack_citizen(enemy: Guard) -> void:
	selection.select_exactly(enemy)
	combat.engage(enemy)


func attack_dialogue_speaker(speaker: String) -> void:
	for enemy: Guard in guards():
		if not is_instance_valid(enemy) or enemy.is_down():
			continue
		if id_of_guard(enemy) == speaker:
			attack_citizen(enemy)
			return
	if live_world != null and live_world.citizens.has(speaker):
		var citizen: Guard = live_world.citizens[speaker]
		if is_instance_valid(citizen) and not citizen.is_down():
			attack_citizen(citizen)


func reward_piece() -> void:
	_add_pickup([ModularBody.Slot.ARM_MAIN_LEFT, ModularBody.Slot.ARM_MAIN_RIGHT])


func _add_zone_guard(
	id: String, route: Array[Vector2], look: Dictionary, weapon_id: String = ""
) -> Guard:
	var enemy: Guard = Guard.new()
	enemy.target = player
	enemy.nav = nav
	enemy.rng = rng
	enemy.visual.body_color = look["color"]
	enemy.visual.art_views = _load_views(str(look["art"]))
	enemy.visual.rig_folder = ART_FOLDER + "rig/" + str(look["art"])
	enemy.death = DeathCatalog.pick(look["deaths"], rng)
	if not weapon_id.is_empty():
		enemy.make_ranged(self, weapon_id)
	enemy.setup(route, ground)
	var species: String = str(look.get("species", ""))
	if not species.is_empty():
		enemy.detector.faction = species
	actors.add_child(enemy)
	_zone_enemy_ids[enemy] = id
	_zone_materials[enemy] = look["material"]
	return enemy


func _species_look(species: String) -> Dictionary:
	return {
		"species": species, "color": SpeciesCatalog.color(species), "art": SpeciesCatalog.art(species),
		"material": SpeciesCatalog.material(species), "deaths": SpeciesCatalog.deaths(species),
	}


func _load_views(base: String) -> Array[Texture2D]:
	return GuardVisual.load_views(ART_FOLDER, base)


## El Sandbox anota el caído con _id_of, que aquí es el id del JSON. La zona solo
## avisa al mundo vivo, que es lo propio de cada zona.
func _on_enemy_fell(enemy: Guard) -> void:
	super(enemy)
	if live_world != null:
		live_world.on_citizen_gone(id_of_guard(enemy))


func _on_zone_citizen_attacked(victim: Guard, species: String) -> void:
	if live_world == null:
		return
	for id: String in live_world.citizens:
		var other: Guard = live_world.citizens[id]
		if other == victim or not is_instance_valid(other):
			continue
		var npc: NpcState = live_world.sim.npcs.get(id) as NpcState
		if npc == null or npc.species != species:
			continue
		if battles != null and battles.is_fighter(id):
			continue
		if other.global_position.distance_to(victim.global_position) <= GROUP_REACT_RADIUS:
			other.join_fight()


func _shows_help_labels() -> bool:
	return true


## Los bloques de forma cierran el paso y deben estar en la rejilla de navegación.
## Los delimitadores de los corredores (muros legacy y fachadas) también: así nadie
## cruza el edificio ni el muro que separa el pasillo de la sala.
func _all_blockers() -> Array[Rect2]:
	var result: Array[Rect2] = super()
	result.append_array(shape_blocks())
	for corridor: Dictionary in _definition().corridors():
		for wall_rect: Rect2 in corridor.get("walls", []):
			result.append(wall_rect)
		for facade_rect: Rect2 in corridor.get("facades", []):
			result.append(facade_rect)
	return result


func objective_key() -> String:
	return "ZONE_OBJECTIVE"


func chat_topic() -> String:
	return tr("ZONE_OBJECTIVE")


## P-32: descubre un reto pendiente. Las zonas sin retos no hacen nada.
func discover_challenge() -> void:
	pass


func _check_goal(_feet: Vector2) -> void:
	pass


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size()), COLOR_BACKGROUND)
	draw_rect(floor_rect(), COLOR_FLOOR)
	for block: Rect2 in shape_blocks():
		draw_rect(block, COLOR_BACKGROUND)


func _begin_fresh() -> void:
	super()
	if live_world != null:
		live_world.start({})


func _apply_save(data: Dictionary) -> bool:
	var result: bool = super(data)
	if result and not data["dead"] and live_world != null:
		live_world.start(data.get("world", {}))
	return result


func snapshot() -> Dictionary:
	var data: Dictionary = super()
	data["world"] = world_state()
	return data


func _definition() -> ZoneDefinition:
	if definition == null:
		push_error("ZoneBase sin definir: falta set_definition() antes de montar la escena")
		return ZoneDefinition.load_from(DespliegueCeroLayout.PATH)
	return definition
