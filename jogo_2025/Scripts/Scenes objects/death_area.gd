extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		
		body.take_damage()
		body.can_move = false
		body.velocity = Vector2.ZERO
		
		await get_tree().create_timer(0.5).timeout
		
		body.global_position = body.respawn_position
		
		await get_tree().create_timer(0.3).timeout
		body.can_move = true
