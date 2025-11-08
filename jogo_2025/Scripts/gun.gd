extends Area2D

const BULLET = preload("res://Entities/Player/Bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D
@onready var player: CharacterBody2D = $".."
@onready var hud = get_tree().get_current_scene().get_node("HUD")


@export var orbit_distance: float = 15.0
@export var max_ammo := 8
@export var reload_time := 3.0

var current_ammo := max_ammo
var can_shoot := true


func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position
	var direction = (mouse_pos - player_pos).normalized()
	if not player or player.status in [player.PlayerState.hurt, player.PlayerState.damage]:
		return
	

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
	if not can_shoot or current_ammo <= 0:
		return
		
	var bullet_instance = BULLET.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	
	current_ammo -= 1
	hud.ammo_animation(current_ammo)
	
	if current_ammo <= 0:
		can_shoot = false
		await get_tree().create_timer(reload_time).timeout
		current_ammo = max_ammo
		can_shoot = true
		hud.update_ammo_display()
	
