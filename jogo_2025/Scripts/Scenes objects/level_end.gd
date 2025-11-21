extends Area2D
@export var next_level = ""

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.max_health += 1
		body.current_health = body.max_health

		var hud = get_tree().get_current_scene().get_node_or_null("HUD")
		if hud:
			hud.max_health = body.max_health
			hud.current_health = hud.max_health
			hud.update_hearts(hud.current_health)

		call_deferred("load_next_scene")


func load_next_scene():
	get_tree().change_scene_to_file("res://Scenes/" + next_level + ".tscn")
