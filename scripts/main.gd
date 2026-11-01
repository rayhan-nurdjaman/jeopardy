extends Control

const BANK_PATH := "res://data/questions.tres"
const REVEAL_SECONDS := 3.0
const FADE_SECONDS := 0.5
const QUESTION_SECONDS := 30.0
const INTRO_FADE_SECONDS := 0.4
const ANSWER_STAGGER_SECONDS := 0.3
const READING_WPM := 150.0
const ANSWER_PAUSE_SECONDS := 1.5

var bank: QuestionBank
var game := ""
var team_count := 2
var scores: Array[int] = []
var topics: Array[String] = []
var points: Array[int] = []
var game_questions: Array[Question] = []
var team_buttons: Array[Button] = []
var active_team := 0

func _ready() -> void:
	bank = load(BANK_PATH)
	theme = BlueSkin.build()
	RenderingServer.set_default_clear_color(BlueSkin.BG)
	_show_start()

func _start_game() -> void:
	_load_questions()
	_show_grid()

func _load_questions() -> void:
	topics.clear()
	points.clear()
	game_questions = bank.get_game(game)
	for q in game_questions:
		if not topics.has(q.topic):
			topics.append(q.topic)
		if not points.has(q.points):
			points.append(q.points)

func _clear() -> void:
	for c in get_children():
		c.queue_free()

func _show_start() -> void:
	_clear()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.add_theme_constant_override("separation", 24)
	add_child(box)

	var title := Label.new()
	title.text = "JEOPARDY"
	title.add_theme_color_override("font_color", BlueSkin.GOLD)
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var names: Array[String] = []
	for q in bank.questions:
		if not names.has(q.game):
			names.append(q.game)
	game = names[0]
	var pack_row := HBoxContainer.new()
	pack_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pack_row.add_theme_constant_override("separation", 12)
	box.add_child(pack_row)
	var pack_label := Label.new()
	pack_label.text = "Question pack:"
	pack_label.add_theme_font_size_override("font_size", 32)
	pack_row.add_child(pack_label)
	var pack_pick := OptionButton.new()
	pack_pick.add_theme_font_size_override("font_size", 32)
	for n in names:
		pack_pick.add_item(n)
	pack_pick.item_selected.connect(func(i: int) -> void: game = names[i])
	pack_row.add_child(pack_pick)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	box.add_child(row)

	var label := Label.new()
	label.text = "Teams:"
	label.add_theme_font_size_override("font_size", 32)
	row.add_child(label)

	var spin := SpinBox.new()
	spin.min_value = 1
	spin.max_value = 8
	spin.value = team_count
	spin.get_line_edit().add_theme_font_size_override("font_size", 32)
	spin.value_changed.connect(func(v: float) -> void: team_count = int(v))
	row.add_child(spin)

	var start := Button.new()
	start.text = "Start"
	start.add_theme_font_size_override("font_size", 32)
	start.pressed.connect(_start_game)
	box.add_child(start)

func _show_grid() -> void:
	_clear()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 200)
	margin.add_theme_constant_override("margin_right", 200)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 24)
	margin.add_child(page)

	var grid := GridContainer.new()
	grid.columns = topics.size()
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	page.add_child(grid)

	var scoreboard := HBoxContainer.new()
	scoreboard.add_theme_constant_override("separation", 12)
	page.add_child(scoreboard)
	var group := ButtonGroup.new()
	group.allow_unpress = true
	team_buttons.clear()
	scores.clear()
	for i in team_count:
		scores.append(0)
		var tb := Button.new()
		tb.text = _team_text(i)
		tb.toggle_mode = true
		tb.button_group = group
		tb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tb.custom_minimum_size = Vector2(0, 80)
		tb.add_theme_font_size_override("font_size", 24)
		tb.toggled.connect(func(on: bool) -> void:
			if on:
				active_team = i)
		scoreboard.add_child(tb)
		team_buttons.append(tb)
	active_team = 0
	team_buttons[0].button_pressed = true

	for t in topics:
		var h := Label.new()
		h.text = t
		h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.size_flags_vertical = Control.SIZE_EXPAND_FILL
		h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		h.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		h.add_theme_font_size_override("font_size", 28)
		h.add_theme_color_override("font_color", BlueSkin.GOLD)
		grid.add_child(h)

	for p in points:
		for t in topics:
			var b := Button.new()
			b.text = str(p)
			b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			b.size_flags_vertical = Control.SIZE_EXPAND_FILL
			b.add_theme_font_size_override("font_size", 32)

			b.pressed.connect(_show_question.bind(t, p, b))
			grid.add_child(b)

func _play_drumroll() -> void:
	# Placeholder: replace with real audio and await its finished signal.
	await get_tree().create_timer(2.0).timeout

