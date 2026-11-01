class_name QuestionBank
extends Resource

@export var questions: Array[Question] = []

func get_game(game: String) -> Array[Question]:
	return questions.filter(func(q: Question) -> bool: return q.game == game)
