class_name DespliegueCeroFacades
extends RefCounted
## Fachadas de los edificios de la beta, que se aclaran al entrar el jugador.

const ART_CENTRAL: String = "res://art/shared/fachada_centralita.svg"
const ART_DEPOT: String = "res://art/shared/fachada_deposito.svg"


static func build(zone: DespliegueCeroZone) -> void:
	var central: BuildingFacade = _add(
		zone, ART_CENTRAL, DespliegueCeroLayout.central_door.end.y, DespliegueCeroLayout.central_facade,
		DespliegueCeroLayout.central_inside, [zone.door, zone.cracked_wall]
	)
	central.door_wall = zone.door
	central.door_hole = Rect2(
		DespliegueCeroLayout.central_door.position.x - central.position.x,
		-DespliegueCeroLayout.facade_door_height - 8.0,
		DespliegueCeroLayout.central_door.size.x, DespliegueCeroLayout.facade_door_height
	)
	_add(zone, ART_DEPOT, DespliegueCeroLayout.depot.end.y + 40.0, DespliegueCeroLayout.depot_facade, DespliegueCeroLayout.depot, [])


static func _add(
	zone: DespliegueCeroZone, path: String, base_y: float, art_rect: Rect2, interior: Rect2, labeled: Array[Wall]
) -> BuildingFacade:
	var facade: BuildingFacade = BuildingFacade.new()
	facade.texture = load(path) as Texture2D
	facade.position = Vector2(art_rect.position.x, base_y + 1.0)
	facade.art_rect = Rect2(Vector2(0.0, art_rect.position.y - facade.position.y), art_rect.size)
	facade.interior = interior
	facade.player = zone.player
	facade.labeled_walls = labeled
	zone.actors.add_child(facade)
	return facade
