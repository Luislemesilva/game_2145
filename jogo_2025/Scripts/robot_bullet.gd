extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


var speed = 60
var direction = 1

func _process(delta: float) -> void:
	position.x += speed * delta * direction
	
func set_direction(robot_direction):
	direction = robot_direction
	anim.flip_h = direction < 0 


func _on_self_destruction_time_timeout() -> void:
	queue_free()


	queue_free()
	

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.hit_lethal_area()
	
