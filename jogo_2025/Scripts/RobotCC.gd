extends CharacterBody2D

enum RobotState {    
	idle,
	walk,
	attack,
	damage,
	hurt
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var attack_area: Area2D = $AttackArea

const SPEED = 30.0
const JUMP_VELOCITY = -400.0
const ATTACK_DAMAGE = 10

var status: RobotState
var direction = 1
var can_attack = true
var player_in_attack_range = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	# Inicia no estado walk e já começa a se mover
	go_to_walk_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

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
	velocity.x = 0  # Para de se mover
	
func go_to_walk_state():
	status = RobotState.walk
	anim.play("walk")
	# Já define a velocidade para começar a se mover
	velocity.x = SPEED * direction
	
func go_to_attack_state():
	status = RobotState.attack
	anim.play("attack")
	velocity = Vector2.ZERO  # Para completamente durante o ataque
	can_attack = true
	
func go_to_damage_state():
	status = RobotState.damage
	anim.play("damage") 
	
func go_to_hurt_state():
	status = RobotState.hurt
	anim.play("hurt")
	if hitbox:
		hitbox.process_mode = Node.PROCESS_MODE_DISABLED 
	velocity = Vector2.ZERO  
	
func idle_state(_delta):
	# Se detectar jogador, vai para ataque
	if player_in_attack_range:
		go_to_attack_state()
	
func walk_state(_delta):
	# Mantém a velocidade de movimento
	velocity.x = SPEED * direction
	
	# Detecção de paredes e bordas
	if wall_detector.is_colliding():
		flip_direction()
		
	if not ground_detector.is_colliding():
		flip_direction()
		
	# Verifica se o jogador está no alcance de ataque
	if player_in_attack_range:
		go_to_attack_state()
		return
		
func attack_state(_delta):
	# Para o robô durante o ataque
	velocity.x = 0
	
	# Verifica em qual frame da animação aplicar o dano
	if anim.frame >= 3 && can_attack:
		apply_melee_damage()
		can_attack = false
	
func damage_state(_delta):
	pass
		
func hurt_state(_delta):
	pass

func flip_direction():
	scale.x *= -1
	direction *= -1
	update_attack_area_position()
	# Atualiza a velocidade imediatamente após virar
	if status == RobotState.walk:
		velocity.x = SPEED * direction

func update_attack_area_position():
	# Move a área de ataque para a frente do robô quando ele virar
	if attack_area:
		attack_area.position.x = abs(attack_area.position.x) * direction

func apply_melee_damage():
	if not attack_area:
		return
		
	# Verifica se há corpos na área de ataque
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		# Verifica se é o jogador
		if body.name == "Player" or body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(ATTACK_DAMAGE)
				print("Robô corpo a corpo causou ", ATTACK_DAMAGE, " de dano!")
			# Se o jogador tiver método diferente
			elif body.has_method("hit"):
				body.hit(ATTACK_DAMAGE)
				print("Robô corpo a corpo causou ", ATTACK_DAMAGE, " de dano!")

func _on_attack_area_body_entered(body):
	# Verifica se é o jogador
	if body.name == "Player" or body.is_in_group("player"):
		player_in_attack_range = true
		print("Jogador entrou na área de ataque corpo a corpo")

func _on_attack_area_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_attack_range = false
		print("Jogador saiu da área de ataque corpo a corpo")
	
func take_damage():             
	print("Robô corpo a corpo recebeu dano!")
	go_to_hurt_state()

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		# Só volta a andar se o jogador não estiver mais no alcance
		if not player_in_attack_range:
			go_to_walk_state()
		else:
			# Se o jogador ainda está no alcance, continua atacando
			go_to_attack_state()
	elif anim.animation == "hurt":
		queue_free()
