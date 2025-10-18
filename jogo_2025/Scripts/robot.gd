extends CharacterBody2D

enum RobotState {     #Maquina de Estado do Robo
	idle,
	walk,
	shoot,
	damage,
	
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector


const SPEED = 30.0
const JUMP_VELOCITY = -400.0


var status: RobotState

var direction = 1

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
		RobotState.shoot:
			shoot_state(delta)
		
	move_and_slide()
	
func go_to_idle_state():
	status = RobotState.idle
	anim.play("idle")
	
func go_to_walk_state():
	status = RobotState.walk
	anim.play("walk")
	
func go_to_shoot_state():
	status = RobotState.shoot
	anim.play("shoot")
	
func go_to_damage_state():
	status = RobotState.damage
	anim.play("shoot") #Mudar animação para sprite de hurt assim que inserido, colocado apenas para teste se funciona
	hitbox.process_mode = Node. PROCESS_MODE_DISABLED #Depois que o inimigo é derrotado, o hitbox é desabilitado, se ele fizer animação de atirar, é o que seria para ser o damage e ao ficar parado, é a certezaa de que ele esta morto .
	
	velocity = Vector2.ZERO  
	
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
		
		
	
func shoot_state(_delta):
	pass
	
func damage_state(_delta):
	pass
	
func hurt():             # Hurt = Death    Damage = Dano    # Desabilitar colisão depois que morrer, não aplicada ainda
	go_to_damage_state() # Invertido a função pois como ainda não sabemos se teremos um death, colocamos um dano até a morte do robo e ele sumiur





















	
