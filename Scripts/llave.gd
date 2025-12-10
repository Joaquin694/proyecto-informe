extends Area2D

func _ready():
	print("🔑 Llave creada en: ", global_position)
	
	# Conectar señal de colisión
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		print("\n⭐ ===== JUGADOR RECOGIÓ LLAVE =====")
		print("Posición: ", global_position)
		
		# Llamar al GameManager
		GameManager.recoger_llave()
		
		# Efecto visual antes de desaparecer
		_crear_efecto_recogida()
		
		# Destruir llave
		queue_free()
		print("🗑️ Llave destruida")
		print("===================================\n")

func _crear_efecto_recogida():
	# Crear partículas de recogida
	var particulas = CPUParticles2D.new()
	get_parent().add_child(particulas)
	particulas.global_position = global_position
	particulas.emitting = true
	particulas.one_shot = true
	particulas.amount = 30
	particulas.lifetime = 0.8
	particulas.explosiveness = 1.0
	particulas.direction = Vector2(0, -1)
	particulas.spread = 180
	particulas.initial_velocity_min = 80
	particulas.initial_velocity_max = 150
	particulas.gravity = Vector2(0, -100)
	particulas.scale_amount_min = 3
	particulas.scale_amount_max = 6
	particulas.color = Color(1, 0.9, 0.3)  # Amarillo dorado
	
	# Auto-destruir partículas
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): 
		if is_instance_valid(particulas):
			particulas.queue_free()
	)
