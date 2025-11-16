extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

const lines: Array[String] = [
	"Aí está você! Eu sou o Punchduca: músculo, coração e dor de cabeça da Syndicore desde os quinze anos.",
	"O LuIQ também te deu as botas de pulo duplo.",
	"Usa isso ao seu favor: reposiciona, pega ângulos melhores, sobe plataformas",
	"Mobilidade vai te salvar mais do que mira perfeita.",
	"Agora mostra pra gente do que você é feito."
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
