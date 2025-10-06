extends CharacterBody2D
# REMOVA o preload e deixe apenas isso:
@export var bullet_scene: PackedScene

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const GRAVITY = 980.0

var is_crouching = false
var is_reloading = false
var can_shoot = true
var is_shooting = false
var direction = 0.0
var shoot_direction = Vector2.RIGHT

func _ready():
	if bullet_scene == null:
		print("ℹ️  Atribua a Bullet Scene no Inspector")

# O resto do seu código continua igual...
