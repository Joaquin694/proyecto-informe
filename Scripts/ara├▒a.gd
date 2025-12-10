extends CharacterBody2D

var vida_max = 50
var vida = vida_max
var ha_recibido_daño = false
@export var speed: float = 100.0
var player

@onready var anim = $AnimatedSprite2D
@onready var barra_vida: ProgressBar = $BarraVida

func _ready():
	set_collision_layer_value(1, false)  
	set_collision_layer_value(2, false)  
	set_collision_layer_value(3, true)   
	
	set_collision_mask_value(1, true)    # Detecta jugador
	set_collision_mask_value(2, true)    # Detecta proyectiles
	set_collision_mask_value(4, true)    # ✅ NUEVO: Detecta paredes
	
	add_to_group("enemigos")
	
	player = get_tree().get_first_node_in_group("player")
	
	if anim:
		anim.play("quieto")
	
	if barra_vida:
		barra_vida.max_value = vida_max
		barra_vida.value = vida
		barra_vida.visible = false
	
	print("=== ARAÑA DEBUG ===")
	print("Posición: ", global_position)
	print("En grupo 'enemigos': ", is_in_group("enemigos"))
	print("Collision layers: ", collision_layer)
	print("Collision mask: ", collision_mask)
	print("==================")

func _physics_process(delta):
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	move_and_slide()
	
	# ✅ NUEVO: Empujar si está atascado en pared
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			# Si choca con pared, intentar rodearla
			if collider is TileMapLayer or collider is StaticBody2D:
				# Empujar perpendicular a la normal de colisión
				var push = collision.get_normal() * speed
				velocity += push
	
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
	print("🔴 ARAÑA RECIBIENDO DAÑO: ", cantidad, " | Vida: ", vida, " -> ", vida - cantidad)
	
	vida -= cantidad
	
	if not ha_recibido_daño and barra_vida:
		ha_recibido_daño = true
		barra_vida.visible = true
	
	if barra_vida:
		barra_vida.value = vida
	
	if vida <= 0:
		print("💀 ARAÑA MURIÓ")
		queue_free()
