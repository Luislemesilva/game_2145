extends CharacterBody2D


enum LysState {
	idle_human,
	idle_monster,
	transforming,
	attack,
	damage,
	dead
}

var state := LysState.idle_human



@export var human_duration := 3.0
@export var max_health := 1
var current_health := max_health

var is_monster := false
var gravity := 300.0
var fall_speed := 0.0
var on_ground := false


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



func _ready() -> void:
	current_health = max_health

	fade.color.a = 0.0
	anim.play("idle_human")
	state = LysState.idle_human


	hitbox_human.monitoring = true
	hitbox_monster.monitoring = false
	hitbox_monster.visible = false


	await get_tree().create_timer(human_duration).timeout
	_start_transformation()




func _start_transformation():
	if state == LysState.dead:
		return

	state = LysState.transforming


	fade.visible = true
	fade.color.a = 0
	var tween = create_tween()
	tween.tween_property(fade, "color:a", 1.0, 0.5)
	await tween.finished

	await get_tree().create_timer(2.0).timeout


	hitbox_human.monitoring = false
	hitbox_human.visible = false
	hitbox_monster.monitoring = true
	hitbox_monster.visible = true


	if float_marker:
		global_position = float_marker.global_position
		float_origin_y = global_position.y

	anim.play("idle_monster")
	is_monster = true

	var tween2 = create_tween()
	tween2.tween_property(fade, "modulate:a", 0.0, 1.0)
	await tween2.finished

	state = LysState.idle_monster

	attack_timer.start()



func _physics_process(delta: float) -> void:

	match state:

		LysState.dead:
			_apply_gravity(delta)

		LysState.idle_monster:
			_float_motion(delta)

		LysState.attack:
			_float_motion(delta)



func _float_motion(delta: float) -> void:
	float_timer += delta * float_speed
	position.y = float_origin_y + sin(float_timer) * float_height



func _apply_gravity(delta: float) -> void:
	if on_ground:
		return

	fall_speed += gravity * delta
	position.y += fall_speed * delta

	if position.y >= -140:
		position.y = -140
		on_ground = true
		_play_death_animation()




# DANO

func take_damage(amount: int = 1) -> void:
	if state in [LysState.transforming, LysState.dead, LysState.idle_human]:
		return

	current_health -= amount


	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE


	if "damage" in anim.sprite_frames.get_animation_names():
		state = LysState.damage
		anim.play("damage")
		await anim.animation_finished

	if current_health <= 0:
		_die()
		return


	state = LysState.idle_monster
	anim.play("idle_monster")




# MORTE

func _die() -> void:
	state = LysState.dead
	attack_timer.stop()

	float_speed = 0
	float_height = 0

	fall_speed = 0
	on_ground = false




#ANIMAÇÃO DE MORTE

func _play_death_animation() -> void:
	if "death" in anim.sprite_frames.get_animation_names():
		anim.play("death")
		await anim.animation_finished

	queue_free()



#  ATAQUE

func _on_Timer_Attack_timeout() -> void:
	if state != LysState.idle_monster:
		return

	state = LysState.attack
	anim.play("attack")
	await anim.animation_finished

	anim.play("idle_monster")
	state = LysState.idle_monster




#HITBOX DA POÇÃO / TIRO

func _on_hitbox_monster_area_entered(area: Area2D) -> void:
	if area.is_in_group("LethalArea"):
		take_damage(1)

	if area.has_method("queue_free"):
		area.queue_free()
