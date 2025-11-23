extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_: Area2D = $Area2D



var pode_levar_dano := false      
var tiros_para_proxima_fase := 5  
var tiros_atual := 0
var fase := 0                      
var destruido := false

const TOTAL_TOTENS := 4
var totens_destruidos := 0



func _ready():
	area_.area_entered.connect(_on_area_entered)
	anim.play("idle")
	_conectar_totens()
	
func _conectar_totens():
	var pasta_totens = get_parent().get_node("WatcherTotens")

	for totem in pasta_totens.get_children():
		if totem.has_signal("totem_destroyed"):
			totem.connect("totem_destroyed", Callable(self, "registrar_toten_destruido"))


func registrar_toten_destruido():
	totens_destruidos += 1
	print("Totens destruídos:", totens_destruidos, "/", TOTAL_TOTENS)

	if totens_destruidos >= TOTAL_TOTENS:
		pode_levar_dano = true



func _on_area_entered(other_area):
	if not other_area.is_in_group("LethalArea"):
		return

	if other_area.has_method("queue_free"):
		other_area.queue_free()

	take_hit()



func take_hit():
	if destruido:
		return


	
	if not pode_levar_dano:
		return 
	tiros_atual += 1

	if tiros_atual < tiros_para_proxima_fase:
		return

	
	tiros_atual = 0
	fase += 1

	match fase:
		1:
			anim.play("damage_1")  
		2:
			anim.play("damage_2") 
		3:
			death()
		_:
			pass



func death():
	destruido = true

	if "death" in anim.sprite_frames.get_animation_names():
		anim.play("death")
		await anim.animation_finished

	queue_free()
