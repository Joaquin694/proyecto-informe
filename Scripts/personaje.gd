extends CharacterBody2D

@export var base_speed = 400.0   
var speed = 0                      

var vida_max = 100
var vida = vida_max
var invulnerable = false
var tiempo_invulnerabilidad = 1.0

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D


func _ready():
	speed = base_speed * scale.x   

	set_collision_layer_value(1, true)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, false)
	
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, true)
	set_collision_mask_value(4, true)
	
	add_to_group("player")
	
	actualizar_hud()
	
	print("=== JUGADOR CONFIGURADO ===")
	print("Escala: ", scale)
	print("Base Speed: ", base_speed)
	print("Speed Ajustada: ", speed)
	print("Vida: ", vida, "/", vida_max)
	print("===========================")


func _physics_process(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	actualizar_animacion(input_direction)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		
		if collider and (collider.is_in_group("enemigos") or collider.is_in_group("boss")) and not invulnerable:
			print("💢 Colisión con enemigo")
			recibir_daño(10)
			var knockback = (global_position - collider.global_position).normalized() * 200
			velocity = knockback


func actualizar_animacion(direccion: Vector2):
	if direccion == Vector2.ZERO:
		sprite.stop()
		sprite.frame = 1 
	else:
		if not sprite.is_playing():
			sprite.play()
		
		if abs(direccion.x) > 0:
			if direccion.x > 0:
				sprite.play("derechaanimacion")
			else:
				sprite.play("isquierdaanimacion")
		elif abs(direccion.y) > 0:
			if direccion.y > 0:
				sprite.play("abajoanimacion")
			else:
				sprite.play("arribaanimacion")


func recibir_daño(cantidad: int):
	if invulnerable:
		print("  └─ Jugador invulnerable, daño ignorado")
		return
	
	print("💥 Jugador recibiendo daño: ", cantidad, " | Vida: ", vida, " -> ", vida - cantidad)
	
	vida -= cantidad
	if vida < 0:
		vida = 0
	
	actualizar_hud()
	
	invulnerable = true
	animacion_daño()
	
	await get_tree().create_timer(tiempo_invulnerabilidad).timeout
	invulnerable = false
	modulate = Color(1, 1, 1, 1)
	
	if vida <= 0:
		morir()


func actualizar_hud():
	if HUD and HUD.has_method("actualizar_vida"):
		HUD.actualizar_vida(vida, vida_max)
		print("✅ HUD actualizado: ", vida, "/", vida_max)
	else:
		print("⚠ No se encontró el Autoload HUD")


func animacion_daño():
	for i in range(3):
		modulate = Color(1, 0.3, 0.3, 1)
		await get_tree().create_timer(0.1).timeout
		modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(0.1).timeout


func morir():
	print("💀 JUGADOR MURIÓ")
	
	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.stop_music()
		print("🔇 Música del nivel detenida")
	
	# Desactivar física
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	await get_tree().create_timer(0.3).timeout
	
	var game_over_scene = load("res://Escenas/game_over.tscn")
	if game_over_scene:
		get_tree().change_scene_to_packed(game_over_scene)
	else:
		get_tree().reload_current_scene()
