extends CharacterBody2D

@export var respawn_position: Vector2


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
	status = PlayerState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO
	reload_timer.start()
	
	

func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()
		return
		
func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()
		return
	
func jump_state():
	move()
	
	if Input.is_action_just_pressed("Jump") && jump_count < max_jump_count:
		go_to_jump_state()
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
		
func damage_state():
	pass              # Testa para que o player volta a se mover após o hit com o robo, pois ele fica paralisado no momento 

func hurt_state():
	pass
	
	
func shoot_state():
	pass

func move():
	var mouse_x = get_global_mouse_position().x
	if mouse_x < global_position.x:
		anim.flip_h = true
	elif mouse_x > global_position.x:
		anim.flip_h = false
		
		
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies"):
		hit_enemy(area)
	elif area.is_in_group("LethalArea"):
		hit_lethal_area()
	
func hit_enemy(area: Area2D):
	if velocity.y > 0:
		# Inimigo Morre
		area.get_parent().take_damage() 
	else:
		# Player Morre
		if status != PlayerState.hurt:     
			go_to_hurt_state()   
	
func hit_lethal_area():
	go_to_hurt_state() 

 
func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()    
