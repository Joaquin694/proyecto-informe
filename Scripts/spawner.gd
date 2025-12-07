extends Node2D

# Sistema de oleadas independiente para arañas y fantasmas

@export var arana_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var spawn_automatico = true
@export var tiempo_entre_oleadas = 20.0
@export var puntos_spawn: Array[Marker2D] = []

var oleada_actual = 0
var enemigos_por_oleada = 4
var tiempo_transcurrido = 0.0

func _ready():
	# Si no hay puntos de spawn definidos, crear algunos por defecto
	if puntos_spawn.is_empty():
		print("ADVERTENCIA: No hay puntos de spawn definidos. Usa Marker2D")

func _process(delta):
	if not spawn_automatico:
		return
	
	tiempo_transcurrido += delta
	
	if tiempo_transcurrido >= tiempo_entre_oleadas:
		tiempo_transcurrido = 0.0
		iniciar_oleada()

func iniciar_oleada():
	oleada_actual += 1
	var cantidad = enemigos_por_oleada + (oleada_actual - 1)  # Aumenta con cada oleada
	
	print("Iniciando oleada ", oleada_actual, " con ", cantidad, " enemigos")
	
	for i in cantidad:
		await get_tree().create_timer(1.0).timeout
		spawn_enemigo_aleatorio()

func spawn_enemigo_aleatorio():
	var enemigo
	
	# 50% araña, 50% fantasma
	if randf() > 0.5:
		if arana_scene:
			enemigo = arana_scene.instantiate()
	else:
		if fantasma_scene:
			enemigo = fantasma_scene.instantiate()
	
	if not enemigo:
		print("ERROR: No se pudo instanciar enemigo")
		return
	
	# Elegir punto de spawn aleatorio
	if puntos_spawn.is_empty():
		# Spawn aleatorio en el mapa si no hay puntos definidos
		enemigo.global_position = Vector2(
			randf_range(100, 1820),
			randf_range(100, 980)
		)
	else:
		var punto_aleatorio = puntos_spawn[randi() % puntos_spawn.size()]
		enemigo.global_position = punto_aleatorio.global_position
	
	# Agregar a la escena actual, no a root
	get_parent().call_deferred("add_child", enemigo)

func detener_oleadas():
	spawn_automatico = false

func reanudar_oleadas():
	spawn_automatico = true
	tiempo_transcurrido = 0.0
