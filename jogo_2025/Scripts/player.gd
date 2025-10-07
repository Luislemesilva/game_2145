extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var use_mouse_aim := true 

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 980.0

var is_crouching = false
var is_reloading = false
var can_shoot = true
var is_shooting = false
var direction = 0.0
var shoot_direction = Vector2.RIGHT

func _ready():
	if bullet_scene == null:
		print("ℹ️  Atribua a Bullet Scene no Inspector")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	direction = Input.get_axis("Left", "Right")
	
	if is_reloading and (direction != 0 or Input.is_action_just_pressed("ui_accept")):
		is_reloading = false
		can_shoot = true
		anim.stop()
	
	if Input.is_action_pressed("Crouch") and is_on_floor() and not is_reloading:
		is_crouching = true
	else:
		is_crouching = false
	
	if Input.is_action_just_pressed("Jump") and is_on_floor() and not is_crouching and not is_reloading:
		velocity.y = JUMP_VELOCITY
	
	if not is_reloading:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	update_aim_direction()
	
	if Input.is_action_just_pressed("Shoot") and can_shoot and not is_reloading:
		shoot()
	
	if Input.is_action_just_pressed("Reload") and not is_reloading and not is_shooting:
		reload()
	
	if not is_shooting and not is_reloading:
		update_animation()


func update_aim_direction():
	if use_mouse_aim:
		var mouse_pos = get_global_mouse_position()
		shoot_direction = (mouse_pos - global_position).normalized()
		anim.flip_h = mouse_pos.x < global_position.x
	else:
		var aim_x = Input.get_axis("aim_left", "aim_right")
		var aim_y = Input.get_axis("aim_up", "aim_down")
		
		if aim_x != 0 or aim_y != 0:
			shoot_direction = Vector2(aim_x, aim_y).normalized()
		elif direction != 0:
			shoot_direction = Vector2(direction, 0)
		
		if shoot_direction.x != 0:
			anim.flip_h = shoot_direction.x < 0


func update_animation() -> void:
	if not is_on_floor():
		anim.play("jump")
	elif is_crouching:
		anim.play("crouch")
	elif direction != 0:
		anim.play("walk")
	else:
		anim.play("idle")


func shoot() -> void:
	if bullet_scene == null:
		print("❌ ERRO: Bullet Scene não atribuída!")
		return
	
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

	var bullet = bullet_scene.instantiate()
	if bullet:
		var offset = Vector2(20, 0)
		if anim.flip_h:
			offset.x = -20
		
		bullet.global_position = global_position + offset

		if bullet.has_method("set_direction"):
			bullet.set_direction(shoot_direction)
		else:
			bullet.direction = shoot_direction

		print("🎯 Atirando na direção:", shoot_direction)
		get_parent().add_child(bullet)

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
