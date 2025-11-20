extends CharacterBody2D

@export var respawn_position: Vector2
@export var max_health := 3
var current_health := max_health


enum PlayerState {     
	idle,
	walk,
	jump,
	damage,
	hurt,
}

const BULLET = preload("uid://dp6iuxs40fxwy")

@onready var anim: AnimatedSprite2D = $Anim
@onready var collision: CollisionShape2D = $Collision
@onready var reload_timer: Timer = $ReloadTimer

const SPEED = 200.0
const JUMP_VELOCITY = -300.0
var jump_count = 0
var can_move := true
@export var max_jump_count = 2
var sistema_verificado = false

var npcs_conversados := []
var robos_derrotados := 0
var missao_treinamento_ativa := false
var npcs_detectados := {}

var status: PlayerState

func _ready() -> void:
	respawn_position = global_position
	add_to_group("Player")
	go_to_idle_state()

	
	if not sistema_verificado:
		sistema_verificado = true
		await get_tree().create_timer(1.0).timeout
		verificar_sistema_missoes()

	
	await get_tree().create_timer(3.0).timeout
	iniciar_missao_treinamento()


		
func take_damage(amount: int = 1) -> void:
	if status == PlayerState.damage or status == PlayerState.hurt:
		return 

	current_health -= amount
	current_health = clamp(current_health, 0, max_health)

	
	var hud_node = get_tree().get_current_scene().get_node_or_null("HUD")
	if hud_node:
		hud_node.update_hearts(current_health)
		if current_health < max_health:
			hud_node.damage_animation(current_health)  

	if current_health <= 0:
		die()
		return

	
	status = PlayerState.damage
	anim.play("damage")
	velocity = Vector2.ZERO

	await anim.animation_finished


	if is_on_floor():
		if abs(velocity.x) > 0:
			go_to_walk_state()
		else:
			go_to_idle_state()
	else:
		go_to_jump_state()


func die():
	status = PlayerState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO

	
	var hud_node = get_tree().get_current_scene().get_node_or_null("HUD")
	if hud_node:
		hud_node.update_hearts(0)

	await anim.animation_finished
	reload_timer.start()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()



func _physics_process(delta: float) -> void:
	detectar_npcs_proximos()
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.damage:
			damage_state()
		PlayerState.hurt:
			hurt_state()

	move_and_slide()

func detectar_npcs_proximos():
	if not missao_treinamento_ativa:
		return
	
	# Detecta NPCs por nome
	var punchduka = get_tree().get_nodes_in_group("Punchduka")
	var lan = get_tree().get_nodes_in_group("Lan")
	var dr_v = get_tree().get_nodes_in_group("DrV")
	
	# Verifica proximidade
	if punchduka.size() > 0 and punchduka[0].global_position.distance_to(global_position) < 100:
		conversar_com_npc("Punchduka")
	
	if lan.size() > 0 and lan[0].global_position.distance_to(global_position) < 100:
		conversar_com_npc("Lan")
		
	if dr_v.size() > 0 and dr_v[0].global_position.distance_to(global_position) < 100:
		conversar_com_npc("Dr. V")
func go_to_damage_state():
	status = PlayerState.damage
	anim.play("damage")
	velocity = Vector2.ZERO        
	await anim.animation_finished
	if Input.get_axis("Left", "Right") == 0:
		go_to_idle_state()
	else:
		go_to_walk_state()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_hurt_state():
	if status == PlayerState.hurt:
		return
	status = PlayerState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO
	reload_timer.start()

func idle_state():
	move()
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()
	if velocity.x != 0:
		go_to_walk_state()

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()

func jump_state():
	move()
	if Input.is_action_just_pressed("Jump") and jump_count < max_jump_count:
		go_to_jump_state()
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()

func damage_state():
	pass          

func hurt_state():
	pass

func shoot_state():
	pass



func move():
	var mouse_x = get_global_mouse_position().x
	if mouse_x < global_position.x:
		$Anim.scale.x = -1  
	else:
		$Anim.scale.x = 1

	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)



func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemies") or area.is_in_group("LethalArea"):
		take_damage()

func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage() 
	else:
		if status != PlayerState.hurt:
			go_to_hurt_state()    

func hit_lethal_area():
	go_to_hurt_state()
	
func verificar_sistema_missoes():
	print(" INICIANDO verificação do sistema...")
	var sistema = encontrar_sistema_missao()
	if sistema:
		print(" Sistema encontrado, verificando missões...")
		
	else:
		print(" Sistema não encontrado")

