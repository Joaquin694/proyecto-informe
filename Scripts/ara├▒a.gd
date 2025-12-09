extends CharacterBody2D

var vida_max = 50
var vida = vida_max
var ha_recibido_daño = false

@export var speed: float = 100.0

var player
@onready var anim = $AnimatedSprite2D
@onready var barra_vida: ProgressBar = $BarraVida

func _ready():
	# Configurar capas de colisión
	set_collision_layer_value(1, false)  # No está en capa jugador
	set_collision_layer_value(2, false)  # No está en capa proyectiles
	set_collision_layer_value(3, true)   # SÍ está en capa enemigos
	
	set_collision_mask_value(1, true)    # Colisiona con jugador
	set_collision_mask_value(2, true)    # Colisiona con proyectiles
	
	# Agregar al grupo
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
