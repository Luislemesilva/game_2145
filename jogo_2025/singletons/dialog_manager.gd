extends Node

@onready var dialog_box_scene = preload("res://Entities/dialog_box.tscn")

var message_lines: Array[String] = []
var current_line := 0

var dialog_box
var dialog_box_position := Vector2.ZERO
var is_message_active := false
var can_advance_message := false


func start_message(position: Vector2, lines: Array[String]):
	if is_message_active:
		return

	message_lines = lines
	dialog_box_position = position
	current_line = 0

	is_message_active = true
	show_text()


func show_text():
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_display_finished.connect(_on_all_text_displayed)

	get_tree().current_scene.add_child(dialog_box)
	dialog_box.position = dialog_box_position + Vector2(0, -50)


	dialog_box.display_text(message_lines[current_line])
	can_advance_message = false


func _on_all_text_displayed():
	can_advance_message = true


func advance_message():
	if not is_message_active:
		return
	
	if not can_advance_message:
		return

	dialog_box.queue_free()
	current_line += 1

	if current_line >= message_lines.size():
		is_message_active = false
		current_line = 0
		return

	show_text()


func _unhandled_input(event):
	if event.is_action_pressed("Interact"):
		advance_message()
