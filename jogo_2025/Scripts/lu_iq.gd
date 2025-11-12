extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

const lines : Array[String] = [
	"Chupa minha caceta!"
]

func _unhandled_input(event):
	if area_2d.get_overlapping_bodies().size() > 0:
		texture.show()
		if event.is_action_pressed("Interact") && !DialogManager.is_message_active:
			texture.hide()
			DialogManager.start_message(global_position,lines)
		else:
			texture.hide()
			if DialogManager.dialog_box != null:
				DialogManager.dialog_box.queue_free()
				DialogManager.is_message_active = false
				
				
				
