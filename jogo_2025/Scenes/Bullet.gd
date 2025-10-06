# Bullet.gd - VERSÃO CORRIGIDA
extends Area2D

var speed = 400
var direction = Vector2.RIGHT

func _ready():
	# Cria uma sprite visual (círculo vermelho)
	var sprite = Sprite2D.new()
	var texture = ImageTexture.create_from_image(create_circle_texture(8, Color.RED))
	sprite.texture = texture
	add_child(sprite)
	
	# Collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4
	collision.shape = shape
	add_child(collision)
	
	# Timer para auto-destruição
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()
	
	# Debug
	print("🔫 Bala criada - Direção:", direction)

func _physics_process(delta):
	# USA global_position PARA MOVIMENTO CORRETO
	global_position += direction * speed * delta
	
	# Debug opcional (cuidado: vai gerar muitas mensagens)
	#print("Posição da bala:", global_position)

func set_direction(new_direction: Vector2):
	direction = new_direction
	print("🎯 Direção da bala alterada para:", direction)

# Função para criar textura de círculo
func create_circle_texture(radius: int, color: Color) -> Image:
	var image = Image.create(radius * 2, radius * 2, false, Image.FORMAT_RGBA8)
	for x in range(radius * 2):
		for y in range(radius * 2):
			var dx = x - radius
			var dy = y - radius
			if dx * dx + dy * dy <= radius * radius:
				image.set_pixel(x, y, color)
	return image
