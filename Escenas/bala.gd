extends Area2D

const SPEED = 300
var damage = 20  # Daño por bala

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	position += transform.x * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("enemigos"):
		body.recibir_daño(damage)
		queue_free()  # La bala desaparece al impactar

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
