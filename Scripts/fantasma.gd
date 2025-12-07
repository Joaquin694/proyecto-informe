extends CharacterBody2D

var vida = 50
@export var speed: float

var player
@onready var anim = $AnimatedSprite2D
@onready var barra_vida: TextureProgressBar = $BarraVida

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim.play("quieto")

	# Configurar barra
	barra_vida.max_value = vida
	barra_vida.value = vida

func _physics_process(delta):
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# Animaciones
	if abs(velocity.x) > 10:
		if velocity.x > 0:
			anim.play("derecha")
		else:
			anim.play("izquierda")
	else:
		anim.play("quieto")

func recibir_daño(cantidad):
	vida -= cantidad
	barra_vida.value = vida

	if vida <= 0:
		queue_free()
