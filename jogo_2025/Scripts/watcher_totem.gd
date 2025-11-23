extends Node2D

signal totem_destruido


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

var max_hits_per_stage := 3
var current_hits := 0
var damage_stage := 0

signal totem_destroyed

func _ready():
	anim.play("idle")
	area.monitoring = true
	area.set_deferred("monitorable", true)

	area.area_entered.connect(_on_area_entered)


func _on_area_entered(other_area):
	if not other_area.is_in_group("LethalArea"):
		return

	if other_area.has_method("queue_free"):
		other_area.queue_free()

	_take_hit()


func _take_hit():
	current_hits += 1

	if current_hits < max_hits_per_stage:
		return

	current_hits = 0
	damage_stage += 1

	match damage_stage:
		1:
			anim.play("damage_1")
		2:
			anim.play("damage_2")
		3:
			_break_totem()


func _break_totem():
	anim.play("broken")
	area.set_deferred("monitoring", false)
	area.set_deferred("monitorable", false)
	collision.set_deferred("disabled", true)

	await anim.animation_finished

	emit_signal("totem_destroyed") 
	queue_free()
