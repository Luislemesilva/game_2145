extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

const lines: Array[String] = [
	"Olha só quem voltou dos mortos. Nosso ex-funcionário preferido do Magnus Veyne! Chega mais, Hex.",
	"O LuIQ já te entregou a pistola, então vamos ao básico: mire e atire nos robôs. ",
	"Três tiros e eles vão pro ferro-velho. Não precisa economizar munição",
	"A gente arrumou um jeito de recarregar automaticamente."
]

func _unhandled_input(event):
	if area_2d.get_overlapping_bodies().size() > 0:
		
		texture.show()

		if event.is_action_pressed("Interact") and not DialogManager.is_message_active:
			texture.hide()
			DialogManager.start_message(global_position, lines)

		elif event.is_action_pressed("Interact") and DialogManager.is_message_active:
			DialogManager.advance_message()

	else:
		texture.hide()
