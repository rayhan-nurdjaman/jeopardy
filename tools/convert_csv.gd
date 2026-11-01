extends SceneTree
# Run: godot4 --headless --path . --script tools/convert_csv.gd
# Optional CSV column "Image": a res:// path to a texture.

const CSV_PATH := "res://source/questions.csv"
const OUT_PATH := "res://data/questions.tres"

func _init() -> void:
	var f := FileAccess.open(CSV_PATH, FileAccess.READ)
	var header := f.get_csv_line()
	var col := {}
	for i in header.size():
		col[header[i].strip_edges()] = i

	var bank := QuestionBank.new()
	var game := ""
	var topic := ""
	while not f.eof_reached():
		var row := f.get_csv_line()
		if row.size() < header.size() or row[col["Points"]].strip_edges() == "":
			continue
		if row[col["Sets"]] != "":
			game = row[col["Sets"]].strip_edges()
		if row[col["Topics"]] != "":
			topic = row[col["Topics"]].strip_edges()

		var q := Question.new()
		q.game = game
		q.topic = topic
		q.points = int(row[col["Points"]])
		q.question = row[col["Example Question"]].strip_edges()
		q.answer = row[col["Example Answer"]].strip_edges()
		for n in [1, 2, 3]:
			var w: String = row[col["Bogey Answer %d" % n]].strip_edges()
			if w != "":
				q.wrong_answers.append(w)
		if col.has("Image"):
			var path: String = row[col["Image"]].strip_edges()
			if path != "":
				q.image = load(path)
		bank.questions.append(q)

	var err := ResourceSaver.save(bank, OUT_PATH)
	print("Saved %d questions to %s (err=%d)" % [bank.questions.size(), OUT_PATH, err])
	quit()
