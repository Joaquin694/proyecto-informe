extends Control

@onready var btn_reintentar = $"CanvasLayer/GameOver/Reintentar"
@onready var btn_menu = $"CanvasLayer/GameOver/Menu"

var escena_anterior = ""


func _ready():
	# Depuración para confirmar nodos
	print("Reintentar encontrado?: ", btn_reintentar)
	print("Menu encontrado?: ", btn_menu)

	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.play_game_over()

	# Conectar botones
	if btn_reintentar:
		btn_reintentar.pressed.connect(_on_reintentar_pressed)
	else:
		print("ERROR: No se encontró botón REINTENTAR")

	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)
	else:
		print("ERROR: No se encontró botón MENU")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if SceneManager.has_method("get_current_level"):
		escena_anterior = SceneManager.get_current_level()
	else:
		escena_anterior = "res://Escenas/escena_1.tscn"

	print("Escena anterior: ", escena_anterior)


func _on_reintentar_pressed():
	print("Reintentando nivel...")

	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.play_nivel()

	get_tree().paused = false

	if escena_anterior != "":
		get_tree().change_scene_to_file(escena_anterior)
	else:
		get_tree().change_scene_to_file("res://Escenas/escena_1.tscn")


func _on_menu_pressed():
	print("Volviendo al menú...")

	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player:
		music_player.play_menu()

	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn")
