extends Node

var volumen_db: float = 0.0

# Señal para notificar cambios de volumen a todos los sliders
signal volumen_changed(new_value)

func set_volumen(bus, valor_db):
	volumen_db = valor_db
	AudioServer.set_bus_volume_db(bus, valor_db)
	# Emitir la señal para que todos los sliders se actualicen
	volumen_changed.emit(valor_db)
