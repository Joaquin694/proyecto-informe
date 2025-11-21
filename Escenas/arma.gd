extends Node2D

const BALA = preload("res://Escenas/bala.tscn")
@onready var aparicion_bala: Marker2D = $Marker2D


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	
	if rotation_degrees > 90 and  rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
	
	if Input.is_action_just_pressed("disparo"):
		var bullet_instance = BALA.instantiate()
		get_tree().root.add_child(bullet_instance)
		bullet_instance.global_position = aparicion_bala.global_position
		bullet_instance.rotation = rotation
