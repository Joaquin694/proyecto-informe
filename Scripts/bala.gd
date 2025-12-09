extends Area2D

const SPEED = 600
var damage = 20

func _ready():
	# Configurar las capas de colisión de la bala
	collision_layer = 2   # Capa 2 (proyectiles)
	collision_mask = 4    # Detecta capa 3 (enemigos)
	
	# Agregar al grupo proyectiles
	add_to_group("proyectil")
	
	# Conectar señal
	body_entered.connect(_on_body_entered)
	
	print("Bala creada en: ", global_position)

func _process(delta):
	position += transform.x * SPEED * delta

func _on_body_entered(body):
	print("Bala colisionó con: ", body.name, " | Grupos: ", body.get_groups())
	
	if body.is_in_group("enemigos"):
		print("¡Impacto en enemigo!")
		if body.has_method("recibir_daño"):
			body.recibir_daño(damage)
		queue_free()
	elif body.is_in_group("paredes") or body.is_in_group("obstaculos"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
