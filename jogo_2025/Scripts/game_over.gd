extends Control


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass




func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/rf_combat.tscn")
 
