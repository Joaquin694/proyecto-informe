extends CharacterBody2D

var vida_max = 50
var vida = vida_max
var ha_recibido_daño = false
@export var speed: float
var player
@onready var anim = $AnimatedSprite2D
@onready var barra_vida: ProgressBar = $BarraVida

func _ready():
	player = get_tree().get_first_node_in_group("player")
	anim.play("quieto")
	
	# Verificar que la barra existe
	if barra_vida:
		barra_vida.max_value = vida_max
		barra_vida.value = vida
		barra_vida.visible = false
	else:
		print("ERROR: No se encontró el nodo BarraVida en Fantasma")

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
	
	if not ha_recibido_daño and barra_vida:
		ha_recibido_daño = true
		barra_vida.visible = true
	
	if barra_vida:
		barra_vida.value = vida
	
	if vida <= 0:
		queue_free()
