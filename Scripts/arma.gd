extends Node2D

const BALA = preload("res://Escenas/bala.tscn")
@onready var aparicion_bala: Marker2D = $Marker2D
@onready var sonido_disparo: AudioStreamPlayer2D = $SonidoDisparo
@onready var sonido_recarga: AudioStreamPlayer2D = $SonidoRecarga

# Sistema de munición
var balas_actuales = 8
var balas_max = 8
var balas_reserva = 40
var recargando = false
var tiempo_recarga = 2.0

# CAMBIO: Referencia al HUD
var hud

func _ready():
	# CAMBIO: Obtener referencia al CanvasLayer
	hud = get_tree().root.get_node_or_null("Escena1/CanvasLayer")
	if hud:
		hud.actualizar_municion(balas_actuales, balas_reserva, false)
		print("Arma conectada al HUD")
	else:
		print("ADVERTENCIA: No se encontró CanvasLayer")

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	
	# Disparar
	if Input.is_action_just_pressed("disparo") and not recargando:
		if balas_actuales > 0:
			disparar()
		else:
			print("¡Sin munición! Recarga con R")
	
	# Recargar
	if Input.is_action_just_pressed("recargar") and not recargando:
		if balas_actuales < balas_max and balas_reserva > 0:
			iniciar_recarga()
		elif balas_actuales >= balas_max:
			print("Cargador lleno")
		elif balas_reserva <= 0:
			print("¡Sin munición de reserva!")

func disparar():
	# Crear y posicionar la bala
	var bullet_instance = BALA.instantiate()
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = aparicion_bala.global_position
	bullet_instance.rotation = rotation
	
	# Reproducir sonido de disparo
	if sonido_disparo:
		sonido_disparo.play()
	
	# Reducir munición
	balas_actuales -= 1
	
	# CAMBIO: Actualizar HUD
	if hud:
		hud.actualizar_municion(balas_actuales, balas_reserva, false)
	
	print("Balas: ", balas_actuales, "/", balas_max, " | Reserva: ", balas_reserva)
	
	# Recarga automática si te quedas sin balas
	if balas_actuales <= 0 and balas_reserva > 0:
		iniciar_recarga()

func iniciar_recarga():
	if recargando:
		return
	
	print("Recargando...")
	recargando = true
	
	# CAMBIO: Actualizar HUD para mostrar "RECARGANDO..."
	if hud:
		hud.actualizar_municion(balas_actuales, balas_reserva, true)
	
	# Reproducir sonido de recarga
	if sonido_recarga:
		sonido_recarga.play()
	
	# Esperar tiempo de recarga
	await get_tree().create_timer(tiempo_recarga).timeout
	
	# Calcular cuántas balas recargar
	var balas_necesarias = balas_max - balas_actuales
	var balas_a_recargar = min(balas_necesarias, balas_reserva)
	
	balas_actuales += balas_a_recargar
	balas_reserva -= balas_a_recargar
	
	recargando = false
	
	# CAMBIO: Actualizar HUD
	if hud:
		hud.actualizar_municion(balas_actuales, balas_reserva, false)
	
	print("¡Recarga completa! Balas: ", balas_actuales, "/", balas_max, " | Reserva: ", balas_reserva)

func añadir_municion(cantidad: int):
	balas_reserva += cantidad
	# CAMBIO: Actualizar HUD
	if hud:
		hud.actualizar_municion(balas_actuales, balas_reserva, false)
	print("Munición recogida! Reserva: ", balas_reserva)
