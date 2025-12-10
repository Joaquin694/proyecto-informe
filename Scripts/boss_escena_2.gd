extends CharacterBody2D

signal boss_derrotado

@export var projectile_scene: PackedScene
@export var speed: float = 100.0
@export var rango_vision: float = 500.0
@export var tiempo_ataque: float = 3.0

var vida: int = 200
var vida_maxima: int = 200
var player: Node2D = null
var puede_disparar: bool = true
var jugador_en_rango: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_timer_ref: Timer = null

func _ready():
	# Capas
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, true)
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)
	
	# Grupos
	add_to_group("enemigos")
	add_to_group("boss")
	
	# Buscar jugador
	player = get_tree().get_first_node_in_group("player")
	
	# Timer de ataque: crearlo si no existe
	if has_node("AttackTimer"):
		attack_timer_ref = $AttackTimer
	else:
		var t = Timer.new()
		t.name = "AttackTimer"
		t.autostart = false
		add_child(t)
		attack_timer_ref = t
	
	attack_timer_ref.wait_time = tiempo_ataque
	
	# Conectar señal (Godot 4 usa Callable)
	if not attack_timer_ref.timeout.is_connected(_on_attack_timeout):
		attack_timer_ref.timeout.connect(_on_attack_timeout)
	
	attack_timer_ref.stop()
	
	if anim:
		anim.play("quieto")

func _physics_process(delta):
	# Refrescar referencia al jugador si es necesario
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	var distancia = global_position.distance_to(player.global_position)
	
	# Movimiento: si está dentro del rango, mover hacia el jugador
	if distancia <= rango_vision:
		# Si el jugador entró en rango, arrancar el timer
		if not jugador_en_rango:
			jugador_en_rango = true
			if attack_timer_ref:
				attack_timer_ref.start()
		
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		# Animaciones
		if abs(velocity.x) > 10:
			if velocity.x > 0:
				if anim:
					anim.play("derecha")
			else:
				if anim:
					anim.play("izquierda")
	else:
		# Si el jugador salió del rango, detener el timer
		if jugador_en_rango:
			jugador_en_rango = false
			if attack_timer_ref:
				attack_timer_ref.stop()
		
		velocity = Vector2.ZERO
		if anim:
			anim.play("quieto")
	
	move_and_slide()
	
	# Evitar empujes entre enemigos
	for i in range(get_slide_collision_count()):
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider and collider.is_in_group("enemigos"):
			velocity += (global_position - collider.global_position).normalized() * 20

# -----------------------------------------------------------
# ATAQUE DEL JEFE
# -----------------------------------------------------------

func _on_attack_timeout():
	if not puede_disparar:
		return
	if not player or not is_instance_valid(player):
		return
	
	var distancia = global_position.distance_to(player.global_position)
	if distancia <= rango_vision:
		lanzar_objeto_gigante()

func lanzar_objeto_gigante():
	if projectile_scene == null:
		print("ERROR: Debes asignar projectile_scene en el Inspector")
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	# Dirección hacia el jugador
	if player and is_instance_valid(player):
		var dir_vector = (player.global_position - global_position).normalized()
		
		# Asignar direction solo si el proyectil tiene esa propiedad
		if "direction" in projectile:
			projectile.direction = dir_vector
		
		# Rotar según la dirección
		projectile.rotation = dir_vector.angle()
	
	# Añadir al árbol (deferred)
	get_parent().call_deferred("add_child", projectile)

# -----------------------------------------------------------
# DAÑO Y MUERTE
# -----------------------------------------------------------

func recibir_daño(cantidad: int):
	vida -= cantidad
	print("🔥 BOSS RECIBIENDO DAÑO: ", cantidad, " | Vida restante: ", vida)
	
	# Efecto de golpe
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("💀 BOSS DERROTADO 💀")
	puede_disparar = false
	
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	
	if attack_timer_ref:
		attack_timer_ref.stop()
	
	# Animación de muerte
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Efecto de parpadeo
	for i in range(5):
		tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	
	tween.tween_property(self, "scale", Vector2(0, 0), 1.0)
	tween.tween_property(self, "rotation", TAU * 2, 1.0)
	
	await tween.finished
	
	boss_derrotado.emit()
	queue_free()
