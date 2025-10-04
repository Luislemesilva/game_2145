extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 980.0

var is_crouching = false
var is_reloading = false
var can_shoot = true
var is_shooting = false
var direction = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	direction = Input.get_axis("ui_left", "ui_right")
	
	if is_reloading and (direction != 0 or Input.is_action_just_pressed("ui_accept")):
		is_reloading = false
		can_shoot = true
		anim.stop()
	
	if Input.is_action_pressed("ui_down") and is_on_floor() and not is_reloading:
		is_crouching = true
	else:
		is_crouching = false
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching and not is_reloading:
		velocity.y = JUMP_VELOCITY
	
	if not is_reloading:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot") and can_shoot and not is_reloading:
		shoot()
	
	if Input.is_action_just_pressed("reload") and not is_reloading and not is_shooting:
		reload()
	
	if not is_shooting and not is_reloading:
		update_animation()

func update_animation() -> void:
	if not is_on_floor():
		anim.play("jump")
	elif is_crouching:
		anim.play("crouch")
	elif direction != 0:
		anim.flip_h = direction < 0
		anim.play("walk")
	else:
		anim.play("idle")

func shoot() -> void:
	can_shoot = false
	is_shooting = true
	
	var anim_name = "shoot_idle"
	if not is_on_floor():
		anim_name = "shoot_jump"
	elif is_crouching:
		anim_name = "shoot_crouch"
	elif direction != 0:
		anim_name = "shoot_walk"
	
	anim.play(anim_name)
	await get_tree().create_timer(0.5).timeout
	
	can_shoot = true
	is_shooting = false

func reload() -> void:
	is_reloading = true
	can_shoot = false
	
	var anim_name = "reload_idle"
	if is_crouching:
		anim_name = "reload_crouch"
	
	anim.play(anim_name)
	await get_tree().create_timer(1.0).timeout
	
	is_reloading = false
	can_shoot = true
