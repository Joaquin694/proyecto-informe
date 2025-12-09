extends Control

@onready var btn_reintentar = $"Panel/VBoxContainer/Reintentar"
@onready var btn_menu = $"Panel/VBoxContainer/Menu"

# Variable para saber qué escena reintentar
var escena_anterior = ""

func _ready():
	# Reproducir música de Game Over usando el MusicPlayer
	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.play_game_over()
		print("Reproduciendo música de Game Over")
	else:
		print("ERROR: No se encontró MusicPlayer")
	
	# Conectar señales de los botones
	if btn_reintentar:
		btn_reintentar.pressed.connect(_on_reintentar_pressed)
	else:
		print("ERROR: No se encontró el botón REINTENTAR")
	
	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)
	else:
		print("ERROR: No se encontró el botón VOLVER AL MENÚ")
	
	# Hacer visible el mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Obtener la escena anterior desde SceneManager si existe
	if SceneManager.has_method("get_current_level"):
		escena_anterior = SceneManager.get_current_level()
	else:
		# Fallback: asumir que es escena_1
		escena_anterior = "res://Escenas/escena_1.tscn"
	
	print("Game Over - Escena anterior: ", escena_anterior)

func _on_reintentar_pressed():
	print("Reintentando nivel...")
	
	# Reproducir música del nivel
	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.play_nivel()
	
	# Asegurarse de que el juego NO esté pausado
	get_tree().paused = false
	
	# Recargar la escena del nivel
	if escena_anterior != "":
		get_tree().change_scene_to_file(escena_anterior)
	else:
		# Si no hay escena guardada, recargar escena_1 por defecto
		get_tree().change_scene_to_file("res://Escenas/escena_1.tscn")

func _on_menu_pressed():
	print("Volviendo al menú...")
	
	# Reproducir música del menú
	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.play_menu()
	
	# Asegurarse de que el juego NO esté pausado
	get_tree().paused = false
	
	# Ir al menú principal
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn")
