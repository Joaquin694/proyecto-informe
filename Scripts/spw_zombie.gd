extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_activo := true
@export var intervalo_spawn := 5.0
@export var enemigos_por_ronda := 2

@export var areas_spawn: Array[Rect2] = []

var timer_spawn: Timer
const DISTANCIA_MINIMA_ENTRE_ENEMIGOS := 60
const DISTANCIA_MINIMA_JUGADOR := 150

func _ready():
	if areas_spawn.is_empty():
		push_error("⚠ No hay áreas de spawn configuradas")
		return
	
	timer_spawn = Timer.new()
	timer_spawn.wait_time = intervalo_spawn
	timer_spawn.autostart = true
	timer_spawn.timeout.connect(_on_spawn_round)
	add_child(timer_spawn)
	
	print("Spawner iniciado con ", areas_spawn.size(), " áreas")

func _on_spawn_round():
	if not spawn_activo: return

	# Elegimos 4 áreas distintas
	var zonas = areas_spawn.duplicate()
	zonas.shuffle()
	zonas = zonas.slice(0, min(enemigos_por_ronda, zonas.size()))

	for i in zonas.size():
		spawn_zombie(zonas[i])
		await get_tree().create_timer(0.2).timeout


# -----------------------------
# SPAWN INDIVIDUAL
# -----------------------------
func spawn_zombie(area: Rect2):
	if not zombie_scene:
		push_error("⚠ zombie_scene no asignado")
		return
	
	var posicion = buscar_posicion_valida(area)
	if posicion == Vector2.ZERO:
		print("No hay posición válida en área:", area)
		return

	var zombie = zombie_scene.instantiate()
	zombie.global_position = posicion
	get_parent().call_deferred("add_child", zombie)

	print("🧟 Zombi spawneado en", posicion)


# -----------------------------
# BÚSQUEDA DE POSICIONES
# -----------------------------
func buscar_posicion_valida(area: Rect2) -> Vector2:
	var max_intentos = 30

	for i in max_intentos:
		var pos_random = Vector2(
			randf_range(area.position.x, area.position.x + area.size.x),
			randf_range(area.position.y, area.position.y + area.size.y)
		)

		if es_posicion_valida(pos_random):
			return pos_random
	
	return Vector2.ZERO


# -----------------------------
# VALIDACIÓN REALISTA DE COLISIONES
# -----------------------------
func es_posicion_valida(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	# --- 1) Checar colisiones usando la forma ENTERA del enemigo ---
	var temp_zombie = zombie_scene.instantiate()
	temp_zombie.position = pos

	var shape_owner = temp_zombie.shape_owner_get_owner(0)
	var shape = temp_zombie.shape_owner_get_shape(0, 0)
	var shape_xform = temp_zombie.global_transform

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = shape_xform
	params.collision_mask = 1  # ajusta si tus paredes tienen otra capa
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var result = space_state.intersect_shape(params, 1)
	temp_zombie.queue_free()

	if result.size() > 0:
		return false

	# --- 2) Evitar que aparezca encima de otros enemigos ---
	for e in get_tree().get_nodes_in_group("enemigo"):
		if pos.distance_to(e.global_position) < DISTANCIA_MINIMA_ENTRE_ENEMIGOS:
			return false

	# --- 3) Evitar que aparezca demasiado cerca del jugador ---
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador and pos.distance_to(jugador.global_position) < DISTANCIA_MINIMA_JUGADOR:
		return false

	return true


# -----------------------------
# GESTIÓN
# -----------------------------
func detener_spawn():
	spawn_activo = false
	if timer_spawn:
		timer_spawn.stop()

func reanudar_spawn():
	spawn_activo = true
	if timer_spawn:
		timer_spawn.start()

func cambiar_intervalo(nuevo_intervalo):
	intervalo_spawn = nuevo_intervalo
	if timer_spawn:
		timer_spawn.wait_time = nuevo_intervalo
