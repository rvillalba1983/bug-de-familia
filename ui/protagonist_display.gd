class_name ProtagonistDisplay
extends Control
## Dibuja al protagonista en pose gamberra (vista frontal).

func _draw() -> void:
	var body: ModularBody = ModularBody.new()
	ProtagonistArt.draw(self, Vector2(0.0, 1.0), 1.0, body, Color("#4a90d9"), false, 0.0)
