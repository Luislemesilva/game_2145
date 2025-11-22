extends CharacterBody2D

enum RobotState {    
	idle,
	walk,
	attack,
	damage,
	hurt,
	
}

const ROBOT_BULLET = preload("uid://c58eo1q8kdx3m")


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var shoot_start_position: Node2D = $ShootStartPosition


const SPEED = 30.0
const JUMP_VELOCITY = -400.0

@export var max_health := 3
var current_health := max_health

var ja_notificou = false
var status: RobotState

var direction = 1
var can_shoot = true

func _ready() -> void:
	go_to_walk_state()


func _physics_process(delta: float) -> void:


	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		RobotState.idle:
			idle_state(delta)
		RobotState.walk:
			walk_state(delta)
		RobotState.attack:
			attack_state(delta)
		RobotState.damage:
			damage_state(delta)
		RobotState.hurt:
			hurt_state(delta)
		
	move_and_slide()
	
func go_to_idle_state():
	status = RobotState.idle
	anim.play("idle")
	
func go_to_walk_state():
	status = RobotState.walk
	anim.play("walk")
	
func go_to_attack_state():
	status = RobotState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_shoot = true
	
func go_to_damage_state():
	status = RobotState.damage
	anim.play("damage")
	velocity = Vector2.ZERO

	await anim.animation_finished
	if player_detector.is_colliding():
		go_to_attack_state()
	else:
		go_to_walk_state()
	
func go_to_hurt_state():
	status = RobotState.hurt
	anim.play("hurt")
	hitbox.monitoring = false
	hitbox.get_node("CollisionShape2D").disabled = true
	velocity = Vector2.ZERO 
	
	notificar_missao_robo_derrotado()
	
func idle_state(_delta):
	pass
	
func walk_state(_delta):
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
		
	if player_detector.is_colliding():
		go_to_attack_state()
		return
		
func attack_state(_delta):
	if anim.frame == 5 && can_shoot:
		shoot()
		can_shoot = false
	
func damage_state(_delta):
	pass
		
func hurt_state(_delta):
	pass
	
	
	
func take_damage(amount: int = 1) -> void:
	if status == RobotState.hurt or status == RobotState.damage:
		return

	current_health -= amount

	if current_health > 0:
		go_to_damage_state()
	else:
		go_to_hurt_state()


func shoot():
	var new_shoot = ROBOT_BULLET.instantiate()
	add_sibling(new_shoot)
	new_shoot.position = shoot_start_position.global_position
	new_shoot.set_direction(self.direction)

func notificar_missao_robo_derrotado():
	if ja_notificou:
		return
	
	ja_notificou = true
	

	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		if player.has_method("derrotar_robo"):
			player.derrotar_robo()
			print("🤖 Robô notificou o sistema de missões!")


func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
	elif anim.animation == "hurt":

		notificar_missao_robo_derrotado()
		queue_free()
