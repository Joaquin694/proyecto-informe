extends Node2D

func _ready():
	MusicPlayer.play_nivel()

func _on_options_pressed():
	SceneManager.previous_scene = "res://Escenas/escena_1.tscn"
	get_tree().paused = false  
	get_tree().change_scene_to_file("res://Escenas/Opciones.tscn")
	
	
