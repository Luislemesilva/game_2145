extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var ammo_bar: ProgressBar = $AmmoBar
@onready var ammo_label: Label = $AmmoLabel

var player: Node = null

func _ready():
	setup_visuals()
	await get_tree().process_frame
	find_player()
	
	if player:
		print("🎯 HUD conectado ao Player!")
		initial_display()

func _process(_delta):
	if player:
		update_display()

func setup_visuals():
	# Configuração das barras
	if health_bar:
		health_bar.min_value = 0
		health_bar.max_value = 100
		health_bar.value = 100
	
	if ammo_bar:
		ammo_bar.min_value = 0
		ammo_bar.max_value = 10
		ammo_bar.value = 10

func find_player():
	# Tenta encontrar por grupo primeiro
	player = get_tree().get_first_node_in_group("player")
	
	# Se não encontrar por grupo, tenta pelo caminho absoluto
	if not player:
		player = get_tree().root.get_node("Game/Player")

func initial_display():
	update_display()

func update_display():
	if not is_instance_valid(player):
		player = null
		return
	
	if not player:
		return
	
	# Atualiza VIDA
	var current_health = player.get_health()
	var max_health = player.get_max_health()
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	var health_percent := int((current_health / float(max_health)) * 100.0)
	health_label.text = str(health_percent) + "%"
	
	# Atualiza MUNIÇÃO - usando ambas as formas de display
	var current_ammo = player.get_ammo()
	var max_ammo = player.get_max_ammo()
	
	# Atualiza barra de munição (se existir)
	if ammo_bar:
		ammo_bar.max_value = max_ammo
		ammo_bar.value = current_ammo
		
		var ammo_percent := int((current_ammo / float(max_ammo)) * 100.0)
		ammo_label.text = "MUNIÇÃO: " + str(ammo_percent) + "%"
	else:
		# Formato alternativo sem barra de munição
		ammo_label.text = "MUNIÇÃO: %d / %d" % [current_ammo, max_ammo]
