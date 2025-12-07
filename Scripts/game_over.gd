extends Control


@onready var btn_reintentar = $"Panel/VBoxContainer/Reintentar"
@onready var btn_menu = $"Panel/VBoxContainer/Menu"

func _ready():
	# Pausar el juego cuando aparece Game Over
	get_tree().paused = true
	
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

func _on_reintentar_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn")
