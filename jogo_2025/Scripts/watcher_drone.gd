extends CharacterBody2D

enum DroneState {    
	idle,
	walk,
	attack,
	hurt, 
}

const ROBOT_BULLET = preload("uid://c58eo1q8kdx3m")

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var celling_detector: RayCast2D = $CellingDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var shoot_start_position: Node2D = $ShootStartPosition

const SPEED = 30.0

@export var max_health := 1
var current_health := max_health

var status: DroneState
var direction = 1
var can_shoot = true


func _ready() -> void:
	go_to_walk_state()


func _physics_process(delta: float) -> void:

	# Drone no teto = sem gravidade
	velocity = Vector2.ZERO

	match status:
		DroneState.idle:
			idle_state(delta)
		DroneState.walk:
			walk_state(delta)
		DroneState.attack:
			attack_state(delta)
		DroneState.hurt:
			hurt_state(delta)

	move_and_slide()


func go_to_idle_state():
	status = DroneState.idle
	anim.play("idle")
	
func go_to_walk_state():
	status = DroneState.walk
	anim.play("walk")
	can_shoot = true
	
func go_to_attack_state():
	status = DroneState.attack
	anim.play("attack")
	can_shoot = true
	
func go_to_hurt_state():
	status = DroneState.hurt
	anim.play("hurt")
	hitbox.monitoring = false
	hitbox.get_node("CollisionShape2D").disabled = true


func idle_state(_delta):
	pass
	

func walk_state(_delta):
	velocity.x = SPEED * direction
	
	# Se o teto acabar, vira
	if not celling_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	# Se detectar jogador → ataca
	if player_detector.is_colliding():
		go_to_attack_state()


func attack_state(_delta):
	# frame 5 é o tiro
	if anim.frame == 4 and can_shoot:
		shoot()
		can_shoot = false


func hurt_state(_delta):
	pass
	

# Drone morre na primeira vez que levar dano
func take_damage(amount: int = 1) -> void:
	if status == DroneState.hurt:
		return
	
	go_to_hurt_state()


func shoot():
	var new_shoot = ROBOT_BULLET.instantiate()
	add_sibling(new_shoot)
	new_shoot.position = shoot_start_position.global_position
	new_shoot.set_direction(self.direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
	elif anim.animation == "hurt":
		queue_free()
