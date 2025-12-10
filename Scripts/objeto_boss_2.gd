extends CharacterBody2D

@export var speed: float = 300.0
@export var damage: int = 15
# Control de rebotes y vida
@export var max_bounces: int = 1
@export var bounce_damping: float = 0.85
@export var lifetime: float = 6.0

var direction: Vector2 = Vector2.RIGHT
var bounce_count: int = 0
var age: float = 0.0

@onready var sprite: AnimatedSprite2D = $Sprite2D

func _ready():
	# Animación inicial
	if sprite:
		sprite.play("bola_fuego")
	
	# Colisiones
	collision_layer = 8
	collision_mask = 1
	
	add_to_group("proyectil_enemigo")
	
	velocity = direction.normalized() * speed
	rotation = velocity.angle()

func _physics_process(delta):
	# Edad / lifetime
	age += delta
	if age >= lifetime:
		queue_free()
		return
	
	# Mover y detectar colisión
	var colision = move_and_collide(velocity * delta)
	
	if colision:
		var cuerpo = colision.get_collider()
		
		# Si es jugador -> daño y destruir
		if cuerpo and cuerpo.is_in_group("player"):
			if cuerpo.has_method("recibir_daño"):
				cuerpo.recibir_daño(damage)
			_crear_efecto_impacto()
			queue_free()
			return
		
		# Si colisiona con otra cosa (pared, etc.)
		# Primero verificar si ya alcanzamos el límite de rebotes
		if bounce_count >= max_bounces:
			_crear_efecto_impacto()
			queue_free()
			return
		
		# Incrementar contador de rebotes
		bounce_count += 1
		
		# Calcula nueva velocidad rebotada
		velocity = velocity.bounce(colision.get_normal())
		
		# Aplicar damping
		velocity *= bounce_damping
		
		# Actualizar rotación
		rotation = velocity.angle()
		
		# Si la velocidad es muy baja después del rebote -> destruir
		if velocity.length() < 30.0:
			_crear_efecto_impacto()
			queue_free()
			return

func _crear_efecto_impacto():
	# Aquí puedes poner partículas/sonido antes de borrar
	pass

func _on_screen_exited():
	queue_free()
