extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100

func _process(delta: float) -> void:
	position += transform.x * SPEED  * delta





func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()


func _on_self_destruction_timeout() -> void:
	queue_free()
