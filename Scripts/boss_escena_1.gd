extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var arana_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var speed := 100.0
@export var puntos_spawn: Array[Marker2D] = []  # Opcional: arrastra Marker2D aquí

var vida := 200
var vida_maxima := 200
var player
var oleada_actual = 0
var tiempo_spawn_enemigos = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	# Configurar capas de colisión del boss
	set_collision_layer_value(1, false)  # No es jugador
	set_collision_layer_value(2, false)  # No es proyectil
	set_collision_layer_value(3, true)   # SÍ es enemigo
	
	set_collision_mask_value(1, true)    # Colisiona con jugador
	set_collision_mask_value(2, true)    # Detecta proyectiles
	set_collision_mask_value(3, false)   # No colisiona con otros enemigos
	
	# Agregar al grupo enemigos
	add_to_group("enemigos")
	add_to_group("boss")
	
	player = get_tree().get_first_node_in_group("player")
	
	
	# Verificar que el timer exista
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_timer_timeout)
		$AttackTimer.start()
	else:
		print("ERROR: Falta AttackTimer en el Boss")
		var attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		attack_timer.wait_time = 2.0
		attack_timer.autostart = true
		add_child(attack_timer)
		attack_timer.timeout.connect(_on_timer_timeout)
	
	# Timer para spawn de enemigos
	if has_node("SpawnTimer"):
		$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
		$SpawnTimer.start()
	else:
		var spawn_timer = Timer.new()
		spawn_timer.name = "SpawnTimer"
		spawn_timer.wait_time = 15.0
		spawn_timer.autostart = true
		add_child(spawn_timer)
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	anim.play("quieto")
	
	print("=== BOSS CONFIGURADO ===")
	print("Vida: ", vida)
	print("En grupo 'enemigos': ", is_in_group("enemigos"))
	print("Puntos de spawn disponibles: ", puntos_spawn.size())
	print("Collision layer: ", collision_layer)
	print("Collision mask: ", collision_mask)
	print("=======================")

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	# Evitar colisiones con otros enemigos
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider and collider.is_in_group("enemigos"):
			var empuje = (global_position - collider.global_position).normalized() * 30
			velocity += empuje
	
	move_and_slide()
	
	# Animaciones
	if anim:
		if abs(velocity.x) > 10:
			if velocity.x > 0:
				anim.play("derecha")
			else:
				anim.play("izquierda")
		else:
			anim.play("quieto")

func recibir_daño(cantidad: int):
	print("🔥 BOSS RECIBIENDO DAÑO: ", cantidad, " | Vida: ", vida, " -> ", vida - cantidad)
	
	vida -= cantidad
	
	
	# Animación de daño
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	# Spawn enemigos cuando pierde cierta vida
	if vida <= 150 and oleada_actual < 1:
		oleada_actual = 1
		print("💀 Boss spawneando oleada 1 (Vida: 150)")
		spawn_oleada(3)
	elif vida <= 100 and oleada_actual < 2:
		oleada_actual = 2
		print("💀 Boss spawneando oleada 2 (Vida: 100)")
		spawn_oleada(4)
	elif vida <= 50 and oleada_actual < 3:
		oleada_actual = 3
		print("💀 Boss spawneando oleada 3 (Vida: 50)")
		spawn_oleada(5)
	
	if vida <= 0:
		morir()

func morir():
	print("💀💀💀 BOSS DERROTADO 💀💀💀")
	
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	
	if has_node("AttackTimer"):
		$AttackTimer.stop()
	if has_node("SpawnTimer"):
		$SpawnTimer.stop()
	
	# Animación de muerte épica
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Parpadeo intenso
	for i in range(5):
		tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	
	tween.tween_property(self, "scale", Vector2(0, 0), 1.0)
	tween.tween_property(self, "rotation", TAU * 2, 1.0)
	
	await tween.finished
	queue_free()

func _on_timer_timeout():
	lanzar_objeto_gigante()

func _on_spawn_timer_timeout():
	print("⏰ Timer spawn activado (cada 15 segundos)")
	spawn_oleada(2)

