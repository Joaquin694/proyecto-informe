extends CharacterBody2D

var speed = 400.0
var vida_max = 100
var vida = vida_max

var barra_vida  # referencia al HUD

func _ready():
	# Busca la barra de vida en el árbol
	barra_vida = get_tree().root.get_node("Escena1/CanvasLayer/BarraVidaJugador")
	barra_vida.value = vida

func _physics_process(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()


func recibir_daño(cantidad):
	vida -= cantidad
	if vida < 0: vida = 0

	barra_vida.value = vida  # Actualiza el HUD

	if vida <= 0:
		print("El jugador murió")
		queue_free()
