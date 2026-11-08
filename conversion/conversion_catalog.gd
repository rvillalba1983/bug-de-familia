class_name ConversionCatalog
extends RefCounted
## Materiales, objetivos, propiedades, acciones y preguntas, cargados de datos.

const CATALOG_PATH: String = "res://data/conversion/catalog.json"
const QUESTIONS_PATH: String = "res://data/conversion/questions.json"

var materials: Dictionary = {}
var objectives: Dictionary = {}
var properties: Dictionary = {}
var actions: Dictionary = {}
var questions: Array = []


static func load_default() -> ConversionCatalog:
	var catalog: ConversionCatalog = ConversionCatalog.new()
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var bank: Variant = JSON.parse_string(FileAccess.get_file_as_string(QUESTIONS_PATH))
	if not data is Dictionary or not bank is Array:
		push_error("Datos de conversión ilegibles en data/conversion/")
		return catalog
	catalog.materials = data["materials"]
	catalog.objectives = data["objectives"]
	catalog.properties = data["properties"]
	catalog.actions = data["actions"]
	catalog.questions = bank
	for problem: String in catalog.validate():
		push_error(problem)
	return catalog


## Devuelve los problemas encontrados, indicando el campo afectado.
func validate() -> Array[String]:
	var problems: Array[String] = []
	for id: String in materials:
		for property: String in materials[id]["properties"]:
			if not properties.has(property):
				problems.append("materials.%s: no existe la propiedad %s" % [id, property])
	for id: String in objectives:
		for action: String in objectives[id]["actions"]:
			if not actions.has(action):
				problems.append("objectives.%s: no existe la acción %s" % [id, action])
	for index: int in range(questions.size()):
		var question: Dictionary = questions[index]
		if int(question["answer"]) >= (question["options"] as Array).size():
			problems.append("questions[%d].answer: fuera de las opciones" % index)
	return problems
