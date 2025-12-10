extends CharacterBody2D

@export var speed: float = 70.0
var vida_max = 50
var vida = vida_max
var ha_recibido_daño = false
var player
var atacando = false


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra_vida: ProgressBar = $BarraVida

func _ready():
	# Collision layer y mask
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, true)   
	
	set_collision_mask_value(1, true)   
	set_collision_mask_value(2, true)   
	set_collision_mask_value(4, true)    
	
	add_to_group("enemigos")
	
	player = get_tree().get_first_node_in_group("player")
	
	if anim:
		anim.play("quieto")
	
	if barra_vida:
		barra_vida.max_value = vida_max
		barra_vida.value = vida
		barra_vida.visible = false   
	
	print("===== ENEMIGO NUEVO DEBUG =====")
	print("Posición: ", global_position)
	print("En grupo enemigos: ", is_in_group("enemigos"))
	print("Collision Layer: ", collision_layer)
	print("Collision Mask : ", collision_mask)
	print("================================")


func _physics_process(delta):
	if atacando:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	
	move_and_slide()
	
	
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider is TileMapLayer or collider is StaticBody2D:
				var push = collision.get_normal() * speed
				velocity += push
	
	
	_actualizar_animacion()



func _actualizar_animacion():
	if atacando:
		return 
	
	if abs(velocity.x) > 10:
		if velocity.x > 0:
			anim.play("caminar_derecha")
		else:
			anim.play("caminar_izquierda")
	else:
		anim.play("quieto")



func atacar():
	if atacando:
		return
	
	atacando = true
	
	if player.global_position.x > global_position.x:
		anim.play("atacar_derecha")
	else:
		anim.play("atacar_izquierda")
	
	await anim.animation_finished
	
	atacando = false


func recibir_daño(cantidad: int):
	vida -= cantidad
	
	if not ha_recibido_daño:
		ha_recibido_daño = true
		if barra_vida:
			barra_vida.visible = true
	
	if barra_vida:
		barra_vida.value = vida
	
	if vida <= 0:
		_morir()


func _morir():
	print("💀 ENEMIGO MURIÓ")
	queue_free()
