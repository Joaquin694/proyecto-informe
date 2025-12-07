extends Control

func _ready():
	MusicPlayer.play_menu()


func _on_options_button_pressed():
	SceneManager.previous_scene = "res://Escenas/MainMenu.tscn"
	get_tree().change_scene_to_file("res://Escenas/Opciones.tscn")
	
func _on_quit_button_pressed():
	get_tree().quit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/escena_1.tscn")
