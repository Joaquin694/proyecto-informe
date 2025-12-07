extends Control

var pause_toggle = false

func _ready() -> void:
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_and_unpause()

func pause_and_unpause():
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	self.visible = pause_toggle

func _on_resume_pressed() -> void:
	pause_and_unpause()

func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/MainMenu.tscn")

func _on_opciones_pressed() -> void:
	# Ocultar el menú de pausa
	self.visible = false
	
	# Obtener el MenuOpciones (es un CanvasLayer hermano de MenuPausa)
	var menu_opciones = get_node("../../MenuOpciones/Control")
	menu_opciones.visible = true
