extends Node

signal llaves_actualizadas(cantidad_actual: int, cantidad_requerida: int)
signal puerta_desbloqueada

var llaves_totales: int = 0
var llaves_requeridas: int = 2

func _ready():
	print("\n🎮 GameManager inicializado")
	llaves_totales = 0
	print("🔑 Sistema de llaves: 0/", llaves_requeridas, "\n")

func recoger_llave() -> void:
	llaves_totales += 1
	
	print("\n🔑 ===== LLAVE RECOGIDA =====")
	print("Total: ", llaves_totales, "/", llaves_requeridas)
	
	llaves_actualizadas.emit(llaves_totales, llaves_requeridas)
	
	if llaves_totales >= llaves_requeridas:
		print("✅ ¡TODAS LAS LLAVES RECOGIDAS!")
		print("🔔 Emitiendo señal puerta_desbloqueada")
		puerta_desbloqueada.emit()
	
	print("============================\n")

func reiniciar_llaves() -> void:
	llaves_totales = 0
	llaves_actualizadas.emit(llaves_totales, llaves_requeridas)
	print("🔄 Llaves reiniciadas: 0/", llaves_requeridas)

func tiene_todas_las_llaves() -> bool:
	return llaves_totales >= llaves_requeridas

func get_llaves_actuales() -> int:
	return llaves_totales

func get_llaves_requeridas() -> int:
	return llaves_requeridas
