extends SceneTree
## Comprueba contra el Godot instalado las APIs que usan la interfaz y el atlas.
## Uso: godot --headless --path . -s tools/verificar_apis_godot.gd

const PROPIEDADES: Dictionary = {
	"CharFXTransform": [
		"relative_index", "elapsed_time", "offset", "color", "env", "visible"
	],
	"RichTextLabel": ["custom_effects", "bbcode_enabled", "scroll_active"],
}
const METODOS: Dictionary = {
	"Image": [
		"create", "blit_rect", "get_used_rect", "save_png", "set_pixel", "get_region",
		"resize", "convert", "fill_rect"
	],
}


func _initialize() -> void:
	var errores: int = 0
	for clase: String in PROPIEDADES:
		for nombre: String in PROPIEDADES[clase]:
			if _tiene_propiedad(clase, nombre):
				print("OK propiedad %s.%s" % [clase, nombre])
			else:
				push_error("Falta la propiedad %s.%s" % [clase, nombre])
				errores += 1
	for clase: String in METODOS:
		for nombre: String in METODOS[clase]:
			if ClassDB.class_has_method(clase, nombre):
				print("OK metodo %s.%s" % [clase, nombre])
			else:
				push_error("Falta el metodo %s.%s" % [clase, nombre])
				errores += 1
	var nativas: PackedStringArray = PackedStringArray()
	for info: Dictionary in ClassDB.class_get_property_list("RichTextEffect", true):
		nativas.append(str(info["name"]))
	## En 4.7.2 `bbcode` no es propiedad nativa: se declara como variable de script.
	print("Propiedades nativas de RichTextEffect: %s" % (
		", ".join(nativas) if not nativas.is_empty() else "ninguna; bbcode va por script"
	))
	print("RESULTADO: %d errores" % errores)
	quit(1 if errores > 0 else 0)


func _tiene_propiedad(clase: String, nombre: String) -> bool:
	for info: Dictionary in ClassDB.class_get_property_list(clase, true):
		if str(info["name"]) == nombre:
			return true
	return false
