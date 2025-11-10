extends CharacterBody2D

@export var human_duration := 3.0       
@export var max_health := 20
var current_health := max_health
var is_monster := false
var is_transforming := false
var is_dead := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_human: Area2D = $Hitboxes/HitboxHuman
@onready var hitbox_monster: Area2D = $Hitboxes/HitboxMonster
@onready var fade: ColorRect = $ScreenFade
@onready var attack_timer: Timer = $Timer_Attack
@onready var float_marker: Marker2D = $FloatPosition

var float_speed := 2.0
var float_height := 15.0
var float_timer := 0.0
var float_origin_y := 0.0
var fade_node : ColorRect = null

func _ready() -> void:
	current_health = max_health
	is_monster = false
	is_transforming = false
	is_dead = false
	
	hitbox_human.monitoring = true
	hitbox_monster.monitoring = false
	hitbox_monster.visible = false
	
	fade.color.a = 0.0
	anim.play("idle_human")
	
	await get_tree().create_timer(human_duration).timeout
	_start_transformation()

func _start_transformation() -> void:
	if is_transforming or is_dead:
		return
	is_transforming = true

	fade.visible = true
	fade.color = Color(0, 0, 0, 0)
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	await tween.finished

	await get_tree().create_timer(2.0).timeout 

	
	hitbox_human.monitoring = false
	hitbox_human.monitorable = false
	hitbox_human.visible = false

	hitbox_monster.monitoring = true
	hitbox_monster.monitorable = true
	hitbox_monster.visible = true
	
	if float_marker:
		global_position = float_marker.global_position
		float_origin_y = global_position.y

	anim.play("idle_monster")
	is_monster = true

	var tween2 := create_tween()
	tween2.tween_property(fade, "modulate:a", 0.0, 1.0)
	await tween2.finished

	is_transforming = false

	attack_timer.wait_time = 3.0
	attack_timer.start()

func _physics_process(delta: float) -> void:
	if is_monster and not is_transforming and not is_dead:
		_float_motion(delta)

func _float_motion(delta: float) -> void:
	float_timer += delta * float_speed
	position.y = float_origin_y + sin(float_timer) * float_height

func take_damage(amount: int = 1) -> void:
	if is_transforming or not is_monster or is_dead:
		return

	current_health -= amount
	if current_health < 0:
		current_health = 0

	# efeito visual de dano
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if "damage" in anim.sprite_frames.get_animation_names():
		anim.play("damage")
		await anim.animation_finished
		anim.play("idle_monster")  
	else:
		anim.play("idle_monster")  

	if current_health <= 0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	attack_timer.stop()

	if "death" in anim.sprite_frames.get_animation_names():
		anim.play("death")
	await anim.animation_finished

	queue_free()

func _on_Timer_Attack_timeout() -> void:
	if not is_monster or is_transforming or is_dead:
		return
	anim.play("attack")
	await anim.animation_finished
	anim.play("idle_monster")
	


func _on_hitbox_monster_area_entered(area: Area2D) -> void:
		if area.is_in_group("LethalArea"):
			take_damage(1)
		if area.has_method("queue_free"):
			area.queue_free()
