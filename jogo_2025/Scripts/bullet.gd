extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100

func _process(delta: float) -> void:
	position += transform.x * SPEED  * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		# sobe um nível para encontrar o dono (Boss)
		var boss = area.get_parent()
		if boss and boss.has_method("take_damage"):
			boss.take_damage(1)
		queue_free()
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		body.take_damage(1)
	queue_free()



func _on_self_destruction_timeout() -> void:
	queue_free()
