extends CharacterBody2D

signal boss_derrotado  # ⭐ NUEVA LÍNEA

@export var projectile_scene: PackedScene
@export var speed := 100.0
@export var rango_vision: float = 500.0
@export var tiempo_ataque: float = 3.0

var vida := 200
var vida_maxima := 200
var player

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var attack_timer_ref = null

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
	
	if has_node("AttackTimer"):
		attack_timer_ref = $AttackTimer
		attack_timer_ref.wait_time = tiempo_ataque
		attack_timer_ref.timeout.connect(_on_timer_timeout)
		attack_timer_ref.start()
	else:
		var attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		attack_timer.wait_time = tiempo_ataque
		attack_timer.autostart = true
		add_child(attack_timer)
		attack_timer.timeout.connect(_on_timer_timeout)
		attack_timer_ref = attack_timer
	
	anim.play("quieto")

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	var distancia_jugador = global_position.distance_to(player.global_position)
	
	if distancia_jugador <= rango_vision:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		if anim:
			if abs(velocity.x) > 10:
				if velocity.x > 0:
					anim.play("derecha")
				else:
					anim.play("izquierda")
	else:
		velocity = Vector2.ZERO
		if anim:
			anim.play("quieto")
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider and collider.is_in_group("enemigos"):
			var empuje = (global_position - collider.global_position).normalized() * 30
			velocity += empuje

func recibir_daño(cantidad: int):
	print("🔥 BOSS RECIBIENDO DAÑO: ", cantidad, " | Vida: ", vida)
	vida -= cantidad
	
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	if vida <= 0:
		morir()

func morir():
	print("💀💀💀 BOSS DERROTADO 💀💀💀")
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	
	if attack_timer_ref:
		attack_timer_ref.stop()
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	for i in range(5):
		tween.tween_property(self, "modulate", Color(1, 0, 0, 1), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.1)
	
	tween.tween_property(self, "scale", Vector2(0, 0), 1.0)
	tween.tween_property(self, "rotation", TAU * 2, 1.0)
	
	await tween.finished
	
	boss_derrotado.emit()  # ⭐ NUEVA LÍNEA
	
	queue_free()

func _on_timer_timeout():
	if player and is_instance_valid(player):
		var distancia = global_position.distance_to(player.global_position)
		
		if distancia <= rango_vision:
			lanzar_objeto_gigante()

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
