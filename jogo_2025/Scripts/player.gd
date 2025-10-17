extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $Anim

const SPEED = 200.0
const JUMP_FORCE = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if is_on_floor():
		if direction > 0:
			anim.flip_h = false
			anim.play("walk")
		elif direction < 0:
			anim.flip_h = true
			anim.play("walk")
		else:
			anim.play("idle")
			
	else:
		anim.play("jump")
	
	move_and_slide()
