extends Node2D



func _on_ok_pressed() -> void:
	get_tree().change_scene_to_file("res://Escenas/historia_inicio.tscn")
