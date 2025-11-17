extends Area2D

const BULLET = preload("res://Entities/Player/Bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D
@onready var owner_node := get_parent()

@onready var hud := get_tree().get_current_scene().get_node_or_null("HUD")

@export var orbit_distance: float = 15.0
@export var max_ammo := 8
@export var reload_time := 1.5

var current_ammo := max_ammo
var can_shoot := true

var is_player := false


func _ready():
	if owner_node.is_in_group("Player"):
		is_player = true
	else:
		is_player = false


func _process(delta):
	if is_player:
		process_player_weapon(delta)
	else:
		process_enemy_weapon(delta)
	
	scale.x = sign(get_parent().scale.x)


func process_player_weapon(_delta):

	if owner_node.status in [owner_node.PlayerState.hurt, owner_node.PlayerState.damage]:
		return

	var mouse_pos = get_global_mouse_position()
	var player_pos = owner_node.global_position

	var dir = (mouse_pos - player_pos).normalized()
	global_position = player_pos + dir * orbit_distance

	look_at(mouse_pos)

	var angle = rad_to_deg(player_pos.angle_to_point(mouse_pos))
	scale.y = -1 if abs(angle) > 90 else 1

	if Input.is_action_just_pressed("Shoot"):
		shoot()


func process_enemy_weapon(_delta):
	var offset := Vector2(6, 3) 
	offset.x *= owner_node.scale.x
	position = offset
	scale.x = owner_node.scale.x



func shoot():
	if not can_shoot or current_ammo <= 0:
		return

	var bullet = BULLET.instantiate()
	get_tree().root.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.rotation = rotation

	current_ammo -= 1
	if hud:
		hud.ammo_animation(current_ammo)

	if current_ammo <= 0:
		can_shoot = false
		await get_tree().create_timer(reload_time).timeout
		current_ammo = max_ammo
		can_shoot = true
		if hud:
			hud.update_ammo_display()
