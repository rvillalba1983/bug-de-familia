class_name AiPerks
extends RefCounted
## Ventajas de las IAs activas. Todos los valores son provisionales (P-05).

const OPTIMUS_LUCK: float = 0.1
const COMPOST_BONUS: float = 0.15
const CHEF_BONUS: float = 0.2
const NIHIL_EXTRA_TIME: float = 2.0
const SARGENTO_MELEE: float = 1.25
const SIESTA_STEALTH: float = 0.75
const HACK_FACTOR: float = 1.5
const CUPIDO_STREAK: int = 3

var team: AiTeam
var streak: int = 0


func _init(new_team: AiTeam) -> void:
	team = new_team


func in_love() -> bool:
	return team.can_speak("cupido") and streak >= CUPIDO_STREAK


## Suma a la puntuación de la conversión, sin pasar de 1.
func forge_score(score: float, target: Convertible, correct_count: int) -> float:
	var bonus: float = 0.0
	if correct_count > 0 and team.can_speak("pesimo_optimus"):
		bonus += OPTIMUS_LUCK
	var source: Node = target.get_parent()
	if team.can_speak("chef") and source is Guard:
		bonus += CHEF_BONUS
	if team.can_speak("compost") and source is Interactable and (source as Interactable).is_rubble():
		bonus += COMPOST_BONUS
	return minf(score + bonus, 1.0)


func question_time() -> float:
	return ConversionSession.TIME_LIMIT + (NIHIL_EXTRA_TIME if team.can_speak("nihil") else 0.0)


func melee_factor() -> float:
	return SARGENTO_MELEE if team.can_speak("sargento_bit") else 1.0


func hack_factor() -> float:
	return HACK_FACTOR if team.can_speak("burocrata") else 1.0


func still_stealth_factor() -> float:
	return SIESTA_STEALTH if team.can_speak("siestaware") else 1.0


## Mamá da la razón a su pareja tóxica y deja de avisar de peligros.
func mama_warns() -> bool:
	return team.can_speak("mama") and not team.has_active("dr_desprecio")
