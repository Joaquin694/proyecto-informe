extends CharacterBody2D

var speed = 400.0
var vida_max = 100
var vida = vida_max
var barra_vida
var invulnerable = false
var tiempo_invulnerabilidad = 1.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	barra_vida = get_tree().root.get_node_or_null("Escena1/CanvasLayer/BarraVidaJugador")
	if barra_vida:
		barra_vida.max_value = vida_max
		barra_vida.value = vida
	add_to_group("player")

func _physics_process(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	# Voltear sprite según dirección (sin animaciones por ahora)
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true
	
	move_and_slide()
	
	# Detectar colisiones con enemigos
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		
		if collider.is_in_group("enemigo") and not invulnerable:
			recibir_daño(10)
			# Empujar al jugador hacia atrás
			var knockback = (global_position - collider.global_position).normalized() * 200
			velocity = knockback

func recibir_daño(cantidad):
	if invulnerable:
		return
	
	vida -= cantidad
	if vida < 0:
		vida = 0
	
	if barra_vida:
		barra_vida.value = vida
	
	# Activar invulnerabilidad temporal
	invulnerable = true
	animacion_daño()
	
	await get_tree().create_timer(tiempo_invulnerabilidad).timeout
	invulnerable = false
	modulate = Color(1, 1, 1, 1)
	
	if vida <= 0:
		morir()

func animacion_daño():
	# Parpadeo rojo
	for i in range(3):
		modulate = Color(1, 0.3, 0.3, 1)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(0.1).timeout

func morir():
	# Animación simple de muerte (fade out)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	
	await tween.finished
	
	# Mostrar pantalla de Game Over
	var game_over_scene = load("res://Escenas/game_over.tscn")
	if game_over_scene:
		get_tree().change_scene_to_packed(game_over_scene)
	else:
		get_tree().reload_current_scene()
