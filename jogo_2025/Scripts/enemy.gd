extends CharacterBody2D

const SPEED = 1500.0
const GRAVITY = 980.0

@onready var wall_detector := $wall_detector as RayCast2D
@onready var texture := $texture as Sprite2D
@onready var anim := $anim as AnimationPlayer 

var direction := 1
var player_in_range = false
var is_talking = false

# 🔥 NOVAS VARIÁVEIS PARA DANO
var max_health := 50
var current_health := max_health
var damage_to_player := 10  # Dano que causa quando encosta no player
var can_attack_player := true
var attack_cooldown := 1.0  # Tempo entre ataques

var dialogues = [
	"Olá, aventureiro! Bem-vindo à nossa cidade!",
	"Espero que sua jornada seja repleta de sucessos.",
	"Cuidado com os monstros na floresta ao norte!",
	"Volte sempre que precisar de descanso."
]
var current_dialogue_index = 0

func _ready():
	print("🔧 NPC inicializando...")
	setup_interaction_system()
	print("✅ NPC pronto!")

# 🔥 NOVA FUNÇÃO PARA RECEBER DANO DO PLAYER
func take_damage(amount: int):
	print("🎯 NPC recebeu dano: ", amount)
	current_health -= amount
	current_health = max(0, current_health)
	print("💔 Vida do NPC agora: ", current_health, "/", max_health)
	
	# Toca animação de dano se tiver
	if anim.has_animation("hurt"):
		anim.play("hurt")
	
	if current_health <= 0:
		die()

# 🔥 NOVA FUNÇÃO PARA MORRER
func die():
	print("💀 NPC morreu!")
	
	# Toca animação de morte se tiver
	if anim.has_animation("die"):
		anim.play("die")
		await anim.animation_finished
	
	# Remove o NPC do jogo
	queue_free()

# 🔥 NOVA FUNÇÃO PARA CAUSAR DANO NO PLAYER
func attack_player():
	if not can_attack_player:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("take_damage"):
		print("👊 NPC causando dano no player: ", damage_to_player)
		player.take_damage(damage_to_player)
		
		# Cooldown entre ataques
		can_attack_player = false
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack_player = true

# 🔥 MODIFIQUE a física process para detectar colisão com player
func _physics_process(delta: float) -> void:
	if not is_talking:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		
		if wall_detector.is_colliding():
			direction *= -1
			wall_detector.scale.x *= -1

		if direction == -1:
			texture.flip_h = true
		else:
			texture.flip_h = false
			
		velocity.x = direction * SPEED * delta
	else:
		velocity.x = 0
		velocity.y = 0

	move_and_slide()
	
	# 🔥 VERIFICA SE ENCOSTOU NO PLAYER PARA CAUSAR DANO
	if is_on_floor():
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() and collision.get_collider().is_in_group("player"):
				attack_player()
				break

func setup_interaction_system():
	if not has_node("Area2D"):
		print("⚠️ Criando Area2D...")
		var area = Area2D.new()
		area.name = "Area2D"
		add_child(area)
	
	var detection_area = $Area2D
	
	if not detection_area.has_node("CollisionShape2D"):
		print("⚠️ Criando CollisionShape2D...")
		var collision = CollisionShape2D.new()
		collision.name = "CollisionShape2D"
		
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 80
		collision.shape = circle_shape
		
		detection_area.add_child(collision)
	
	if not detection_area.has_node("InteractionCloud"):
		print("⚠️ Criando nuvem de interação...")
		var cloud = Sprite2D.new()
		cloud.name = "InteractionCloud"
		
		var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		var cloud_texture = ImageTexture.create_from_image(image)
		cloud.texture = cloud_texture
		
		cloud.position = Vector2(0, -80)
		cloud.scale = Vector2(1.5, 1.5)
		cloud.modulate = Color.BLUE
		cloud.visible = false
		
		detection_area.add_child(cloud)
		print("✅ Nuvem criada!")
	
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	
	print("🎯 Sistema de interação configurado!")

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		var cloud = $Area2D/InteractionCloud
		if cloud:
			cloud.visible = true
		print("🎯 Player entrou na área - Nuvem VISÍVEL")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		var cloud = $Area2D/InteractionCloud
		if cloud:
			cloud.visible = false
		print("🎯 Player saiu da área - Nuvem INVISÍVEL")

func _input(event):
	if player_in_range and event.is_action_pressed("interact") and not is_talking:  # ⬅️ Já está como E
		print("🎮 Tecla E pressionada - Iniciando diálogo")
		start_dialogue()
	elif is_talking and event.is_action_pressed("ui_accept"):
		print("🎮 Tecla ESPAÇO pressionada - Próximo diálogo")
		next_dialogue()
	elif is_talking and event.is_action_pressed("ui_cancel"):
		print("🎮 Tecla ESC pressionada - Terminando diálogo")
		end_dialogue()

func start_dialogue():
	print("🎮 CONVERSA INICIADA!")
	is_talking = true
	current_dialogue_index = 0
	
	# ⬅️ Comunica com o player para bloquear inputs
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_in_dialogue"):
		player.set_in_dialogue(true)
	
	var cloud = $Area2D/InteractionCloud
	if cloud:
		cloud.modulate = Color.YELLOW
		cloud.visible = false
	
	show_dialogue(dialogues[0])

func next_dialogue():
	print("▶️ Avançando para próximo diálogo...")
	current_dialogue_index += 1
	
	if current_dialogue_index < dialogues.size():
		show_dialogue(dialogues[current_dialogue_index])
	else:
		end_dialogue()