func _team_text(i: int) -> String:
	return "Team %d\n%d" % [i + 1, scores[i]]

func _on_answer(chosen: Button, correct: bool, answers: Container, overlay: Control, p: int, timer_tween: Tween) -> void:
	timer_tween.kill()
	for b in answers.get_children():
		b.disabled = true
	await _play_drumroll()
	_resolve(chosen, correct, answers, overlay, p)

func _on_timeout(answers: Container, overlay: Control, p: int) -> void:
	for b in answers.get_children():
		b.disabled = true
	_resolve(null, false, answers, overlay, p)

func _paint(b: Button, color: Color) -> void:
	b.add_theme_stylebox_override("disabled", BlueSkin.flat(color))
	b.add_theme_color_override("font_disabled_color", Color.WHITE)

func _resolve(chosen: Button, correct: bool, answers: Container, overlay: Control, p: int) -> void:
	if chosen != null:
		_paint(chosen, BlueSkin.GREEN if correct else BlueSkin.RED)
	if not correct:
		for b in answers.get_children():
			if b.get_meta("correct"):
				_paint(b, BlueSkin.GREEN)
	else:
		scores[active_team] += p
		team_buttons[active_team].text = _team_text(active_team)
	active_team = (active_team + 1) % team_count
	team_buttons[active_team].button_pressed = true

	await get_tree().create_timer(REVEAL_SECONDS).timeout
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, FADE_SECONDS)
	await tween.finished
	overlay.queue_free()

func _show_question(topic: String, p: int, button: Button) -> void:
	var q: Question
	for candidate in game_questions:
		if candidate.topic == topic and candidate.points == p:
			q = candidate
	if q == null:
		return
	button.disabled = true

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(700, 0)
	overlay.add_child(panel)
	var pad := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(pad)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	pad.add_child(box)

	if q.image != null:
		var pic := TextureRect.new()
		pic.texture = q.image
		pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pic.custom_minimum_size = Vector2(0, 300)
		box.add_child(pic)

	var text := Label.new()
	text.text = q.question
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 32)
	box.add_child(text)

	var choices: Array[String] = ["", "", "", ""]
	choices[randi() % 4] = q.answer
	var answers := GridContainer.new()
	answers.columns = 2
	answers.add_theme_constant_override("h_separation", 8)
	answers.add_theme_constant_override("v_separation", 8)
	box.add_child(answers)
	for c in choices:
		var ab := Button.new()
		ab.text = c
		ab.set_meta("correct", c == q.answer)
		ab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ab.custom_minimum_size = Vector2(0, 60)
		ab.add_theme_font_size_override("font_size", 24)
		answers.add_child(ab)

	var bar := ProgressBar.new()
	bar.max_value = QUESTION_SECONDS
	bar.value = QUESTION_SECONDS
	bar.show_percentage = false
	bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bar.offset_bottom = 24
	overlay.add_child(bar)
	var timer_tween := create_tween()
	timer_tween.tween_property(bar, "value", 0.0, QUESTION_SECONDS)
	timer_tween.finished.connect(_on_timeout.bind(answers, overlay, p))
	timer_tween.pause()
	for ab in answers.get_children():
		ab.pressed.connect(_on_answer.bind(ab, ab.get_meta("correct"), answers, overlay, p, timer_tween))
		ab.disabled = true
		ab.modulate.a = 0.0

	var question_parts: Array[Control] = [text]
	if q.image != null:
		question_parts.append(box.get_child(0))
	for part in question_parts:
		part.modulate.a = 0.0
	bar.modulate.a = 0.0
	overlay.modulate.a = 0.0
	_intro(overlay, q.question, question_parts, answers, bar, timer_tween)

func _fade_in(node: CanvasItem) -> void:
	var t := create_tween()
	t.tween_property(node, "modulate:a", 1.0, INTRO_FADE_SECONDS)
	await t.finished

func _read_seconds(text: String) -> float:
	var words := text.split(" ", false).size()
	return maxf(words / READING_WPM * 60.0, ANSWER_STAGGER_SECONDS)

func _intro(overlay: Control, question_text: String, question_parts: Array[Control], answers: Container, bar: Control, timer_tween: Tween) -> void:
	await _fade_in(overlay)
	for part in question_parts:
		_fade_in(part)
	await get_tree().create_timer(INTRO_FADE_SECONDS + _read_seconds(question_text)).timeout
	for ab in answers.get_children():
		_fade_in(ab)
		await get_tree().create_timer(INTRO_FADE_SECONDS + ANSWER_PAUSE_SECONDS + _read_seconds(ab.text)).timeout
	await _fade_in(bar)
	for ab in answers.get_children():
		ab.disabled = false
	timer_tween.play()

