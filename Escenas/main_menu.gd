# main_menu.gd
extends Control

# Ruta a la escena principal de tu juego (escena_1.tscn)
const GAME_SCENE = "res://Escenas/escena_1.tscn"

# --- Funciones conectadas por la señal 'pressed' ---

func _on_start_button_pressed():
	# Carga la escena del juego
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_options_button_pressed():
	# Aquí puedes mostrar un sub-menú de opciones
	print("Mostrar menú de opciones")

func _on_quit_button_pressed():
	# Sale de la aplicación
	get_tree().quit()
