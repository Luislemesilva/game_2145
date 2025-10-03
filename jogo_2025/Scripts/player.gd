extends CharacterBody2D
@onready var animated: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)



	if is_on_floor():
		
		if direction > 0:
			animated.flip_h = false
			animated.play('Running')
		elif direction < 0:
			animated.flip_h = true
			animated.play("Running")
		else:
			animated.play("Idle")
	else:
		animated.play("Jump")


	move_and_slide()
