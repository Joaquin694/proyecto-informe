extends Node2D

@export var arana_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var spawn_activo: bool = true
@export var intervalo_spawn: float = 2
@export var enemigos_por_spawn: int = 4

# Múltiples áreas de spawn
@export var areas_spawn: Array[Rect2] = [
	Rect2(300, 150, 1000, 300), 
	Rect2(2000, 100, 1000, 300),   
	Rect2(2000, -500, 400, 400), 
]

var timer_spawn: Timer

func _ready():
	if areas_spawn.is_empty():
		print("ERROR: No hay áreas de spawn configuradas")
		return
	
	# Crear timer de spawn
	timer_spawn = Timer.new()
	timer_spawn.wait_time = intervalo_spawn
	timer_spawn.autostart = true
	timer_spawn.timeout.connect(_on_spawn_timer_timeout)
	add_child(timer_spawn)
	
	print("Sistema de spawn con ", areas_spawn.size(), " áreas iniciado")

func _on_spawn_timer_timeout():
	if not spawn_activo:
		return
	
	var cantidad = randi_range(4, 5)
	
	for i in cantidad:
		spawn_enemigo_aleatorio()
		await get_tree().create_timer(0.3).timeout

func spawn_enemigo_aleatorio():
	# Elegir tipo de enemigo (50/50)
	var enemigo_scene = arana_scene if randf() > 0.5 else fantasma_scene
	
	if not enemigo_scene:
		print("ERROR: Escena de enemigo no asignada")
		return
	
	# Buscar posición válida
	var posicion_valida = buscar_posicion_valida()
	
	if posicion_valida == Vector2.ZERO:
		print("No se encontró posición válida para spawn")
		return
	
	# Crear e instanciar enemigo
	var enemigo = enemigo_scene.instantiate()
	enemigo.global_position = posicion_valida
	
	# Agregar a la escena
	get_parent().call_deferred("add_child", enemigo)
	
	print("Enemigo spawneado en: ", posicion_valida)

func buscar_posicion_valida() -> Vector2:
	var intentos_maximos = 30
	var intentos = 0
	
	while intentos < intentos_maximos:
		# Elegir un área aleatoria
		var area_elegida = areas_spawn[randi() % areas_spawn.size()]
		
		# Generar posición aleatoria dentro del área
		var pos_random = Vector2(
			randf_range(area_elegida.position.x, area_elegida.position.x + area_elegida.size.x),
			randf_range(area_elegida.position.y, area_elegida.position.y + area_elegida.size.y)
		)
		
		# Verificar que la posición sea válida (solo paredes)
		if es_posicion_valida(pos_random):
			return pos_random
		
		intentos += 1
	
	return Vector2.ZERO

func es_posicion_valida(posicion: Vector2) -> bool:
	# 1. Verificar que NO esté dentro de una pared
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = posicion
	query.collision_mask = 1  # Layer de paredes
	query.collide_with_areas = false
	query.collide_with_bodies = true
	
	var result = space_state.intersect_point(query, 1)
	
	# Si hay colisión con pared, no es válido
	if result.size() > 0:
		return false
	
	# 2. Verificar que no haya otros enemigos muy cerca (opcional)
	var enemigos = get_tree().get_nodes_in_group("enemigo")
	for enemigo in enemigos:
		if posicion.distance_to(enemigo.global_position) < 50:
			return false
	
	return true

func detener_spawn():
	spawn_activo = false
	if timer_spawn:
		timer_spawn.stop()

func reanudar_spawn():
	spawn_activo = true
	if timer_spawn:
		timer_spawn.start()

func cambiar_intervalo(nuevo_intervalo: float):
	intervalo_spawn = nuevo_intervalo
	if timer_spawn:
		timer_spawn.wait_time = intervalo_spawn

func agregar_area_spawn(nueva_area: Rect2):
	areas_spawn.append(nueva_area)
	print("Nueva área de spawn agregada: ", nueva_area)

func limpiar_areas():
	areas_spawn.clear()
	print("Todas las áreas de spawn eliminadas")

# Visualizar áreas de spawn en debug
func _draw():
	if Engine.is_editor_hint() or OS.is_debug_build():
		var colores = [
			Color(1, 0, 0, 0.2),  # Rojo
			Color(0, 1, 0, 0.2),  # Verde
			Color(0, 0, 1, 0.2),  # Azul
			Color(1, 1, 0, 0.2),  # Amarillo
			Color(1, 0, 1, 0.2),  # Magenta
			Color(0, 1, 1, 0.2),  # Cian
		]
		
		for i in range(areas_spawn.size()):
			var area = areas_spawn[i]
			var color = colores[i % colores.size()]
			
			# Rellenar área
			draw_rect(area, color)
			# Borde
			draw_rect(area, Color(color.r, color.g, color.b, 1.0), false, 3.0)
			
			# Número del área
			var texto_pos = area.position + Vector2(10, 20)
			draw_string(ThemeDB.fallback_font, texto_pos, "Área " + str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
