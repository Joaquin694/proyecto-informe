extends Area2D

@export var speed: float = 300.0
@export var damage: int = 15
var direction: Vector2 = Vector2.ZERO

func _ready():
	collision_layer = 8
	collision_mask = 1
	
	add_to_group("proyectil_enemigo")
	
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	else:
		print("ADVERTENCIA: Falta VisibleOnScreenNotifier2D en proyectil del boss")
	
	body_entered.connect(_on_body_entered)
	
	print("Proyectil del boss creado - Layer: ", collision_layer, " Mask: ", collision_mask)

func _process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	print("Proyectil colisionó con: ", body.name, " | Grupos: ", body.get_groups())
	
	if body.is_in_group("player"):
		print("¡Proyectil golpeó al jugador!")
		
		if body.has_method("recibir_daño"):
			body.recibir_daño(damage)
		
		queue_free()

func _on_screen_exited():
	queue_free()
