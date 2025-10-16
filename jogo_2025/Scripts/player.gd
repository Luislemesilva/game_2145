extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 980.0

var max_health := 100
var current_health := max_health
var current_ammo = 10
var max_ammo = 10
var is_in_dialogue = false 

var is_crouching = false
var is_reloading = false
var can_shoot = true
var is_shooting = false
var direction = 0.0

var use_mouse_aim := true
var shoot_direction = Vector2.RIGHT

@export var bullet_scene: PackedScene

func _ready():
	add_to_group("player")
	print("🔥 Player inicializado!")
	print("   Vida: ", current_health, "/", max_health)
	print("   Munição: ", current_ammo, "/", max_ammo)

func set_in_dialogue(value: bool):
	is_in_dialogue = value

func _physics_process(delta: float) -> void:
	# ⬅️ SE estiver em diálogo, não processa movimento
	if is_in_dialogue:
		velocity.x = 0  # Para movimento horizontal
		velocity.y = 0  # Para pulo/gravidade
		move_and_slide()
		return
	
	# ⬅️ Seu código normal de movimento continua aqui...
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	direction = Input.get_axis("ui_left", "ui_right")
	
	update_aim_direction()
	
	if is_reloading and direction != 0:
		cancel_reload()
	
	is_crouching = Input.is_action_pressed("ui_down") and is_on_floor() and not is_reloading
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching and not is_reloading:
		velocity.y = JUMP_VELOCITY
	
	if not is_reloading:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("Shoot") and can_shoot and not is_reloading and current_ammo > 0:
		shoot()
	
	if Input.is_action_just_pressed("Reload") and not is_reloading and current_ammo < max_ammo:
		reload()
	
	if not is_shooting and not is_reloading:
		update_animation()

func _input(event):
	# ⬅️ SE estiver em diálogo, ignora TODOS os inputs
	if is_in_dialogue:
		return
	
	# SISTEMA DE TESTE CORRIGIDO
	# TESTE - Tecla Tab para DANO (afeta VIDA)
	if event.is_action_pressed("ui_focus_next"):  # Tecla Tab
		print("========================================")
		print("🎮 TECLA TAB - APLICANDO DANO NA VIDA!")
		print("========================================")
		take_damage(15)
	
	# TESTE - Tecla F para ATIRAR (afeta MUNIÇÃO) - CORRIGIDO
	if event.is_action_pressed("Shoot") and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):  # Tecla F
		print("========================================")
		print("🎮 TECLA F - GASTANDO MUNIÇÃO!")
		print("========================================")
		if current_ammo > 0:
			current_ammo -= 1
			print("🔫 Munição gasta! Agora: ", current_ammo, "/", max_ammo)
		else:
			print("💢 Sem munição!")
	
	# TESTE - Tecla Shift+Tab para CURAR (afeta VIDA)
	if event.is_action_pressed("ui_focus_prev"):  # Tecla Shift+Tab
		print("========================================")
		print("🎮 SHIFT+TAB - CURANDO VIDA!")
		print("========================================")
		heal(20)
	
	# TESTE - Tecla Escape para STATUS
	if event.is_action_pressed("ui_cancel"):  # Tecla Escape
		print("📊 STATUS ATUAL:")
		print("   Vida: ", current_health, "/", max_health)
		print("   Munição: ", current_ammo, "/", max_ammo)

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

func update_aim_direction() -> void:
	if use_mouse_aim:
		var mouse_pos = get_global_mouse_position()
		shoot_direction = (mouse_pos - global_position).normalized()
	else:
		if direction != 0:
			shoot_direction = Vector2(direction, 0).normalized()

func shoot() -> void:
	update_aim_direction()
	
	can_shoot = false
	is_shooting = true
	current_ammo -= 1  # Isso já está CORRETO - gasta munição
	
	if bullet_scene:
		create_bullet()
	
	var anim_name = "shoot_idle"
	if not is_on_floor():
		anim_name = "shoot_jump"
	elif is_crouching:
		anim_name = "shoot_crouch"
	elif direction != 0:
		anim_name = "shoot_walk"
	
	anim.play(anim_name)
	await get_tree().create_timer(0.3).timeout
	
	is_shooting = false
	can_shoot = true
	
	if current_ammo <= 0:
		reload()

func create_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	
	# 🔥 CORREÇÃO: Spawn da bala mais à frente do player
	var spawn_offset = Vector2(20, 0)  # 20 pixels à frente
	if anim.flip_h:  # Se estiver virado para esquerda
		spawn_offset.x = -20  # Spawn à esquerda
	
	bullet.global_position = global_position + spawn_offset
	
	if bullet.has_method("set_direction"):
		bullet.set_direction(shoot_direction)
	
	print("🎯 Bala spawn em: ", bullet.global_position)

func reload() -> void:
	is_reloading = true
	can_shoot = false
	
	var anim_name = "reload_idle"
	if is_crouching:
		anim_name = "reload_crouch"
	
	anim.play(anim_name)
	await get_tree().create_timer(1.5).timeout
	
	if is_reloading:
		current_ammo = max_ammo
		is_reloading = false
		can_shoot = true

func cancel_reload() -> void:
	is_reloading = false
	can_shoot = true
	anim.stop()

func take_damage(amount: int):
	print("🎯 APLICANDO DANO NA VIDA: ", amount)
	current_health -= amount
	current_health = max(0, current_health)
	print("💔 Vida agora: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func heal(amount: int):
	print("🎯 APLICANDO CURA NA VIDA: ", amount)
	current_health = min(current_health + amount, max_health)
	print("❤️ Vida agora: ", current_health, "/", max_health)

func die():
	print("💀 Player morreu! Reiniciando cena...")
	get_tree().reload_current_scene()

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_ammo() -> int:
	return current_ammo

func get_max_ammo() -> int:
	return max_ammo
