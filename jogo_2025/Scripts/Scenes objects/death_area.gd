extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.global_position = body.respawn_position
		body.velocity = Vector2.ZERO


func _on_timer_timeout() -> void:
	pass # Replace with function body.
