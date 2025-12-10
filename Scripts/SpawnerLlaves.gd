extends Node2D

@export var llave_scene: PackedScene
@export var cantidad_llaves: int = 2

var spawn_positions: Array[Marker2D] = []

func _ready():
	print("\n🎯 ===== SPAWNER DE LLAVES =====")
	_detectar_spawn_positions()
	await get_tree().create_timer(0.1).timeout
	_spawn_llaves()

func _detectar_spawn_positions() -> void:
	spawn_positions.clear()
	
	for child in get_children():
		if child is Marker2D:
			spawn_positions.append(child)
	
	print("📍 Posiciones detectadas: ", spawn_positions.size())
	
	if spawn_positions.is_empty():
		push_error("❌ No hay Marker2D hijos del SpawnerLlaves")

func _spawn_llaves() -> void:
	if not llave_scene:
		push_error("❌ Asigna la escena de llave en el inspector")
		return
	
	if spawn_positions.is_empty():
		push_error("❌ No hay posiciones de spawn")
		return
	
	var cantidad = min(cantidad_llaves, spawn_positions.size())
	var indices = range(spawn_positions.size())
	indices.shuffle()
	
	print("🔑 Spawneando ", cantidad, " llaves...\n")
	
	for i in range(cantidad):
		var marker = spawn_positions[indices[i]]
		_spawnear_llave(marker, i + 1)
	
	print("================================\n")

func _spawnear_llave(marker: Marker2D, numero: int) -> void:
	var llave = llave_scene.instantiate()
	
	# Obtener el nivel actual
	var nivel = get_tree().current_scene
	nivel.add_child(llave)
	
	# Esperar un frame para que se procese
	await get_tree().process_frame
	
	# Posicionar la llave
	llave.global_position = marker.global_position
	
	print("  ✓ Llave ", numero, " → ", marker.name)
	print("    Posición: ", marker.global_position)
