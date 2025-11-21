extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return

	var hud = get_tree().get_current_scene().get_node_or_null("HUD")

	if body.current_health < body.max_health:
		body.current_health += 1
		if hud:
			hud.current_health = body.current_health
			hud.update_hearts(hud.current_health)

	anim.play("get")
	await anim.animation_finished

	queue_free()
