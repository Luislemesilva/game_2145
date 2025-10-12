extends CharacterBody2D

var move_speed := 50.0
var direction := 1
var health_points := 3

@onready var sprite = $sprite
@onready var anim = $anim
@onready var colision = $colision
@onready var bullet_spwn_point = $bullet_spawn_point
@onready var ground_detector = $ground_detector
@onready var player_detector = $player_detector


func _ready():
	pass 


func _physics_process(delta):
	
	
	if is_on_wall():
		direction *= -1
		sprite.scale.x *= -1
		player_detector.scale.x *= -1
		colision.scale.x *= -1
			
	if !ground_detector.is_colliding():
		direction *= -1
		sprite.scale.x *= -1
		player_detector.scale.x *= -1
		colision.scale.x *= -1
	

	
		
	velocity.x  = move_speed * direction
	move_and_slide()
