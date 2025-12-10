extends Node2D  # O Control, si tu nodo raíz es de interfaz de usuario

# Referencias a los nodos hijos tal como se ven en tu imagen
@onready var imagen_1 = $"1"
@onready var imagen_2 = $"2"
@onready var imagen_3 = $"3"
@onready var boton = $Button

# Variables de lógica
var lista_sprites: Array = []
var indice_actual: int = 0

func _ready():
	# 1. Llenamos la lista con tus sprites en orden
	lista_sprites = [imagen_1, imagen_2, imagen_3]
	
	# 2. Conectamos la señal del botón (si no lo hiciste desde el editor)
	boton.pressed.connect(_al_presionar_boton)
	
	# 3. Inicializamos mostrando solo la primera imagen
	actualizar_visibilidad()

func _al_presionar_boton():
	# Aumentamos el índice para pasar a la siguiente "página"
	indice_actual += 1
	
	# Verificamos si ya nos pasamos del total de imágenes
	if indice_actual >= lista_sprites.size():
		cambiar_a_juego()
	else:
		actualizar_visibilidad()

func actualizar_visibilidad():
	# Recorremos todas las imágenes
	for i in range(lista_sprites.size()):
		if i == indice_actual:
			lista_sprites[i].visible = true  # Muestra la imagen actual
		else:
			lista_sprites[i].visible = false # Oculta las demás

func cambiar_a_juego():
	print("Historia terminada, cambiando de escena...")
	# AQUÍ COLOCA LA RUTA DE TU ESCENA DE JUEGO
	get_tree().change_scene_to_file("res://Escenas/escena_1.tscn")
