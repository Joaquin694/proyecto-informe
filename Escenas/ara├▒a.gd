extends CharacterBody2D

var vida = 50

func recibir_daño(cantidad):
	vida -= cantidad
	print("Vida de la araña:", vida)
	if vida <= 0:
		queue_free()