func show_dialogue(text: String):
	print("💬 NPC: ", text)
	
	var dialogue_ui = get_node("/root/Game/CanvasLayer/HUD")
	
	if dialogue_ui:
		print("✅ UI encontrada: ", dialogue_ui.name)
		
		var dialogue_panel = dialogue_ui.get_node_or_null("DialoguePanel")
		
		if not dialogue_panel:
			print("⚠️ Criando novo DialoguePanel...")
			dialogue_panel = create_dialogue_panel(dialogue_ui)
		else:
			print("✅ DialoguePanel já existe")
		
		var dialogue_text = dialogue_panel.get_node_or_null("DialogueText")
		if not dialogue_text:
			print("⚠️ Criando DialogueText...")
			dialogue_text = create_dialogue_text(dialogue_panel)
		else:
			print("✅ DialogueText já existe")
		
		var press_space = dialogue_panel.get_node_or_null("PressSpace")
		if not press_space:
			print("⚠️ Criando PressSpace...")
			press_space = create_press_space(dialogue_panel)
		else:
			print("✅ PressSpace já exists")
		
		# ⚠️ CORREÇÕES PARA GARANTIR VISIBILIDADE ⚠️
		dialogue_text.text = text
		press_space.text = "Pressione ESPAÇO para continuar"
		
		# Garante que o painel fique na frente
		dialogue_panel.z_index = 100  # Valor alto para ficar na frente
		dialogue_panel.visible = true
		
		# Força uma atualização visual
		dialogue_panel.queue_redraw()
		
		print("✅ Diálogo mostrado: ", text)
		print("✅ Painel visível: ", dialogue_panel.visible)
		print("✅ Z-index: ", dialogue_panel.z_index)
		
	else:
		print("❌ UI não encontrada")
		create_emergency_ui(text)

func create_dialogue_panel(parent: Control) -> Control:
	print("🛠️ Criando DialoguePanel...")
	var panel = ColorRect.new()
	panel.name = "DialoguePanel"
	panel.size = Vector2(600, 120)
	panel.position = Vector2(100, 300)  # ⬅️ Mudei para posição mais central
	panel.color = Color(0, 0, 0, 0.9)   # ⬅️ Preto quase sólido
	panel.z_index = 1000                # ⬅️ Z-index muito alto
	
	# Adiciona uma borda para destacar
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 0.9)
	stylebox.border_color = Color.YELLOW
	stylebox.border_width_left = 4
	stylebox.border_width_right = 4
	stylebox.border_width_top = 4
	stylebox.border_width_bottom = 4
	panel.add_theme_stylebox_override("panel", stylebox)
	
	parent.add_child(panel)
	
	# Move o painel para o final para ficar na frente
	parent.move_child(panel, parent.get_child_count() - 1)
	
	print("✅ DialoguePanel criado na posição: ", panel.position)
	return panel

func create_dialogue_text(parent: Control) -> Label:
	print("🛠️ Criando DialogueText...")
	var label = Label.new()
	label.name = "DialogueText"
	label.position = Vector2(20, 10)
	label.size = Vector2(560, 70)
	label.text = "TESTE - TEXTO VISÍVEL"  # ⬅️ Texto de teste
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_constant_override("line_spacing", 8)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Adiciona contorno ao texto
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	
	parent.add_child(label)
	print("✅ DialogueText criado")
	return label

func create_press_space(parent: Control) -> Label:
	print("🛠️ Criando PressSpace...")
	var label = Label.new()
	label.name = "PressSpace"
	label.position = Vector2(20, 80)
	label.size = Vector2(560, 30)
	label.text = "PRESSIONE ESPAÇO PARA CONTINUAR"  
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	print("✅ PressSpace criado")
	return label

func create_emergency_ui(text: String):
	print("🆘 Criando UI de emergência...")
	var label = Label.new()
	label.name = "EmergencyDialogue"
	label.text = "NPC: " + text
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.RED)  # ⬅️ Vermelho para destacar
	label.position = Vector2(100, 500)
	label.z_index = 1000  # ⬅️ Z-index muito alto
	
	if get_tree().root.has_node("EmergencyDialogue"):
		get_tree().root.get_node("EmergencyDialogue").queue_free()
	
	get_tree().root.add_child(label)
	print("✅ UI de emergência criada")

func end_dialogue():
	print("🎮 CONVERSA ENCERRADA!")
	is_talking = false
	current_dialogue_index = 0
	
	# ⬅️ Comunica com o player para liberar inputs
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_in_dialogue"):
		player.set_in_dialogue(false)
	
	var cloud = $Area2D/InteractionCloud
	if cloud:
		cloud.modulate = Color.BLUE
		cloud.visible = player_in_range
	
	var dialogue_ui = get_node("/root/Game/CanvasLayer/HUD")
	if dialogue_ui:
		var dialogue_panel = dialogue_ui.get_node_or_null("DialoguePanel")
		if dialogue_panel:
			dialogue_panel.visible = false
			print("✅ DialoguePanel escondido")
	
	if get_tree().root.has_node("EmergencyDialogue"):
		get_tree().root.get_node("EmergencyDialogue").queue_free()

# 🔥 CORREÇÃO CRÍTICA: REMOVA ou COMENTE esta função que faz o NPC desaparecer
# func _on_anim_current_animation_changed(anim_name: String) -> void:
#     if anim_name == "Hurt":
#         queue_free()
