extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

const lines: Array[String] = [
	"Hex! Finalmente. Eu sou o LuIQ e, em nome da Rede Fantasma, seja muito bem-vindo.",
	"Sua experiência como ex-técnico da Syndicore e, principalmente, sua coragem… Nós vamos precisar de tudo isso.",
	"A Syndicore está apertando o cerco. Para salvar Neo Kairosaka, precisamos ativar o Projeto Solaris.",
	"A única fonte de energia limpa capaz de quebrar o monopólio de Magnus Veyne.",
	"Mas o desgraçado trancou o reator atrás de Cripto Chaves",
	"Seu objetivo é recuperá-las. Mas antes disso, você precisa treinar.",
	"Pegamos alguns robôs do Distrito da Vigilância. Demos uma reprogramada, mas… Eles ainda sabem machucar.",
	"O Dr. V está logo ali. Ele vai te preparar para o que te espera lá fora."
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
