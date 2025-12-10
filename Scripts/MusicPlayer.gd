extends AudioStreamPlayer

var musica_menu = preload("res://Audio/Michelle.mp3")
var musica_nivel_1 = preload("res://Audio/In The Androgynous Dark.mp3")
var musica_nivel_2 = preload("res://Audio/AMs.mp3")
var musica_game_over = preload("res://Audio/game-over-deep-male-voice-clip-352695.mp3")


func play_menu():
	if stream != musica_menu:
		stream = musica_menu
	if not playing:
		play()


func play_nivel_1():
	if stream != musica_nivel_1:
		stream = musica_nivel_1
	if not playing:
		play()


func play_nivel_2():
	if stream != musica_nivel_2:
		stream = musica_nivel_2
	if not playing:
		play()


func play_game_over():
	if stream != musica_game_over:
		stream = musica_game_over
		play()
	elif not playing:
		play()


# ----------------------------------------------------------
# NUEVO → función genérica que reproduce la música del nivel
# ----------------------------------------------------------
func play_nivel():
	var scene = get_tree().current_scene
	if scene == null:
		print("ERROR: current_scene es null, usando nivel 1")
		play_nivel_1()
		return

	match scene.name:
		"escena_1":
			play_nivel_1()
		"escena_2":
			play_nivel_2()
		_:
			print("No se reconoce la escena, usando música de nivel 1")
			play_nivel_1()


func stop_music():
	stop()
