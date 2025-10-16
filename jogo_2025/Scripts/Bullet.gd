# Bullet.gd - VERSÃO PIXEL ART CORRIGIDA
extends Area2D

var speed = 400
var direction = Vector2.RIGHT
var damage := 25

@onready var sprite = $Sprite2D  # 🔥 Use a sprite que já existe na cena

func _ready():
	# 🔥 REMOVA a criação da sprite no código e use a que já existe
	configure_existing_sprite()
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4
	collision.shape = shape
	add_child(collision)
	
	# 🔥 CONECTAR SINAIS DE COLISÃO
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Timer para auto-destruição
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()
	
	# Adicionar partículas de rastro
	add_trail_particles()
	
	# Debug
	print("🔫 Bala criada - Sprite configurada:", sprite != null)

func _physics_process(delta):
	global_position += direction * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction
	# 🔥 Girar a sprite na direção do tiro
	if sprite:
		sprite.rotation = direction.angle()
	print("🎯 Direção da bala alterada para:", direction)

# 🔥 USE A SPRITE EXISTENTE EM VEZ DE CRIAR NOVA
func configure_existing_sprite():
	if sprite:
		sprite.texture = create_pixel_art_texture()
		sprite.centered = true
		sprite.scale = Vector2(2, 2)  # 🔥 Aumenta o tamanho para ficar visível
		print("🎨 Sprite existente configurada!")
	else:
		print("❌ Sprite2D não encontrada na cena!")

func create_pixel_art_texture() -> ImageTexture:
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	
	# Padrão de bala estilo pixel art
	var pixels = [
		[0,0,1,1,1,1,0,0],
		[0,1,2,2,2,2,1,0],
		[1,2,3,3,3,3,2,1],
		[1,2,3,4,4,3,2,1],
		[1,2,3,4,4,3,2,1],
		[1,2,3,3,3,3,2,1],
		[0,1,2,2,2,2,1,0],
		[0,0,1,1,1,1,0,0]
	]
	
	var colors = {
		0: Color.TRANSPARENT,
		1: Color(0.3, 0.1, 0.1),
		2: Color(0.8, 0.2, 0.1),
		3: Color(1.0, 0.6, 0.2),
		4: Color(1.0, 0.9, 0.3)
	}
	
	for x in range(8):
		for y in range(8):
			var color_index = pixels[y][x]
			image.set_pixel(x, y, colors[color_index])
	
	return ImageTexture.create_from_image(image)

# 🔥 FUNÇÕES DE COLISÃO
func _on_body_entered(body):
	print("💥 Bala colidiu com: ", body.name)
	if body.has_method("take_damage"):
		print("🎯 Acertou inimigo! Causando dano: ", damage)
		body.take_damage(damage)
	queue_free()

func _on_area_entered(area):
	print("💥 Bala colidiu com área: ", area.name)
	queue_free()

func add_trail_particles():
	var particles = GPUParticles2D.new()
	particles.process_material = ParticleProcessMaterial.new()
	particles.one_shot = false
	particles.explosiveness = 0
	particles.lifetime = 0.3
	particles.amount = 8
	
	var material = particles.process_material
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.spread = 45
	material.gravity = Vector3(0, 0, 0)
	material.initial_velocity_min = 10
	material.initial_velocity_max = 30
	material.linear_accel_min = -50
	material.linear_accel_max = -30
	material.color = Color(1, 0.5, 0.2)
	material.color_ramp = create_color_ramp()
	
	particles.position = Vector2.ZERO
	add_child(particles)

func create_color_ramp() -> Gradient:
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 0.3, 1))
	gradient.set_color(1, Color(1, 0.3, 0.1, 0))
	return gradient
