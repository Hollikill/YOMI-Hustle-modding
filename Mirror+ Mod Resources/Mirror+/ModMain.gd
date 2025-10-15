extends Node

func _init(modLoader = ModLoader):
	var dir = Directory.new()
	modLoader.installScriptExtension("res://Mirror+/Copy.gd")
	#modLoader.installScriptExtension("res://Mirror+/NetworkDetect.gd")
	if dir.dir_exists("res://SoupModOptions/"):
		modLoader.installScriptExtension("res://Mirror+/Options.gd")
