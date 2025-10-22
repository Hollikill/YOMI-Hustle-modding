extends Node

func _init(modLoader = ModLoader):
	var dir = Directory.new()
	modLoader.installScriptExtension("res://StyleModifiers/CharacterSelect.gd")
	modLoader.installScriptExtension("res://StyleModifiers/Custom.gd")
	if dir.dir_exists("res://SoupModOptions/"):
		modLoader.installScriptExtension("res://StyleModifiers/Options.gd")
