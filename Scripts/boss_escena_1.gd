extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var arana_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var speed := 100.0
@export var puntos_spawn: Array[Marker2D] = []

# --- CAMBIO 1: Variables nuevas para visión y tiempo de ataque ---
@export var rango_vision: float = 500.0 # Distancia máxima para detectar al jugador
@export var tiempo_ataque: float = 3.0  # Segundos entre cada bola de fuego
# ---------------------------------------------------------------

var vida := 200
var vida_maxima := 200
var player
var oleada_actual = 0
var tiempo_spawn_enemigos = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var attack_timer_ref = null # Referencia para guardar el timer

func _ready():
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, true)
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)
	
	add_to_group("enemigos")
	add_to_group("boss")
	
	player = get_tree().get_first_node_in_group("player")
	
	# --- CAMBIO 2: Configuración del Timer de Ataque usando la variable ---
	if has_node("AttackTimer"):
		attack_timer_ref = $AttackTimer
		attack_timer_ref.wait_time = tiempo_ataque # Usamos la variable nueva
		attack_timer_ref.timeout.connect(_on_timer_timeout)
		attack_timer_ref.start()
	else:
		print("Creando AttackTimer por código...")
		var attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		attack_timer.wait_time = tiempo_ataque # Usamos la variable nueva
		attack_timer.autostart = true
		add_child(attack_timer)
		attack_timer.timeout.connect(_on_timer_timeout)
		attack_timer_ref = attack_timer
	# ---------------------------------------------------------------------
	
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
	print("Rango Visión: ", rango_vision)
	print("Tiempo Ataque: ", tiempo_ataque)

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	# --- CAMBIO 3: Lógica de Visión ---
	# Calculamos la distancia al jugador
	var distancia_jugador = global_position.distance_to(player.global_position)
	
	# Solo se mueve si el jugador está DENTRO del rango de visión
	if distancia_jugador <= rango_vision:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		# Animaciones de movimiento
		if anim:
			if abs(velocity.x) > 10:
				if velocity.x > 0:
					anim.play("derecha")
				else:
					anim.play("izquierda")
	else:
		# Si el jugador está lejos, el Boss se queda quieto
		velocity = Vector2.ZERO
		if anim:
			anim.play("quieto")
	# ----------------------------------
	
	move_and_slide()
	
	# Colisiones con otros enemigos (separación)
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider and collider.is_in_group("enemigos"):
			var empuje = (global_position - collider.global_position).normalized() * 30
			velocity += empuje

func recibir_daño(cantidad: int):
	# ... (El código de recibir daño se mantiene igual) ...
	print("🔥 BOSS RECIBIENDO DAÑO: ", cantidad, " | Vida: ", vida)
	vida -= cantidad
	
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	if vida <= 150 and oleada_actual < 1:
		oleada_actual = 1
		spawn_oleada(3)
	elif vida <= 100 and oleada_actual < 2:
		oleada_actual = 2
		spawn_oleada(4)
	elif vida <= 50 and oleada_actual < 3:
		oleada_actual = 3
		spawn_oleada(5)
	
	if vida <= 0:
		morir()

func morir():
	# ... (El código de morir se mantiene igual) ...
	print("💀💀💀 BOSS DERROTADO 💀💀💀")
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	if attack_timer_ref: attack_timer_ref.stop()
	if has_node("SpawnTimer"): $SpawnTimer.stop()
	
	var tween = create_tween()
	tween.set_parallel(true)
	for i in range(5):
		tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	tween.tween_property(self, "scale", Vector2(0, 0), 1.0)
	tween.tween_property(self, "rotation", TAU * 2, 1.0)
	await tween.finished
	queue_free()

func _on_timer_timeout():
	# --- CAMBIO 4: Condición de disparo ---
	# Solo dispara si el jugador está dentro del rango de visión
	if player and is_instance_valid(player):
		var distancia = global_position.distance_to(player.global_position)
		
		if distancia <= rango_vision:
			lanzar_objeto_gigante()
		else:
			print("Jugador fuera de rango, Boss no dispara.")

func _on_spawn_timer_timeout():
	# ... (Igual) ...
	spawn_oleada(2)

func lanzar_objeto_gigante():
	# ... (Igual) ...
	if projectile_scene == null: return
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	if player and is_instance_valid(player):
		var dir_vector = (player.global_position - global_position).normalized()
		projectile.direction = dir_vector
		projectile.rotation = dir_vector.angle()
	get_parent().call_deferred("add_child", projectile)

func spawn_oleada(cantidad: int):
	# ... (Igual) ...
	for i in cantidad:
		await get_tree().create_timer(0.5).timeout
		var enemigo
		if randf() > 0.5:
			if arana_scene: enemigo = arana_scene.instantiate()
		else:
			if fantasma_scene: enemigo = fantasma_scene.instantiate()
		if enemigo:
			configurar_enemigo(enemigo)
			var pos = obtener_posicion_spawn_aleatoria()
			enemigo.global_position = pos
			get_parent().call_deferred("add_child", enemigo)

func obtener_posicion_spawn_aleatoria() -> Vector2:
	# ... (Igual) ...
	if not puntos_spawn.is_empty():
		return puntos_spawn[randi() % puntos_spawn.size()].global_position
	if player and is_instance_valid(player):
		var radio = randf_range(400, 700)
		var angulo = randf_range(0, TAU)
		var pos_tentativa = global_position + Vector2(cos(angulo) * radio, sin(angulo) * radio)
		return pos_tentativa
	return Vector2(randf_range(100, 1820), randf_range(100, 980))

func configurar_enemigo(enemigo: CharacterBody2D):
	# ... (Igual) ...
	enemigo.add_to_group("enemigos")
	enemigo.set_collision_layer_value(1, false)
	enemigo.set_collision_layer_value(2, false)
	enemigo.set_collision_layer_value(3, true)
	enemigo.set_collision_mask_value(1, true)
	enemigo.set_collision_mask_value(2, true)
	enemigo.set_collision_mask_value(3, false)
