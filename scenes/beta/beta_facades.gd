class_name BetaFacades
extends RefCounted
## Fachadas de los edificios de la beta, que se aclaran al entrar el jugador.

const ART_CENTRAL: String = "res://art/beta/fachada_centralita.svg"
const ART_DEPOT: String = "res://art/beta/fachada_deposito.svg"


static func build(zone: BetaZone) -> void:
	var central: BuildingFacade = _add(
		zone, ART_CENTRAL, BetaLayout.CENTRAL_DOOR.end.y, BetaLayout.CENTRAL_FACADE,
		BetaLayout.CENTRAL_INSIDE, [zone.door, zone.cracked_wall]
	)
	central.door_wall = zone.door
	central.door_hole = Rect2(
		BetaLayout.CENTRAL_DOOR.position.x - central.position.x,
		-BetaLayout.FACADE_DOOR_HEIGHT - 8.0,
		BetaLayout.CENTRAL_DOOR.size.x, BetaLayout.FACADE_DOOR_HEIGHT
	)
	_add(zone, ART_DEPOT, BetaLayout.DEPOT.end.y + 40.0, BetaLayout.DEPOT_FACADE, BetaLayout.DEPOT, [])


static func _add(
	zone: BetaZone, path: String, base_y: float, art_rect: Rect2, interior: Rect2, labeled: Array[Wall]
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
