extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

const lines: Array[String] = [
	"E aí, Hex. O pessoal ja te recepcionou direitinho, né? Bom… agora e comigo.",
	"O objetivo é simples de falar, dificil de executar: precisamos das Cripto Chaves para reativar o Sistema Eo-Helion e liberar o Projeto Solaris.",
	"Isso abre o reator, isso derruba Magnus, isso salva a cidade.",
	"Sua primeira parada é o Distrito Tóxico, onde fica o laboratório da Dra. Lys. Ela protege a primeira chave.",
	"Vou fazer o possível para te guiar daqui da base.",
	"Fique atento: você vai encontrar capangas da Syndicore e talvez até O Vigia — a IA que controla quase toda a cidade.",
	"Não tente enfrentar tudo. Concentre-se nas chaves.",
	"A prioridade máxima é chegar ate Magnus Veyne com as duas em mãos.",
	"Agora vá. Punchduca e GaMa estão na seção de treino esperando você."
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
