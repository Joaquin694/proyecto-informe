extends Area2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	# Asegúrate de tener el nodo VisibleOnScreenNotifier2D creado
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	body_entered.connect(_on_body_entered)

func _process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	# Escribe esta línea manualmente si te da error al copiar/pegar
	if body.is_in_group("player"):
		print("¡Golpeaste al jugador!")
		# body.take_damage() 
		queue_free()
