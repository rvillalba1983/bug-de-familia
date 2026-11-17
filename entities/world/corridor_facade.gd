class_name CorridorFacade
extends StaticBody2D
## Edificio que delimita un corredor entre zonas (P-53, ADR 0034).
##
## Hace el trabajo del muro de corredor (`Wall.Kind.SOLID`): colisiona, entra en
## `_all_blockers()` para que `NavGrid` lo respete, y vive en `actors` para el
## y-sort. La diferencia es el aspecto y la opacidad:
##
## - Se dibuja con textura de fachada (`art/shared/fachada_*.svg`) en el frente.
## - **Nunca se atenúa.** `BuildingFacade` se vuelve translúcida al acercarse el
##   jugador para no tapar las patrullas del interior; ésta, en cambio, cumple la
##   función de muro y tiene que ocultar lo que hay más allá del pasillo. Por eso
##   no procesa ni se registra en `Sandbox.walls`, que es la lista que se atenúa.
##
## Su origen es el borde inferior de la huella, igual que `Wall`, y el frente se
## dibuja hacia el norte: el edificio mira a la sala.

const OUTLINE: float = Wall.OUTLINE
## Tejado y sombra: los mismos colores que los muros para que el pasillo se lea
## como una sola pieza.
const ROOF_COLOR: Color = Wall.COLOR_ROOF
const FRONT_COLOR: Color = Wall.COLOR_FRONT_LIGHT

## Zona que ocupa el edificio, en coordenadas del mundo.
var footprint: Rect2
## Altura del frente en la proyección (el tejado se dibuja hacia el norte).
var front_height: float
var texture: Texture2D


func setup(new_footprint: Rect2, new_front_height: float, new_texture: Texture2D) -> void:
	footprint = new_footprint
	front_height = new_front_height
	texture = new_texture
	position = Vector2(footprint.position.x, footprint.end.y)
	collision_layer = PhysicsLayers.WALLS
	collision_mask = 0
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = footprint.size
	var collider: CollisionShape2D = CollisionShape2D.new()
	collider.shape = shape
	collider.position = Vector2(footprint.size.x * 0.5, -footprint.size.y * 0.5)
	add_child(collider)


## Rectángulo del frente en coordenadas locales: pegado a la base y hacia el norte.
func front_rect() -> Rect2:
	return Rect2(0.0, -front_height, footprint.size.x, front_height)


## Área que ocupa el edificio en pantalla, en coordenadas del mundo. Sirve para
## comprobar que tapa a un personaje; no se usa para atenuarlo, porque no se atenúa.
func visual_rect() -> Rect2:
	return footprint.grow_side(SIDE_TOP, front_height)


func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, footprint.size.x, Wall.SHADOW_HEIGHT), Wall.COLOR_SHADOW)
	var front: Rect2 = front_rect()
	if texture != null:
		# Provisional (P-53): la textura se estira al frente. Las fachadas
		# genéricas de corredor se dibujarán con la proporción del frente.
		draw_texture_rect(texture, front, false)
	else:
		draw_rect(front, FRONT_COLOR)
	var roof: Rect2 = Rect2(
		0.0, front.position.y - footprint.size.y, footprint.size.x, footprint.size.y
	)
	draw_rect(roof, ROOF_COLOR)
	draw_rect(roof.grow(-5.0), ROOF_COLOR.darkened(0.28))
	draw_rect(front, Palette.INK, false, OUTLINE)
	draw_rect(roof, Palette.INK, false, OUTLINE)
