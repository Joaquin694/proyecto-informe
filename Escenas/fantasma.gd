extends CharacterBody2D

var vida = 50

func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida del fantasma:", vida)
	if vida <= 0:
		queue_free()
