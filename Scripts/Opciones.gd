extends Control

@onready var slider = $Volume/HSlider

func _ready():
	await get_tree().process_frame
	slider.value = AudioConfig.volumen_db
	AudioServer.set_bus_volume_db(0, AudioConfig.volumen_db)
	MusicPlayer.play_menu()

func volumen(bus_index,value):
	AudioServer.set_bus_volume_db(bus_index,value)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(SceneManager.previous_scene)

func _on_h_slider_value_changed(value):
	AudioConfig.set_volumen(0, value)
