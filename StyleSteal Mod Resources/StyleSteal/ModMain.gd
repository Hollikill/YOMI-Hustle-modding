extends Node

func _init(modLoader = ModLoader):
	var dir = Directory.new()
	modLoader.installScriptExtension("res://StyleSteal/CharacterSelect.gd")
	modLoader.installScriptExtension("res://StyleSteal/Custom.gd")
	if dir.dir_exists("res://SoupModOptions/"):
		modLoader.installScriptExtension("res://StyleSteal/Options.gd")
