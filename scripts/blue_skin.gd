class_name BlueSkin

const BG := Color("0e1633")
const BLUE := Color("2a3f8f")
const BLUE_LIGHT := Color("3b52a3")
const BLUE_DARK := Color("18234f")
const GOLD := Color("9fb8e8")
const GREEN := Color("3d8f5f")
const RED := Color("a14a4a")

const ANSWER_PAD := 64

static func flat(fill: Color, border: Color = Color.WHITE, h_pad := 16) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = fill
	s.border_color = border
	s.set_border_width_all(3)
	s.set_corner_radius_all(10)
	s.content_margin_left = h_pad
	s.content_margin_right = h_pad
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

static func build() -> Theme:
	var t := Theme.new()

	t.set_stylebox("normal", "Button", flat(BLUE))
	t.set_stylebox("hover", "Button", flat(BLUE_LIGHT, GOLD))
	t.set_stylebox("pressed", "Button", flat(GOLD, Color.WHITE))
	t.set_stylebox("hover_pressed", "Button", flat(GOLD, Color.WHITE))
	t.set_stylebox("disabled", "Button", flat(BLUE_DARK, Color("34437a")))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_color("font_color", "Button", Color.WHITE)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", BG)
	t.set_color("font_hover_pressed_color", "Button", BG)
	t.set_color("font_disabled_color", "Button", Color("7f8bb5"))

	t.set_color("font_color", "Label", Color.WHITE)

	# Answer buttons reserve side room for the A/B/C/D letter.
	t.set_type_variation("AnswerButton", "Button")
	t.set_stylebox("normal", "AnswerButton", flat(BLUE, Color.WHITE, ANSWER_PAD))
	t.set_stylebox("hover", "AnswerButton", flat(BLUE_LIGHT, GOLD, ANSWER_PAD))
	t.set_stylebox("pressed", "AnswerButton", flat(GOLD, Color.WHITE, ANSWER_PAD))
	t.set_stylebox("hover_pressed", "AnswerButton", flat(GOLD, Color.WHITE, ANSWER_PAD))
	t.set_stylebox("disabled", "AnswerButton", flat(BLUE_DARK, Color("34437a"), ANSWER_PAD))

	var panel := flat(BLUE_DARK, GOLD)
	panel.set_border_width_all(4)
	t.set_stylebox("panel", "PanelContainer", panel)

	var bar_bg := flat(BG, Color.WHITE)
	bar_bg.set_border_width_all(2)
	var bar_fill := flat(GOLD, GOLD)
	bar_fill.set_border_width_all(0)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	t.set_stylebox("fill", "ProgressBar", bar_fill)

	return t
