extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100
var direction = 1

func _process(delta: float) -> void:
	position.x += SPEED * delta * direction
	
func set_direction(bullet_direction):
	direction = bullet_direction
	anim.flip_h = direction < 0 


func _on_self_destruction_time_timeout() -> void:
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
