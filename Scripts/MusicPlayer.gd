extends AudioStreamPlayer

var musica_menu = preload("res://Audio/Michelle.mp3")
var musica_nivel = preload("res://Audio/In The Androgynous Dark.mp3")
var musica_game_over = preload("res://Audio/game-over-deep-male-voice-clip-352695.mp3")

func play_menu():
	if stream != musica_menu:
		stream = musica_menu
	if not playing:
		play()

func play_nivel():
	if stream !=musica_nivel:
		stream = musica_nivel
	if not playing:
		play()

func play_game_over():  
	if stream != musica_game_over:
		stream = musica_game_over
		play()
	elif not playing:
		play()

func stop_music():
	stop()
