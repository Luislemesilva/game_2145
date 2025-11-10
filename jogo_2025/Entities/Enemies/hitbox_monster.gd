extends Area2D



func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("LethalArea"): 
		var boss = get_parent().get_parent()  
		if boss and boss.has_method("take_damage"):
			boss.take_damage(1)
		queue_free()  
