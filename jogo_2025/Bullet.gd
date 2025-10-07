extends Area2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO

func set_direction(dir: Vector2):
	direction = dir.normalized()

func _process(delta):
	position += direction * speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
