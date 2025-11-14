extends CanvasLayer

@onready var hearts = [
	$HeartsContainer/Heart1,
	$HeartsContainer/Heart2,
	$HeartsContainer/Heart3
]

@onready var bullets = [
	$BulletsContainer/Bullet1,
	$BulletsContainer/Bullet2,
	$BulletsContainer/Bullet3,
	$BulletsContainer/Bullet4,
	$BulletsContainer/Bullet5,
	$BulletsContainer/Bullet6,
	$BulletsContainer/Bullet7,
	$BulletsContainer/Bullet8
]

var max_health := 3
var current_health := 3

var max_ammo := 8
var current_ammo := 8


func update_hearts(new_health: int) -> void:
	for i in range(hearts.size()):
		if i < new_health:
			hearts[i].visible = true
			hearts[i].play("idle")
		else:
			if hearts[i].animation != "break" and hearts[i].visible:
				damage_animation(i)


func damage_animation(index: int):
	if index >= 0 and index < hearts.size():
		hearts[index].play("break")
		await hearts[index].animation_finished
		hearts[index].visible = false


func update_ammo_display():
	for i in range(bullets.size()):
		if i < current_ammo:
			bullets[i].play("idle")
		else:
			bullets[i].play("empty")


func ammo_animation(index: int):
	if index >= 0 and index < bullets.size():
		bullets[index].play("break")
		await bullets[index].animation_finished
		bullets[index].play("empty")
