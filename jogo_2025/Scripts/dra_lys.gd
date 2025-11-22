extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

var dialog_enabled := true
var area := true

const lines: Array[String] = [
	"Olha só quem voltou dos mortos.",
	"O LuIQ já te entregou a pistola."
]

func _ready():
	var dm = get_node("/root/DialogManager")
	dm.dialog_finished.connect(_on_dialog_finished)


func _unhandled_input(event):
	if not dialog_enabled:
		return
		
	if area_2d.get_overlapping_bodies().size() > 0:
		
		texture.show()

		if event.is_action_pressed("Interact") and not DialogManager.is_message_active:
			texture.hide()
			DialogManager.start_message(global_position, lines)

		elif event.is_action_pressed("Interact") and DialogManager.is_message_active:
			DialogManager.advance_message()

	else:
		texture.hide()


func _on_dialog_finished():
	disable_dialog()
	disable_collision()


	var lys = get_parent() 
	if lys.has_method("_start_transformation"):
		await get_tree().create_timer(2.0).timeout
		lys._start_transformation()


func disable_dialog():
	dialog_enabled = false
	texture.hide()
	area_2d.monitoring = false
	area_2d.set_deferred("monitorable", false)
	

func disable_collision():
	area = false
	area_2d.hide()
	area_2d.monitoring = false
	area_2d.set_deferred("monitorable", false)
	
	
