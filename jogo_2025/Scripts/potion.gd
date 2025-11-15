extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var speed := 90.0
@export var rotation_speed := 6.0

var lifetime := 2.5 
var life_timer := 0.0
var target: Node2D = null
var is_breaking := false


func _ready():
	anim.play("spin") 
	find_player()


func find_player():
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0]


func _physics_process(delta):
	if is_breaking:
		return
		
	life_timer += delta
	if life_timer >= lifetime:
		break_potion()
		return
		
	if target == null:
		return

	var dir = (target.global_position - global_position).normalized()
	global_position += dir * speed * delta
	rotation = lerp_angle(rotation, dir.angle(), rotation_speed * delta)



func _on_area_entered(_area):
	break_potion()


func _on_body_entered(_body):
	break_potion()


func break_potion():
	if is_breaking:
		return

	is_breaking = true
	speed = 0

	anim.play("break")
	await anim.animation_finished

	queue_free()
	
