extends CharacterBody2D

@export var escena_mano: PackedScene 
@export var velocidad = 100.0
@export var vida = 100

var player: Node2D = null 
var tiempo_ataque = 2.0
var timer_ataque = 0.0

# Variables para el movimiento (Patrulla)
var direccion_movimiento = Vector2.DOWN # Empieza bajando
var tiempo_cambio_direccion = 2.0 # Cambia de dirección cada 2 segundos
var timer_movimiento = 0.0

@onready var sprite = $AnimatedSprite2D # Asegúrate de que el nodo se llame así

func _ready():
	# 1. Configuración de Grupos
	add_to_group("enemigos") # ¡CRUCIAL! Para que la bala lo detecte
	
	# 2. Buscar al Player
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("¡CUIDADO! El Enemigo no encuentra al Player.")

func _process(delta):
	# Temporizador para disparar manos
	timer_ataque -= delta
	if timer_ataque <= 0:
		intentar_atacar()
		timer_ataque = tiempo_ataque

func _physics_process(delta):
	mover_enemigo(delta)
	animar_enemigo()
	move_and_slide()

# --- LÓGICA DE MOVIMIENTO ---
func mover_enemigo(delta):
	timer_movimiento -= delta
	
	# Cambiar dirección cuando se acaba el tiempo
	if timer_movimiento <= 0:
		timer_movimiento = tiempo_cambio_direccion
		# Invertimos la dirección Y
		if direccion_movimiento == Vector2.DOWN:
			direccion_movimiento = Vector2.UP
		else:
			direccion_movimiento = Vector2.DOWN
	
	velocity = direccion_movimiento * velocidad

# --- LÓGICA DE ANIMACIÓN ---
func animar_enemigo():
	if velocity.length() == 0:
		sprite.play("quieto")
	elif velocity.y > 0:
		sprite.play("caminando_abajo")
	elif velocity.y < 0:
		sprite.play("caminando_arriba")

# --- SISTEMA DE DAÑO (Para las balas) ---
func recibir_daño(cantidad):
	vida -= cantidad
	print("Enemigo herido. Vida restante: ", vida)
	
	# Feedback visual (parpadeo rojo)
	modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("Enemigo derrotado")
	# Aquí podrías poner una explosión o sonido
	queue_free()

# --- SISTEMA DE ATAQUE (Tu código anterior) ---
func intentar_atacar():
	if get_tree().get_nodes_in_group("manos").size() == 0:
		# Se detiene un momento para atacar (opcional, se ve mejor)
		var velocidad_anterior = velocidad
		velocidad = 0
		sprite.play("quieto") # Pone pose de ataque
		
		lanzar_mano(-15) 
		lanzar_mano(15)
		
		# Espera un poquito y vuelve a caminar
		await get_tree().create_timer(0.5).timeout
		velocidad = velocidad_anterior

func lanzar_mano(angulo_extra_grados = 0.0):
	if not player or not escena_mano: return
	var nueva_mano = escena_mano.instantiate()
	get_parent().call_deferred("add_child", nueva_mano) 
	var direccion_ataque = global_position.direction_to(player.global_position)
	var direccion_final = direccion_ataque.rotated(deg_to_rad(angulo_extra_grados))
	nueva_mano.iniciar(global_position, direccion_final, player)
