extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

const lines: Array[String] = [
	"Hex! Que bom ver você em carne, osso e coragem. Eu sou o Dr. V.",
	"Voce já sabe como a cidade está…",
	"A elite vive acima das nuvens, respirando ar puro, enquanto o resto da população enfrenta favelas tecnológicas e toxinas no ar.",
	"Magnus vende a doença e também a cura. Talvez isso seja o mais cruel de tudo.",
	"Preste atencao: você nao é indestrutivel. Tomou dano demais, missão encerrada.",
	"As nuvens tóxicas drenam sua vida em segundos. Então, evite-as sempre que puder.",
	"Para ajudar, espalhei meus Packs de Cura por Neo Kairosaka.",
	"Se estiver a beira da morte, procure um. Eles podem te salvar.",
	"A Lan te espera ali na frente — ela vai te explicar sua primeira missão."
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
