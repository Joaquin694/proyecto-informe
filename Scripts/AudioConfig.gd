extends Node

var volumen_db: float = 0.0

func set_volumen(bus, valor_db):
	volumen_db = valor_db
	AudioServer.set_bus_volume_db(bus, valor_db)
