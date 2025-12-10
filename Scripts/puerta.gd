extends Area2D

@export var escena_siguiente: String = "res://Escenas/escena_2.tscn"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var puerta_activa: bool = false
var jugador_en_puerta: bool = false
var puede_cambiar: bool = true

func _ready():
	# Configurar colisiones
	collision_layer = 0b0000_0000_0000_1000  # Capa 4
	collision_mask = 0b0000_0000_0000_0001   # Detecta capa 1 (jugador)
	
	# Conectar señales
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Empezar invisible
	visible = false
	monitoring = false
	
	# Buscar y conectar al boss
	call_deferred("_conectar_boss")

func _conectar_boss():
	await get_tree().process_frame
	
	var boss = get_tree().get_first_node_in_group("boss")
	if boss:
		if boss.has_signal("boss_derrotado"):
			boss.boss_derrotado.connect(_on_boss_muerto)
			print("✅ Puerta conectada al boss")
		else:
			print("❌ Boss no tiene la señal boss_derrotado")
	else:
		print("❌ No se encontró el boss")

func _on_boss_muerto():
	print("🚪 ¡BOSS MUERTO! Mostrando puerta...")
	
	visible = true
	monitoring = true
	puerta_activa = true
	
	# Animación de aparición
	modulate.a = 0
	scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)
	
	await tween.finished
	
	# Reproducir animación "abierta"
	if anim and anim.sprite_frames:
		if anim.sprite_frames.has_animation("abierta"):
			anim.play("abierta")
			print("🎬 Animación 'abierta' reproducida")
		else:
			print("⚠️ No existe animación 'abierta', intentando 'default'")
			if anim.sprite_frames.has_animation("default"):
				anim.play("default")
	
	print("✅ Puerta ACTIVA y lista")

func _on_body_entered(body):
	if body.is_in_group("player") and puerta_activa:
		jugador_en_puerta = true
		print("✅ ¡JUGADOR DENTRO! Presiona E o ENTER")

func _on_body_exited(body):
	if body.is_in_group("player"):
		jugador_en_puerta = false
		print("❌ Jugador salió")

func _unhandled_input(event):
	if not jugador_en_puerta or not puerta_activa or not puede_cambiar:
		return
	
	# Detectar teclas de interacción
	var activar = false
	
	if event.is_action_pressed("ui_accept"):
		activar = true
		print("✅ ui_accept presionado")
	
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			activar = true
			print("✅ Tecla E presionada")
		elif event.keycode == KEY_ENTER:
			activar = true
			print("✅ Tecla ENTER presionada")
	
	if activar:
		puede_cambiar = false
		cambiar_escena()

func cambiar_escena():
	print("🚪🚪🚪 CAMBIANDO A ESCENA: ", escena_siguiente, " 🚪🚪🚪")
	
	set_process_unhandled_input(false)
	
	if not ResourceLoader.exists(escena_siguiente):
		print("❌ ERROR: La escena no existe: ", escena_siguiente)
		return
	
	print("🔄 Ejecutando change_scene_to_file...")
	
	# Cambiar escena directamente (sin fade por ahora)
	var error = get_tree().change_scene_to_file(escena_siguiente)
	
	if error != OK:
		print("❌ ERROR al cambiar escena. Código: ", error)
	else:
		print("✅ ¡Cambio de escena exitoso!")
