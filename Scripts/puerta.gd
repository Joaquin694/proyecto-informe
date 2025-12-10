extends Area2D

@export var escena_siguiente: String = "res://Escenas/escena_2.tscn"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var puerta_activa: bool = false
var jugador_en_puerta: bool = false
var puede_cambiar: bool = true

# 🔥 Escala base original del editor
var escala_original := Vector2.ONE

func _ready():
	print("\n=== INICIALIZANDO PUERTA ===")
	print("Escena siguiente: ", escena_siguiente)
	
	# Guardar escala original de forma segura
	if scale and scale != Vector2.ZERO:
		escala_original = scale
	else:
		escala_original = Vector2.ONE
		push_warning("⚠️ Scale de puerta era inválido, usando Vector2.ONE")
	
	print("Escala original guardada: ", escala_original)
	
	# Configurar colisiones
	collision_layer = 0b0000_0000_0000_1000  # Capa 4
	collision_mask = 0b0000_0000_0000_0001   # Detecta capa 1 (jugador)
	
	# Conectar señales
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Empezar invisible
	visible = false
	monitoring = false
	
	print("Puerta configurada correctamente")
	print("============================\n")
	
	# Buscar y conectar al boss
	call_deferred("_conectar_boss")

func _conectar_boss():
	await get_tree().process_frame
	
	var boss = get_tree().get_first_node_in_group("boss")
	if boss:
		if boss.has_signal("boss_derrotado"):
			# Verificar si ya está conectado para evitar duplicados
			if not boss.boss_derrotado.is_connected(_on_boss_muerto):
				boss.boss_derrotado.connect(_on_boss_muerto)
				print("✅ Puerta conectada al boss")
			else:
				print("⚠️ Puerta ya estaba conectada al boss")
		else:
			print("❌ Boss no tiene la señal boss_derrotado")
	else:
		print("⚠️ No se encontró el boss (normal si no hay boss en esta escena)")

func _on_boss_muerto():
	print("🚪 ¡BOSS MUERTO! Mostrando puerta...")
	visible = true
	monitoring = true
	puerta_activa = true
	
	# 🔥 PROTECCIÓN: Asegurar que escala_original sea válida
	if escala_original == null or escala_original == Vector2.ZERO:
		escala_original = Vector2.ONE
		push_warning("⚠️ escala_original era inválida, usando Vector2.ONE")
	
	# Usar escala original como destino
	var escala_aparicion = escala_original * 0.5
	modulate.a = 0
	scale = escala_aparicion
	
	print("   Escala original: ", escala_original)
	print("   Escala aparición: ", escala_aparicion)
	
	# Animación suave usando la escala original como referencia
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", escala_original, 0.5)
	
	await tween.finished
	
	# Reproducir animación
	if anim and anim.sprite_frames:
		if anim.sprite_frames.has_animation("abierta"):
			anim.play("abierta")
		elif anim.sprite_frames.has_animation("default"):
			anim.play("default")
	
	print("✅ Puerta ACTIVA y lista")

func _on_body_entered(body):
	if body.is_in_group("player") and puerta_activa:
		jugador_en_puerta = true
		print("✅ ¡JUGADOR DENTRO! Presiona E o ENTER")

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_en_puerta = false
		print("❌ Jugador salió de la puerta")

func _unhandled_input(event):
	if not jugador_en_puerta or not puerta_activa or not puede_cambiar:
		return
	
	var activar = false
	
	if event.is_action_pressed("ui_accept"):
		activar = true
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_E, KEY_ENTER]:
			activar = true
	
	if activar:
		puede_cambiar = false
		cambiar_escena()

func cambiar_escena():
	print("\n🚪🚪🚪 CAMBIANDO A ESCENA 🚪🚪🚪")
	print("Destino: ", escena_siguiente)
	
	set_process_unhandled_input(false)
	
	# Verificar que la escena existe
	if not ResourceLoader.exists(escena_siguiente):
		push_error("❌ ERROR: La escena no existe: ", escena_siguiente)
		puede_cambiar = true  # Permitir reintentar
		return
	
	# Detener música si existe
	var music_player = get_node_or_null("/root/MusicPlayer")
	if music_player and music_player.has_method("stop_music"):
		music_player.stop_music()
		print("🔇 Música detenida")
	
	# Cambiar escena
	var error = get_tree().change_scene_to_file(escena_siguiente)
	
	if error != OK:
		push_error("❌ ERROR al cambiar escena. Código: ", error)
		puede_cambiar = true
	else:
		print("✅ ¡Cambio de escena iniciado!")
