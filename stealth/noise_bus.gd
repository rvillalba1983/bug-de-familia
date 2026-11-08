class_name NoiseBus
extends Node
## Propaga ruidos por el mundo y dibuja un aviso visual.

signal noise_emitted(origin: Vector2, radius: float)

var ground: Node2D


func emit_noise(origin: Vector2, radius: float) -> void:
	noise_emitted.emit(origin, radius)
	if ground != null:
		var ring: NoiseRing = NoiseRing.new()
		ring.setup(origin, radius)
		ground.add_child(ring)
