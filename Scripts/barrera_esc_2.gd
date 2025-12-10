extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null

var esta_desbloqueada: bool = false

func _ready():
	print("\n========== DEBUG BARRERA ==========")
	print("📍 Posición global: ", global_position)
	print("📍 Posición local: ", position)
	
	# Verificar CollisionShape2D
	if not collision:
		push_error("❌ CRÍTICO: No hay CollisionShape2D. Añade uno como hijo del StaticBody2D")
		return
	
	print("✅ CollisionShape2D encontrado")
	
	if not collision.shape:
		push_error("❌ CRÍTICO: CollisionShape2D no tiene Shape asignado")
		push_error("   Solución: Selecciona el CollisionShape2D y en Inspector → Shape → asigna RectangleShape2D")
		return
	
	print("✅ Shape asignado: ", collision.shape.get_class())
	
	if collision.shape is RectangleShape2D:
		var rect_shape = collision.shape as RectangleShape2D
		print("   📐 Tamaño: ", rect_shape.size)
		if rect_shape.size.x < 10 or rect_shape.size.y < 10:
			push_warning("⚠️ La colisión es muy pequeña: ", rect_shape.size)
	
	print("   🚫 Disabled antes de configurar: ", collision.disabled)
	
	# ============================================================
	# CONFIGURACIÓN CORRECTA - Capa 1 para paredes/obstáculos
	# ============================================================
	print("\n🔧 Configurando colisiones...")
	
	# Limpiar todas las capas primero
	collision_layer = 0
	collision_mask = 0
	
	# Configurar SOLO capa 1 (paredes/obstáculos)
	set_collision_layer_value(1, true)   # Barrera ESTÁ en capa 1
	set_collision_layer_value(2, false)  # Asegurar que no esté en otras capas
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, false)
	
	# NO necesita detectar nada (mask = 0)
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, false)
	set_collision_mask_value(4, false)
	
	# Confirmar valores finales
	collision_layer = 1  # Binario: 0001 = Solo capa 1
	collision_mask = 0   # Binario: 0000 = No detecta nada
	
	print("   ✓ Collision Layer: ", collision_layer, " (binario: ", String.num_int64(collision_layer, 2).pad_zeros(4), ")")
	print("   ✓ Collision Mask: ", collision_mask, " (binario: ", String.num_int64(collision_mask, 2).pad_zeros(4), ")")
	print("   ℹ️  El jugador con mask=1 SÍ detectará esta barrera")
	
	# FORZAR colisión habilitada
	collision.disabled = false
	print("   ✓ Colisión ACTIVADA (disabled = false)")
	
	# Visibilidad
	visible = true
	modulate = Color(1, 1, 1, 1)
	
	if sprite:
		sprite.visible = true
		print("✅ Sprite de reja visible")
	else:
		print("⚠️ No hay Sprite2D, pero la colisión funcionará")
	
	# Verificar GameManager
	if not GameManager:
		push_error("❌ GameManager no existe en el proyecto")
		return
	
	if GameManager.has_signal("puerta_desbloqueada"):
		GameManager.puerta_desbloqueada.connect(_on_desbloquear)
		print("✅ Conectado a GameManager.puerta_desbloqueada")
	else:
		push_error("❌ GameManager no tiene la señal 'puerta_desbloqueada'")
	
	# ============================================================
	# VERIFICACIÓN FINAL
	# ============================================================
	print("\n🔍 VERIFICACIÓN FINAL:")
	print("   • Barrera en Layer: ", collision_layer, " → Jugador debe tener 1 en su MASK ✓")
	print("   • Barrera Mask: ", collision_mask, " → Debe ser 0 ✓")
	print("   • Shape tipo: ", collision.shape.get_class())
	if collision.shape is RectangleShape2D:
		print("   • Shape tamaño: ", collision.shape.size)
	print("   • Disabled: ", collision.disabled, " → DEBE SER false ✓")
	print("   • Visible: ", visible)
	print("===================================\n")

func _on_desbloquear():
	if esta_desbloqueada:
		return
	
	esta_desbloqueada = true
	print("\n🔓 ===== DESBLOQUEANDO REJA =====")
	
	# Deshabilitar colisión INMEDIATAMENTE
	if collision:
		collision.disabled = true
		print("✅ Colisión DESHABILITADA - El jugador puede pasar")
	
	# Animación de apertura
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Parpadeo
	for i in range(4):
		tween.tween_property(self, "modulate:a", 0.3, 0.15).set_delay(i * 0.3)
		tween.tween_property(self, "modulate:a", 1.0, 0.15).set_delay(i * 0.3 + 0.15)
	
	# Deslizar hacia arriba (como reja que sube)
	tween.tween_property(self, "position:y", position.y - 150, 1.2).set_ease(Tween.EASE_IN_OUT)
	
	await tween.finished
	
	# Fade final
	var fade = create_tween()
	fade.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade.finished
	
	print("🗑️ Reja eliminada completamente")
	print("==================================\n")
	queue_free()
