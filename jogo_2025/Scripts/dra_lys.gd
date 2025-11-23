extends Node2D

@onready var texture: Sprite2D = $Texture
@onready var area_2d: Area2D = $Area2D

var dialog_enabled := true

const lines: Array[String] = [
	"Ora, ora. O rato da Rede Fantasma finalmente saiu do bueiro. Hex! Pensei que o medo dos meus 'gases' teria te mantido escondido.",
	"Você quer salvar a cidade? Você quer restaurar Neo Kairosaka? Mas quem vai comprar a cura se não houver a doença? Eu crio o veneno, Hex. E vendo o antídoto!.",
	"Você não vai estragar o meu ciclo de lucro! Magnus me deu o Distrito Tóxico e eu vou te dar a minha maior criação!."
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
	area_2d.hide()
	area_2d.monitoring = false
	area_2d.set_deferred("monitorable", false)
