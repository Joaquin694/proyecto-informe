extends Area2D

# --- CONFIGURACIÓN ---
var velocidad_ida = 500.0
var velocidad_vuelta = 350.0 
const DISTANCIA_MAXIMA = 900.0 
const TIEMPO_ADVERTENCIA = 0.5 
var tiempo_vida_ataque = 5.0 

# Nueva variable para que la mano se pueda romper
var vida_mano = 30 

# --- VARIABLES ---
var direccion = Vector2.ZERO
var player_objetivo: Node2D = null
var posicion_inicial = Vector2.ZERO
var fase = 1 
var timer_advertencia = 0.0

@onready var sprite = $AnimatedSprite2D 

func _ready():
	sprite.play("mano") 
	add_to_group("manos") 
	
	# IMPORTANTE: Agregamos al grupo enemigos para que la bala sepa que puede golpearlo
	add_to_group("enemigos") 

func iniciar(pos_inicio, dir_objetivo, target):
	global_position = pos_inicio
	posicion_inicial = pos_inicio
	direccion = dir_objetivo.normalized()
	player_objetivo = target
	look_at(global_position + direccion)
	fase = 1

func _physics_process(delta):
	if fase == 1: procesar_fase_1_ida(delta)
	elif fase == 2: procesar_fase_2_rodar(delta)
	elif fase == 3: procesar_fase_3_lanzarse(delta)

# --- FASES (Igual que antes) ---
func procesar_fase_1_ida(delta):
	position += direccion * velocidad_ida * delta
	if global_position.distance_to(posicion_inicial) >= DISTANCIA_MAXIMA:
		fase = 2
		timer_advertencia = TIEMPO_ADVERTENCIA

func procesar_fase_2_rodar(delta):
	timer_advertencia -= delta
	rotation += 25.0 * delta 
	if timer_advertencia <= 0: fase = 3 

func procesar_fase_3_lanzarse(delta):
	tiempo_vida_ataque -= delta
	if tiempo_vida_ataque <= 0:
		queue_free()
		return
	if is_instance_valid(player_objetivo): 
		var dir_al_player = global_position.direction_to(player_objetivo.global_position)
		position += dir_al_player * velocidad_vuelta * delta
		look_at(player_objetivo.global_position)
	else:
		queue_free() 

# --- DAÑO AL PLAYER ---
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("¡Mano golpeó al jugador!")
		if body.has_method("recibir_daño"):
			body.recibir_daño(10) 
		queue_free() 

# --- NUEVO: DAÑO A LA MANO (POR BALAS) ---
func recibir_daño(cantidad):
	vida_mano -= cantidad
	# Efecto visual rápido
	modulate = Color(10, 10, 10) # Flash blanco brillante
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)
	
	if vida_mano <= 0:
		print("¡Mano destruida por disparo!")
		queue_free()