func lanzar_objeto_gigante():
	if projectile_scene == null:
		print("ERROR: Debes asignar projectile_scene en el Inspector")
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	if player and is_instance_valid(player):
		var dir_vector = (player.global_position - global_position).normalized()
		projectile.direction = dir_vector
		projectile.rotation = dir_vector.angle()
	
	get_parent().call_deferred("add_child", projectile)

func spawn_oleada(cantidad: int):
	print("🔴 Spawneando ", cantidad, " enemigos desde el Boss")
	
	for i in cantidad:
		await get_tree().create_timer(0.5).timeout
		
		var enemigo
		if randf() > 0.5:
			if arana_scene:
				enemigo = arana_scene.instantiate()
		else:
			if fantasma_scene:
				enemigo = fantasma_scene.instantiate()
		
		if enemigo:
			# Configurar el enemigo antes de agregarlo
			configurar_enemigo(enemigo)
			
			# SPAWN INTELIGENTE
			var pos = obtener_posicion_spawn_aleatoria()
			enemigo.global_position = pos
			
			get_parent().call_deferred("add_child", enemigo)
			print("✅ Enemigo spawneado por Boss en: ", enemigo.global_position)

func obtener_posicion_spawn_aleatoria() -> Vector2:
	"""
	Obtiene una posición de spawn aleatoria basada en la configuración.
	Prioriza:
	1. Puntos de spawn predefinidos (Marker2D)
	2. Posiciones lejos del jugador
	3. Fallback aleatorio en el mapa
	"""
	
	# PRIORIDAD 1: Usar puntos de spawn predefinidos
	if not puntos_spawn.is_empty():
		var punto = puntos_spawn[randi() % puntos_spawn.size()]
		print("  └─ Usando punto de spawn predefinido: ", punto.global_position)
		return punto.global_position
	
	# PRIORIDAD 2: Spawn en círculo alrededor del boss
	# pero más lejos del jugador (más desafiante)
	if player and is_instance_valid(player):
		var intentos = 5  # Intentar 5 veces encontrar buena posición
		var mejor_pos = global_position
		var mejor_distancia = 0.0
		
		for i in intentos:
			# Radio grande para spawn lejos
			var radio = randf_range(400, 700)
			var angulo = randf_range(0, TAU)  # Ángulo aleatorio completo
			
			var pos_tentativa = global_position + Vector2(
				cos(angulo) * radio,
				sin(angulo) * radio
			)
			
			# Asegurar que no se salga del mapa (ajusta según tu mapa)
			pos_tentativa.x = clamp(pos_tentativa.x, 100, 1820)
			pos_tentativa.y = clamp(pos_tentativa.y, 100, 980)
			
			# Preferir posiciones lejos del jugador
			var dist_al_player = pos_tentativa.distance_to(player.global_position)
			if dist_al_player > mejor_distancia:
				mejor_distancia = dist_al_player
				mejor_pos = pos_tentativa
		
		print("  └─ Spawn en círculo (distancia al jugador: ", int(mejor_distancia), ")")
		return mejor_pos
	
	# FALLBACK: spawn aleatorio en el mapa si todo falla
	print("  └─ Spawn aleatorio fallback")
	return Vector2(
		randf_range(100, 1820),  # Ajusta según el ancho de tu mapa
		randf_range(100, 980)    # Ajusta según el alto de tu mapa
	)

func configurar_enemigo(enemigo: CharacterBody2D):
	"""Configura correctamente un enemigo spawneado para que pueda recibir daño"""
	
	# Agregar al grupo enemigos
	enemigo.add_to_group("enemigos")
	
	# Configurar capas de colisión
	enemigo.set_collision_layer_value(1, false)  # No es jugador
	enemigo.set_collision_layer_value(2, false)  # No es proyectil
	enemigo.set_collision_layer_value(3, true)   # SÍ es enemigo
	
	# Configurar con qué colisiona (máscara)
	enemigo.set_collision_mask_value(1, true)    # Colisiona con jugador
	enemigo.set_collision_mask_value(2, true)    # Detecta proyectiles
	enemigo.set_collision_mask_value(3, false)   # No colisiona con otros enemigos
