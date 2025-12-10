extends Area2D

const SPEED = 600
var damage = 20

func aplicar_escala(escala: Vector2):
	scale = escala

func _ready():
	# Configurar colisiones de la bala
	set_collision_layer_value(2, true)   # Proyectiles
	set_collision_mask_value(3, true)    # Enemigos
	set_collision_mask_value(4, true)    # Paredes

	add_to_group("proyectil")

	# --- CORRECCIÓN IMPORTANTE ---
	# Conectamos las dos señales: una para cuerpos físicos y otra para áreas
	body_entered.connect(_on_body_entered) 
	area_entered.connect(_on_area_entered) # <--- ESTO FALTABA

	print("🔫 Bala creada en: ", global_position, " con escala: ", scale)

func _process(delta):
	position += transform.x * SPEED * delta

# 1. ESTO DETECTA PAREDES Y ENEMIGOS FISICOS (CharacterBody2D/StaticBody2D)
func _on_body_entered(body):
	print("💥 Bala colisionó con CUERPO: ", body.name)

	if body.is_in_group("enemigos") or body.is_in_group("boss"):
		print("   └─ ¡Impacto en enemigo físico!")
		if body.has_method("recibir_daño"):
			body.recibir_daño(damage)
		queue_free()
		return

	# Lógica de paredes
	if body is TileMapLayer or body is StaticBody2D or body.is_in_group("paredes"):
		print("   └─ Impactó pared/obstáculo")
		queue_free()

# 2. ESTO DETECTA TUS MANOS (Area2D)
func _on_area_entered(area):
	print("💥 Bala colisionó con AREA: ", area.name)
	
	# Como añadimos la mano al grupo "enemigos" en el script de la mano, esto funcionará:
	if area.is_in_group("enemigos") or area.is_in_group("manos"):
		print("   └─ ¡Impacto en MANO!")
		if area.has_method("recibir_daño"):
			area.recibir_daño(damage) # Le baja la vida a la mano
		queue_free() # Destruye la bala

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
