extends Control

@onready var slider = $HSlider 

func _ready() -> void:
	self.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	if slider:
		slider.value = AudioConfig.volumen_db
		slider.process_mode = Node.PROCESS_MODE_ALWAYS
		slider.value_changed.connect(_on_h_slider_value_changed)
	AudioConfig.volumen_changed.connect(_on_volumen_changed)

func _on_volumen_changed(new_value: float):
	if slider:
		slider.set_value_no_signal(new_value)

func _on_h_slider_value_changed(value: float):
	print("Cambiando volumen desde MenuOpciones: ", value)
	AudioConfig.set_volumen(0, value)

func _on_atras_pressed() -> void:
	self.visible = false
	var menu_pausa = get_node("../../MenuPausa/PauseMenu/VBoxContainer")
	menu_pausa.get_parent().visible = true
