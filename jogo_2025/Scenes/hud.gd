extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var ammo_label: Label = $AmmoLabel

var player: Node

func _ready():
	# Esperar um pouco para encontrar o player
	await get_tree().process_frame
	player = get_parent().get_parent().get_node("Player")
	if player:
		print("HUD conectado ao Player!")
		update_display()

func _process(_delta):
	if player:
		update_display()

func update_display():
	if not player:
		return
	
	# Vida
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
	
	var health_percent = int((float(player.current_health) / float(player.max_health)) * 100)
	health_label.text = str(health_percent) + "%"
	
	# Munição
	ammo_label.text = "MUNIÇÃO: %d / %d" % [player.current_ammo, player.max_ammo]
