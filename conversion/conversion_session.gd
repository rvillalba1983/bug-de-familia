class_name ConversionSession
extends RefCounted
## Las dos preguntas de una conversión y su puntuación.

const QUESTION_COUNT: int = 2
const TIME_LIMIT: float = 5.0

var questions: Array = []
var index: int = 0

var _points: float = 0.0


func _init(bank: Array, rng: RandomNumberGenerator) -> void:
	var pool: Array = bank.duplicate()
	while questions.size() < QUESTION_COUNT and not pool.is_empty():
		questions.append(pool.pop_at(rng.randi_range(0, pool.size() - 1)))


func current() -> Dictionary:
	return questions[index]


func is_finished() -> bool:
	return index >= questions.size()


## option -1 significa que se acabó el tiempo. Devuelve si acertó.
func answer(option: int, time_left: float) -> bool:
	var correct: bool = option == int(current()["answer"])
	if correct:
		_points += 0.5 + 0.5 * clampf(time_left / TIME_LIMIT, 0.0, 1.0)
	index += 1
	return correct


func score() -> float:
	return _points / float(maxi(questions.size(), 1))
