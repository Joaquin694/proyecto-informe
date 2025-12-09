extends Node

var previous_scene = ""
var current_level = ""

func get_current_level() -> String:
	return current_level

func set_current_level(path: String):
	current_level = path
