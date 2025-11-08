extends CharacterBody2D

@export var respawn_position: Vector2
@export var max_health := 3
var current_health := max_health

enum PlayerState {     
	idle,
	walk,
	jump,
	damage,
	hurt,
}

const BULLET = preload("uid://dp6iuxs40fxwy")

@onready var anim: AnimatedSprite2D = $Anim
@onready var collision: CollisionShape2D = $Collision
@onready var reload_timer: Timer = $ReloadTimer

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var jump_count = 0
@export var max_jump_count = 2

var status: PlayerState

func _ready() -> void:
	respawn_position = global_position
	add_to_group("Player")
	go_to_idle_state()



func take_damage(amount: int = 1) -> void:
	if status == PlayerState.damage or status == PlayerState.hurt:
		return 

	current_health -= amount
	current_health = clamp(current_health, 0, max_health)

	
	var hud_node = get_tree().get_current_scene().get_node_or_null("HUD")
	if hud_node:
		hud_node.update_hearts(current_health)
		if current_health < max_health:
			hud_node.damage_animation(current_health)  

	if current_health <= 0:
		die()
		return

	
	status = PlayerState.damage
	anim.play("damage")
	velocity = Vector2.ZERO

	await anim.animation_finished


	if is_on_floor():
		if abs(velocity.x) > 0:
			go_to_walk_state()
		else:
			go_to_idle_state()
	else:
		go_to_jump_state()


func die():
	status = PlayerState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO

	
	var hud_node = get_tree().get_current_scene().get_node_or_null("HUD")
	if hud_node:
		hud_node.update_hearts(0)

	await anim.animation_finished
	reload_timer.start()


func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()



func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.damage:
			damage_state()
		PlayerState.hurt:
			hurt_state()

	move_and_slide()


func go_to_damage_state():
	status = PlayerState.damage
	anim.play("damage")
	velocity = Vector2.ZERO        
	await anim.animation_finished
	if Input.get_axis("Left", "Right") == 0:
		go_to_idle_state()
	else:
		go_to_walk_state()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_hurt_state():
	if status == PlayerState.hurt:
		return
	status = PlayerState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO
	reload_timer.start()



func idle_state():
	move()
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()
	if velocity.x != 0:
		go_to_walk_state()

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()

func jump_state():
	move()
	if Input.is_action_just_pressed("Jump") and jump_count < max_jump_count:
		go_to_jump_state()
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()

func damage_state():
	pass          

func hurt_state():
	pass

func shoot_state():
	pass



func move():
	var mouse_x = get_global_mouse_position().x
	if mouse_x < global_position.x:
		$Anim.scale.x = -1  
	else:
		$Anim.scale.x = 1

	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)



func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") or area.is_in_group("EnemyBullets"):
		take_damage()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage() 
	else:
		if status != PlayerState.hurt:
			go_to_hurt_state()   

func hit_lethal_area():
	go_to_hurt_state()
