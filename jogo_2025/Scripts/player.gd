extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Constantes
const SPEED = 50.0
const JUMP_VELOCITY = -200.0
const GRAVITY = 980.0

# Sistema de vida e munição
var max_health := 100
var current_health := max_health
var current_ammo = 10
var max_ammo = 10

# Estados do jogador
var is_crouching = false
var is_reloading = false
var can_shoot = true
var is_shooting = false
var direction = 0.0

# Sistema de mira
var use_mouse_aim := true
var shoot_direction = Vector2.RIGHT

# Referência para a cena da bala (configure no Inspector)
@export var bullet_scene: PackedScene

func _ready():
	print("🎮 PLAYER INICIADO - Aguardando comandos")

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement()
	handle_actions()
	handle_animations()

func handle_gravity(delta: float) -> void:
	# Aplicar gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func handle_movement() -> void:
	# Obter direção do teclado
	direction = Input.get_axis("ui_left", "ui_right")
	
	# Cancelar recarga se o jogador se mover
	if is_reloading and direction != 0:
		cancel_reload()
	
	# Verificar se está agachando
	is_crouching = Input.is_action_pressed("ui_down") and is_on_floor() and not is_reloading
	
	# Pular
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not is_crouching and not is_reloading:
		velocity.y = JUMP_VELOCITY
	
	# Movimento horizontal (bloqueado durante recarga)
	if not is_reloading:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func handle_actions() -> void:
	# Atualizar direção da mira
	update_aim_direction()
	
	# DEBUG - Mostrar quando botões são pressionados
	if Input.is_action_just_pressed("Shoot"):
		print("🔫 BOTÃO DE TIRO PRESSIONADO")
		print("   - Munição atual:", current_ammo)
		print("   - Pode atirar:", can_shoot)
		print("   - Recarregando:", is_reloading)
	
	if Input.is_action_just_pressed("Reload"):
		print("🔄 BOTÃO DE RECARGA PRESSIONADO")
	
	# Atirar
	if Input.is_action_just_pressed("Shoot") and can_shoot and not is_reloading and current_ammo > 0:
		shoot()
	
	# Recarregar
	if Input.is_action_just_pressed("Reload") and not is_reloading and current_ammo < max_ammo:
		reload()
	
	# Teste do sistema de vida (teclas 1 e 2)
	if Input.is_key_pressed(KEY_1):
		take_damage(10)
	if Input.is_key_pressed(KEY_2):
		heal(10)

func handle_animations() -> void:
	# Só atualizar animação base se não estiver atirando ou recarregando
	if not is_shooting and not is_reloading:
		update_base_animation()

func update_base_animation() -> void:
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
		# Mira com mouse - direção do mouse em relação ao player
		var mouse_pos = get_global_mouse_position()
		shoot_direction = (mouse_pos - global_position).normalized()
	else:
		# Mira com teclado - direção do movimento
		if direction != 0:
			shoot_direction = Vector2(direction, 0).normalized()

func shoot() -> void:
	print("🎯 INICIANDO TIRO")
	can_shoot = false
	is_shooting = true
	current_ammo -= 1
	
	# Criar bala se a cena estiver configurada
	if bullet_scene:
		create_bullet()
	else:
		print("   ⚠️  Cena da bala não configurada")
	
	# Animação de tiro baseada no estado
	var anim_name = "shoot_idle"
	if not is_on_floor():
		anim_name = "shoot_jump"
	elif is_crouching:
		anim_name = "shoot_crouch"
	elif direction != 0:
		anim_name = "shoot_walk"
	
	anim.play(anim_name)
	print("   - Animação:", anim_name)
	
	# Tempo de recarga entre tiros
	await get_tree().create_timer(0.3).timeout
	
	is_shooting = false
	can_shoot = true
	print("💥 TIRO CONCLUÍDO - Munição restante:", current_ammo)
	
	# Recarga automática se a munição acabar
	if current_ammo <= 0:
		print("🔁 Munição zerada - recarregando automaticamente")
		reload()

func create_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	
	# Adicionar a bala na cena principal (não como filha do player)
	get_parent().add_child(bullet)
	
	# Posicionar a bala na posição do player
	bullet.global_position = global_position
	
	# Definir direção da bala
	if bullet.has_method("set_direction"):
		bullet.set_direction(shoot_direction)
		print("   - Bala criada com direção:", shoot_direction)
	else:
		print("   ⚠️  Bala não tem método set_direction")

func reload() -> void:
	print("🔄 INICIANDO RECARGA")
	is_reloading = true
	can_shoot = false
	
	# Animação de recarga
	var anim_name = "reload_idle"
	if is_crouching:
		anim_name = "reload_crouch"
	
	anim.play(anim_name)
	print("   - Animação:", anim_name)
	
	# Tempo de recarga
	await get_tree().create_timer(1.5).timeout
	
	# Recarregar munição (só se ainda estiver recarregando)
	if is_reloading:
		current_ammo = max_ammo
		is_reloading = false
		can_shoot = true
		print("✅ RECARGA COMPLETA - Munição:", current_ammo)

func cancel_reload() -> void:
	print("❌ RECARGA CANCELADA - Jogador se moveu")
	is_reloading = false
	can_shoot = true
	anim.stop()

# ========================
# SISTEMA DE VIDA
# ========================

func take_damage(amount: int) -> void:
	current_health -= amount
	current_health = max(0, current_health)
	print("❤️  Dano recebido - Vida:", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("💚 Cura recebida - Vida:", current_health, "/", max_health)

func die() -> void:
	print("💀 PLAYER MORREU!")
	get_tree().reload_current_scene()

# ========================
# FUNÇÕES PARA O HUD
# ========================

func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_ammo() -> int:
	return current_ammo

func get_max_ammo() -> int:
	return max_ammo