func encontrar_sistema_missao():
	print(" Buscando SistemaMissao...")
	
	var sistema
	

	sistema = get_node("/root/SistemaMissao")
	if sistema:
		print(" Encontrado em /root/SistemaMissao")
		return sistema
	
	
	if get_parent():
		sistema = get_parent().get_node("SistemaMissao")
		if sistema:
			print(" Encontrado como filho do parent")
			return sistema
	
	
	sistema = get_tree().get_first_node_in_group("SistemaMissao")
	if sistema:
		print(" Encontrado no grupo SistemaMissao")
		return sistema
	
	print(" Nodes disponíveis no root:")
	for node in get_tree().get_root().get_children():
		print("   - ", node.name)
	
	print(" SistemaMissao não encontrado")
	print(" Adicione o nó SistemaMissao na cena principal")
	return null

func mostrar_missoes_ativas():
	var sistema = encontrar_sistema_missao()
	if sistema and sistema.missoes_ativas.size() > 0:
		print("=== MISSÕES ATIVAS ===")
		for missao in sistema.missoes_ativas:
			print(" ", missao["nome"])
	else:
		print("Nenhuma missão ativa no momento")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:  
				mostrar_missoes_ativas()
			
			KEY_1:
				print(" TESTE: Conversando com Punchduka...")
				conversar_com_npc("Punchduka")
			KEY_2:
				print(" TESTE: Conversando com Lan...")
				conversar_com_npc("Lan")
			KEY_3:
				print(" TESTE: Conversando com Dr. V...")
				conversar_com_npc("Dr. V")
			KEY_4:
				print(" TESTE: Derrotando robô...")
				derrotar_robo()
			
			KEY_5:
				print(" TESTE: Reiniciando missão de treinamento...")
				iniciar_missao_treinamento()
			
func iniciar_missao_treinamento():
	missao_treinamento_ativa = true
	npcs_conversados.clear()
	robos_derrotados = 0
	npcs_detectados = {
		"Punchduka": false,
		"Lan": false, 
		"Dr. V": false
	}
	
	var sistema = encontrar_sistema_missao()
	if sistema:
		sistema.iniciar_missao("Treinamento na base")
		print("🎯 Missão de treinamento iniciada!")
		print("   Objetivos:")
		print("   - Falar com Punchduka (Combate)")
		print("   - Falar com Lan (Hacking)") 
		print("   - Falar com Dr. V (Cura)")
		print("   - Derrotar 1 robô de treinamento")


func detectar_npc_proximo(nome_npc: String):
	if not missao_treinamento_ativa:
		return
	
	if nome_npc in ["Punchduka", "Lan", "Dr. V"] and not npcs_detectados[nome_npc]:
		npcs_detectados[nome_npc] = true
		conversar_com_npc(nome_npc)

func conversar_com_npc(nome_npc: String):
	if not missao_treinamento_ativa:
		return
	
	if nome_npc in ["Punchduka", "Lan", "Dr. V"]:
		if nome_npc not in npcs_conversados:
			npcs_conversados.append(nome_npc)
			print(" Conversou com: " + nome_npc)
			verificar_progresso_treinamento()

func derrotar_robo():
	if not missao_treinamento_ativa:
		return
	
	robos_derrotados += 1
	print(" Robôs derrotados: " + str(robos_derrotados))
	verificar_progresso_treinamento()

func verificar_progresso_treinamento():
	if not missao_treinamento_ativa:
		return
	
	var sistema = encontrar_sistema_missao()
	if not sistema:
		return
	
	print("🔍 Verificando progresso da missão...")
	print("   NPCs conversados: " + str(npcs_conversados.size()) + "/3")
	print("   Robôs derrotados: " + str(robos_derrotados) + "/1")
	
	if "Punchduka" in npcs_conversados:
		sistema.completar_objetivo("Treinamento na base", 0)  # Combate
		print(" Objetivo 0 completado: Punchduka")
	
	if "Lan" in npcs_conversados:
		sistema.completar_objetivo("Treinamento na base", 1)  # Hacking
		print(" Objetivo 1 completado: Lan")
	
	if "Dr. V" in npcs_conversados:
		sistema.completar_objetivo("Treinamento na base", 2)  # Cura
		print(" Objetivo 2 completado: Dr. V")
	
	if robos_derrotados >= 1:
		sistema.completar_objetivo("Treinamento na base", 3)  # Robô
		print(" Objetivo 3 completado: Robô")
