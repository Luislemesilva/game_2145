extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var ammo_label: Label = $AmmoLabel

var player: Node = null

func _ready():
	await get_tree().process_frame
	player = get_tree().root.get_node("Game/Player")
	if player:
		print("HUD conectado ao Player!")
		update_display()

func _process(_delta):
	if player:
		update_display()

func update_display():
	if not player:
		return
	
	# Atualiza valores da vida
	health_bar.max_value = player.get_max_health()
	health_bar.value = player.get_health()
	
	var percent := int((player.get_health() / float(player.get_max_health())) * 100.0)
	health_label.text = str(percent) + "%"
	
	# Atualiza munição
	ammo_label.text = "MUNIÇÃO: %d / %d" % [player.get_ammo(), player.get_max_ammo()]
