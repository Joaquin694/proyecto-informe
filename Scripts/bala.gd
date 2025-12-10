extends Area2D

const SPEED = 600
var damage = 20

func aplicar_escala(escala: Vector2):
	# Asigna la escala del arma/personaje a la bala
	scale = escala


func _ready():
	# Configurar colisiones de la bala
	set_collision_layer_value(2, true)   # Proyectiles
	set_collision_mask_value(3, true)    # Enemigos
	set_collision_mask_value(4, true)    # Paredes

	# Grupo
	add_to_group("proyectil")

	# Señal
	body_entered.connect(_on_body_entered)

	print("🔫 Bala creada en: ", global_position, " con escala: ", scale)


func _process(delta):
	position += transform.x * SPEED * delta


func _on_body_entered(body):
	print("💥 Bala colisionó con: ", body.name, " | Tipo: ", body.get_class())

	# Enemigos o jefe
	if body.is_in_group("enemigos") or body.is_in_group("boss"):
		print("   └─ ¡Impacto en enemigo!")
		if body.has_method("recibir_daño"):
			body.recibir_daño(damage)
		queue_free()
		return

	# Paredes
	if body is TileMapLayer:
		print("   └─ Impactó TileMapLayer (pared)")
		queue_free()
		return

	if body is StaticBody2D:
		print("   └─ Impactó StaticBody2D (pared)")
		queue_free()
		return

	# Grupos
	if body.is_in_group("paredes") or body.is_in_group("obstaculos"):
		print("   └─ Impactó obstáculo (por grupo)")
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
