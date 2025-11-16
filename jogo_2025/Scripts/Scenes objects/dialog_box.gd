extends MarginContainer

@onready var text_label: Label = $Label_margin/Text_label
@onready var letter_timer_display: Timer = $Letter_timer_display

const MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_display_timer := 0.02
var space_display_timer := 0.05
var punctuaction_display_timer := 0.02

signal text_display_finished()

func display_text(text_to_display: String):
	text = text_to_display
	text_label.text = text_to_display

	await resized

	custom_minimum_size.x = min(size.x, MAX_WIDTH)

	if size.x > MAX_WIDTH:
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		custom_minimum_size.y = size.y

	var final_size = size
	global_position.x -= final_size.x / 2
	global_position.y -= final_size.y + 24


	text_label.text = ""
	letter_index = 0
	display_letter()

func display_letter():

	if letter_index >= text.length():
		text_display_finished.emit()
		return

	text_label.text += text[letter_index]
	letter_index += 1

	if letter_index >= text.length():
		text_display_finished.emit()
		return

	match text[letter_index]:
		"!", "?", ",", ".":
			letter_timer_display.start(punctuaction_display_timer)
		" ":
			letter_timer_display.start(space_display_timer)
		_:
			letter_timer_display.start(letter_display_timer)

func _on_letter_timer_display_timeout() -> void:
	display_letter()
