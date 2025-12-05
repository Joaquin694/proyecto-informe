extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var speed := 100.0
var vida := 200

var player
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var barra_vida: TextureProgressBar = $BarraVida

func _ready():
	player = get_tree().get_first_node_in_group("player")

	# Configurar barra
	barra_vida.max_value = vida
	barra_vida.value = vida

	# Verificar que el timer exista
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_timer_timeout)
	else:
		print("ERROR: Falta AttackTimer en el Boss")

	anim.play("quieto")


func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
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
	barra_vida.value = vida

	if vida <= 0:
		queue_free()


func _on_timer_timeout():
	lanzar_objeto_gigante()


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

	get_tree().root.call_deferred("add_child", projectile)
