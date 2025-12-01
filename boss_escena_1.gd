extends CharacterBody2D

# BORRA ESTA LÍNEA: "res://objeto_boss_1.gd" <--- Esto da error

@export var projectile_scene: PackedScene 

func _ready():
	# Asegúrate de que el nodo se llame exactamente "AttackTimer" en la escena
	if has_node("AttackTimer"):
		$AttackTimer.timeout.connect(_on_timer_timeout)
	else:
		print("ERROR: Falta el nodo AttackTimer en el Boss")

func _on_timer_timeout():
	lanzar_objeto_gigante()

func lanzar_objeto_gigante():
	if projectile_scene == null:
		print("ERROR: No has asignado la escena del proyectil en el Inspector")
		return
	
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var dir_vector = (player.global_position - global_position).normalized()
		# Accedemos a la variable 'direction' que creaste en el otro script
		projectile.direction = dir_vector 
		projectile.rotation = dir_vector.angle()
	
	# Usar 'call_deferred' es más seguro para evitar errores de físicas al añadir hijos
	get_tree().root.call_deferred("add_child", projectile)
