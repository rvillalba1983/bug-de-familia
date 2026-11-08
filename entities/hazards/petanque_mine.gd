class_name PetanqueMine
extends Node2D
## Mina de petanca de los Jubilados. Salta al pisarla o con un golpe de ruido muy cerca.

signal exploded(mine: PetanqueMine)

## Valores provisionales, a ajustar al probar.
const TRIGGER_RADIUS: float = 34.0
const NOISE_TRIGGER_RADIUS: float = 50.0
const DAMAGE: float = 45.0
const EXPLOSION_NOISE: float = 700.0
const STUN_RADIUS: float = 190.0
const STUN_TIME: float = 6.0
const COLOR_BALL: Color = Color("#c8b070")

var mine_id: String = ""
var level: Sandbox

var _exploded: bool = false


func setup(id: String, at: Vector2, host: Sandbox) -> void:
	mine_id = id
	position = at
	level = host
	host.noise_bus.noise_emitted.connect(_on_noise)


func _draw() -> void:
	draw_circle(Vector2(0.0, -8.0), 9.0, COLOR_BALL)
	draw_arc(Vector2(0.0, -8.0), 9.0, 0.0, TAU, 16, Color.BLACK, 1.5)


func _physics_process(_delta: float) -> void:
	if global_position.distance_to(level.player.global_position) <= TRIGGER_RADIUS:
		detonate(true)


## Una mina lejana del jugador no le hace daño, pero se oye y aturde igual.
func detonate(hits_player: bool) -> void:
	if _exploded:
		return
	_exploded = true
	if hits_player:
		level.player.body.damage_random(DAMAGE, level.rng)
	for enemy: Guard in level.guards():
		if enemy.global_position.distance_to(global_position) <= STUN_RADIUS:
			enemy.stun(STUN_TIME)
	exploded.emit(self)
	level.noise_bus.emit_noise(global_position, EXPLOSION_NOISE)
	queue_free()


func _on_noise(origin: Vector2, _radius: float) -> void:
	if origin.distance_to(global_position) <= NOISE_TRIGGER_RADIUS:
		detonate.call_deferred(false)
