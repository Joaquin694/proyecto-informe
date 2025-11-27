extends CharacterBody2D

var vida = 50

@export var speed: float

var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()


func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida del fantasma:", vida)
	if vida <= 0:
		queue_free()
