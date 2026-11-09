class_name ImpactFx
extends RefCounted
## Sensación de impacto: temblor, destello, pausa de milésimas y deformación.
## Valores provisionales, a ajustar al probar. Nada de esto cambia las reglas del juego.

const FLASH_SHADER: Shader = preload("res://core/impact_flash.gdshader")
const FLASH_PARAMETER: String = "shader_parameter/flash"
const FLASH_TIME: float = 0.14
const SQUASH_TIME: float = 0.18
const STOP_SCALE: float = 0.05


static func new_flash_material() -> ShaderMaterial:
	var flash_material: ShaderMaterial = ShaderMaterial.new()
	flash_material.shader = FLASH_SHADER
	return flash_material


static func flash(item: CanvasItem) -> void:
	if GameSettings.reduce_motion:
		return
	if item.material == null:
		item.material = new_flash_material()
	var flash_material: ShaderMaterial = item.material as ShaderMaterial
	if flash_material == null:
		return
	flash_material.set_shader_parameter(&"flash", 1.0)
	var tween: Tween = item.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(flash_material, FLASH_PARAMETER, 0.0, FLASH_TIME)
	tween.tween_callback(_release_flash.bind(item, flash_material))


## Con material propio no se agrupa con los demás, así que solo lo tiene mientras destella.
static func _release_flash(item: CanvasItem, flash_material: ShaderMaterial) -> void:
	if item.material == flash_material and float(flash_material.get_shader_parameter(&"flash")) <= 0.0:
		item.material = null


## Deforma una propiedad de escala y la devuelve a su sitio con rebote.
static func squash(node: Node, property: String, amount: Vector2) -> void:
	node.set(property, amount)
	var tween: Tween = node.create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(node, property, Vector2.ONE, SQUASH_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func shake(viewport: Viewport, strength: float) -> void:
	var camera: CameraZoom = viewport.get_camera_2d() as CameraZoom
	if camera != null and not GameSettings.reduce_motion:
		camera.shake(strength)


## Casi detiene el tiempo un instante. Solo lo devuelve si nadie lo ha cambiado entretanto.
static func hit_stop(tree: SceneTree, seconds: float) -> void:
	if GameSettings.reduce_motion or tree.paused or Engine.time_scale <= STOP_SCALE:
		return
	var previous: float = Engine.time_scale
	Engine.time_scale = STOP_SCALE
	var timer: SceneTreeTimer = tree.create_timer(seconds, true, false, true)
	timer.timeout.connect(func() -> void:
		if is_equal_approx(Engine.time_scale, STOP_SCALE):
			Engine.time_scale = previous
	)
