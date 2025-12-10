extends CanvasLayer

@onready var barra_vida: ProgressBar = $BarraVidaJugador
@onready var label_municion: Label = $LabelMunicion
@onready var icono_corazon: AnimatedSprite2D = $Corazon/IconoCorazon

var vida_anterior = 100

func _ready():
	# Agregar al grupo para acceso por grupo (opcional, pero útil)
	add_to_group("hud")
	
	# Configurar valores iniciales
	if barra_vida:
		barra_vida.max_value = 100
		barra_vida.value = 100
		actualizar_estilo_barra(100, 100)
		
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0, 0, 0, 0.8)
		style_bg.set_border_width_all(3)
		style_bg.border_color = Color(0, 0, 0, 1)
		style_bg.set_corner_radius_all(5)
		barra_vida.add_theme_stylebox_override("background", style_bg)
	
	if icono_corazon:
		icono_corazon.play("0")
		print("✅ Corazón inicializado en animación '0' (lleno)")
	else:
		print("❌ ERROR: No se encontró IconoCorazon")
	
	# Conectar señal para detectar cambios de escena
	get_tree().root.child_entered_tree.connect(_on_scene_changed)
	
	# Verificar escena actual al iniciar
	verificar_visibilidad_hud()
	
	print("🎮 HUD inicializado como Autoload")

# ===== SISTEMA DE VISIBILIDAD =====

func verificar_visibilidad_hud():
	await get_tree().process_frame
	
	# Si hay un jugador en la escena, mostrar HUD
	var jugador = get_tree().get_first_node_in_group("player")
	
	if jugador:
		mostrar_hud()
	else:
		ocultar_hud()

func _on_scene_changed(node):
	await get_tree().process_frame
	verificar_visibilidad_hud()

func mostrar_hud():
	visible = true
	print("🎮 HUD visible")

func ocultar_hud():
	visible = false
	print("🚫 HUD oculto")

# ===== ACTUALIZACIÓN DE VIDA =====

func actualizar_vida(vida_actual: int, vida_maxima: int):
	if not barra_vida:
		print("⚠ ERROR: barra_vida no existe")
		return
	
	print("💚 Actualizando HUD - Vida: ", vida_actual, "/", vida_maxima)
	
	vida_anterior = barra_vida.value
	barra_vida.max_value = vida_maxima
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(barra_vida, "value", vida_actual, 0.3)
	
	actualizar_estilo_barra(vida_actual, vida_maxima)
	actualizar_animacion_corazon(vida_actual, vida_maxima)
	
	if vida_actual < vida_anterior:
		efecto_daño()
		if icono_corazon:
			animar_corazon()

func actualizar_animacion_corazon(vida_actual: int, vida_maxima: int):
	if not icono_corazon:
		return
	
	var porcentaje = float(vida_actual) / float(vida_maxima)
	var animacion = "0"
	
	if porcentaje > 0.83:
		animacion = "0"
	elif porcentaje > 0.66:
		animacion = "1"
	elif porcentaje > 0.50:
		animacion = "2"
	elif porcentaje > 0.33:
		animacion = "3"
	elif porcentaje > 0.16:
		animacion = "4"
	else:
		animacion = "5"
	
	icono_corazon.play(animacion)
	print("❤ Corazón actualizado a animación: ", animacion)

func actualizar_estilo_barra(vida_actual: int, vida_maxima: int):
	if not barra_vida:
		return
		
	var porcentaje = float(vida_actual) / float(vida_maxima)
	
	var style_fill = StyleBoxFlat.new()
	style_fill.set_corner_radius_all(5)
	
	if porcentaje > 0.6:
		style_fill.bg_color = Color(0.2, 0.8, 0.3)
	elif porcentaje > 0.4:
		style_fill.bg_color = Color(0.6, 0.9, 0.3)
	elif porcentaje > 0.25:
		style_fill.bg_color = Color(1.0, 0.7, 0.2)
	elif porcentaje > 0.1:
		style_fill.bg_color = Color(1.0, 0.4, 0.2)
	else:
		style_fill.bg_color = Color(0.9, 0.2, 0.2)
	
	barra_vida.add_theme_stylebox_override("fill", style_fill)

# ===== ACTUALIZACIÓN DE MUNICIÓN =====

func actualizar_municion(balas_actuales: int, balas_reserva: int, recargando: bool):
	if not label_municion:
		return
	
	if recargando:
		label_municion.text = "RECARGANDO..."
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(label_municion, "modulate:a", 0.3, 0.5)
		tween.tween_property(label_municion, "modulate:a", 1.0, 0.5)
	else:
		label_municion.text = str(balas_actuales) + " / " + str(balas_reserva)
		label_municion.modulate.a = 1.0
		
		if balas_actuales <= 5:
			label_municion.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		elif balas_actuales <= 10:
			label_municion.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
		else:
			label_municion.add_theme_color_override("font_color", Color(1, 1, 1))

# ===== EFECTOS VISUALES =====

func efecto_daño():
	if not barra_vida:
		return
		
	var tween = create_tween()
	tween.tween_property(barra_vida, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(barra_vida, "modulate", Color(1, 1, 1), 0.3)

func animar_corazon():
	if not icono_corazon:
		return
	
	var tween = create_tween()
	tween.tween_property(icono_corazon, "modulate", Color(1, 0.3, 0.3), 0.1)
	tween.tween_property(icono_corazon, "modulate", Color(1, 1, 1), 0.3)
