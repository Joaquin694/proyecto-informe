extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var arana_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var speed := 100.0

var vida := 200
var player
var oleada_actual = 0
var tiempo_spawn_enemigos = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision = $CollisionShape2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemigo")

	# Verificar que el timer exista
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_timer_timeout)
	else:
		print("ERROR: Falta AttackTimer en el Boss")
	
	# Timer para spawn de enemigos
	if has_node("SpawnTimer"):
		$SpawnTimer.timeout.connect(_on_spawn_timer_timeout)
	else:
		var spawn_timer = Timer.new()
		spawn_timer.name = "SpawnTimer"
		spawn_timer.wait_time = 15.0
		spawn_timer.autostart = true
		add_child(spawn_timer)
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	anim.play("quieto")

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		
		# Evitar colisiones con otros enemigos
		for i in get_slide_collision_count():
			var collision_info = get_slide_collision(i)
			var collider = collision_info.get_collider()
			if collider.is_in_group("enemigo"):
				var empuje = (global_position - collider.global_position).normalized() * 30
				velocity += empuje
		
		move_and_slide()

		if abs(velocity.x) > 10:
			if velocity.x > 0:
				anim.play("derecha")
			else:
				anim.play("izquierda")
		else:
			anim.play("quieto")

func recibir_daño(cantidad):
	vida -= cantidad
	
	# Animación de daño
	modulate = Color(1, 0, 0, 1)
	await get_tree().create_timer(0.15).timeout
	modulate = Color(1, 1, 1, 1)
	
	# Spawn enemigos cuando pierde cierta vida
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
	print("Boss derrotado")
	queue_free()

func _on_timer_timeout():
	lanzar_objeto_gigante()

func _on_spawn_timer_timeout():
	spawn_oleada(2)

func lanzar_objeto_gigante():
	if projectile_scene == null:
		print("ERROR: Debes asignar projectile_scene en el Inspector")
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position

	if player:
		var dir_vector = (player.global_position - global_position).normalized()
		projectile.direction = dir_vector
		projectile.rotation = dir_vector.angle()

	get_parent().call_deferred("add_child", projectile)

func spawn_oleada(cantidad: int):
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
			# Spawn en posición aleatoria cerca del boss
			var offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
			enemigo.global_position = global_position + offset
			get_parent().call_deferred("add_child", enemigo)
