extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var speed := 100.0
var player

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

	# Verificar timer
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_timer_timeout)
	else:
		print("ERROR: Nodo 'AttackTimer' no existe en la escena del Boss")

	# Animación inicial
	if anim:
		anim.play("quieto")


func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		# Animaciones en base al movimiento
		if abs(velocity.x) > 10:
			if velocity.x > 0:
				anim.play("derecha")
			else:
				anim.play("izquierda")
		else:
			anim.play("quieto")


func _on_timer_timeout():
	lanzar_objeto_gigante()


func lanzar_objeto_gigante():
	if projectile_scene == null:
		print("ERROR: No has asignado la escena del proyectil en el Inspector")
		return

	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position

	if player:
		var dir_vector = (player.global_position - global_position).normalized()
		projectile.direction = dir_vector
		projectile.rotation = dir_vector.angle()

	# Añadir después de la física para evitar errores
	get_tree().root.call_deferred("add_child", projectile)
