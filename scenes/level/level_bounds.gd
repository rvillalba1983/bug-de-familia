class_name LevelBounds
extends RefCounted
## Colisiones invisibles que rodean el suelo de un nivel.

const THICKNESS: float = 64.0


static func build(parent: Node, area: Rect2) -> void:
	var t: float = THICKNESS
	var sides: Array[Rect2] = [
		Rect2(area.position.x - t, area.position.y - t, area.size.x + t * 2.0, t),
		Rect2(area.position.x - t, area.end.y, area.size.x + t * 2.0, t),
		Rect2(area.position.x - t, area.position.y, t, area.size.y),
		Rect2(area.end.x, area.position.y, t, area.size.y),
	]
	for side: Rect2 in sides:
		var body: StaticBody2D = StaticBody2D.new()
		body.collision_layer = PhysicsLayers.WALLS
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = side.size
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = shape
		collider.position = side.get_center()
		body.add_child(collider)
		parent.add_child(body)
