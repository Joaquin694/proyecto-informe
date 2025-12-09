extends CharacterBody2D

@export var speed: float = 300.0
@export var damage: int = 15
# Definimos una dirección inicial (por defecto a la derecha, pero la cambias al instanciar)
var direction: Vector2 = Vector2.RIGHT 

@onready var sprite: AnimatedSprite2D = $Sprite2D# Asegúrate que tu nodo se llame así

func _ready():
	# 1. ACTIVAR LA ANIMACIÓN (Según tu imagen 1)
	sprite.play("bola_fuego")
	
	# Configuración de colisiones
	collision_layer = 8
	collision_mask = 1 # Debe chocar con paredes (1) y jugador
	
	add_to_group("proyectil_enemigo")
	
	# Establecemos la velocidad inicial
	velocity = direction * speed
	
	# Hacemos que rote para mirar hacia donde va
	rotation = direction.angle()

func _physics_process(delta):
	# move_and_collide mueve el objeto y nos devuelve información si choca
	var colision = move_and_collide(velocity * delta)
	
	if colision:
		var cuerpo = colision.get_collider()
		print("¡Rebote! Chocó con: ", cuerpo.name)
		
		# SI CHOCA CON EL JUGADOR
		if cuerpo.is_in_group("player"):
			if cuerpo.has_method("recibir_daño"):
				cuerpo.recibir_daño(damage)
			crear_efecto_impacto() # Opcional: destruir bala
			
		# SI CHOCA CON PAREDES (O cualquier otra cosa) -> REBOTAR
		else:
			# Esta función mágica calcula el ángulo de rebote exacto
			velocity = velocity.bounce(colision.get_normal())
			
			# Actualizamos la rotación para que la bola "mire" a la nueva dirección
			rotation = velocity.angle()
			
			# Opcional: Aumentar velocidad tras rebote para hacerlo más difícil
			velocity *= 1.05 

func crear_efecto_impacto():
	# Aquí podrías poner una animación de explosión antes de borrarla
	queue_free()

func _on_screen_exited():
	queue_free()
