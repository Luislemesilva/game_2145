extends Area2D

const BULLET = preload("res://Entities/Player/Bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D
@onready var player: CharacterBody2D = $".."

@export var orbit_distance: float = 15.0

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position
	var direction = (mouse_pos - player_pos).normalized()
	

	global_position = player_pos + direction * orbit_distance

	look_at(mouse_pos)
	
	var angle = rad_to_deg(player_pos.angle_to_point(mouse_pos))
	

	if abs(angle) > 90:
		scale.y = -1  
	else:
		scale.y = 1   
	
	
	if Input.is_action_just_pressed("Shoot"):
		shoot()


func shoot():
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
