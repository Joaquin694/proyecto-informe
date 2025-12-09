extends Node2D

@export var arana_scene: PackedScene
@export var fantasma_scene: PackedScene
@export var spawn_automatico = true
@export var tiempo_entre_oleadas = 20.0
@export var puntos_spawn: Array[Marker2D] = []

var oleada_actual = 0
var enemigos_por_oleada = 4
var tiempo_transcurrido = 0.0

func _ready():
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
	var cantidad = enemigos_por_oleada + (oleada_actual - 1)
	
	print("Iniciando oleada ", oleada_actual, " con ", cantidad, " enemigos")
	
	for i in cantidad:
		await get_tree().create_timer(1.0).timeout
		spawn_enemigo_aleatorio()

func spawn_enemigo_aleatorio():
	var enemigo
	
	if randf() > 0.5:
		if arana_scene:
			enemigo = arana_scene.instantiate()
	else:
		if fantasma_scene:
			enemigo = fantasma_scene.instantiate()
	
	if not enemigo:
		print("ERROR: No se pudo instanciar enemigo")
		return
	
	if puntos_spawn.is_empty():
		enemigo.global_position = Vector2(
			randf_range(100, 1820),
			randf_range(100, 980)
		)
	else:
		var punto_aleatorio = puntos_spawn[randi() % puntos_spawn.size()]
		enemigo.global_position = punto_aleatorio.global_position
	
	configurar_enemigo(enemigo)
	
	get_parent().call_deferred("add_child", enemigo)
	
	print("Enemigo spawneado: ", enemigo.name, " en ", enemigo.global_position)

func configurar_enemigo(enemigo: CharacterBody2D):
	enemigo.add_to_group("enemigos")
	
	enemigo.set_collision_layer_value(1, false)  # No está en capa jugador
	enemigo.set_collision_layer_value(2, false)  # No está en capa proyectiles
	enemigo.set_collision_layer_value(3, true)   # SÍ está en capa enemigos
	
	enemigo.set_collision_mask_value(1, true)    # Colisiona con jugador
	enemigo.set_collision_mask_value(2, true)    # Colisiona con proyectiles
	enemigo.set_collision_mask_value(3, false)   # No colisiona con otros enemigos

func detener_oleadas():
	spawn_automatico = false

func reanudar_oleadas():
	spawn_automatico = true
	tiempo_transcurrido = 0.0
