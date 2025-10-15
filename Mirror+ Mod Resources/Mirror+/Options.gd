extends "res://SoupModOptions/ModOptions.gd"

func _ready():
	print("Loaded mirror+ mod menu")
	var menu = generate_menu("mirrorplus", "Mirror+")
	menu.add_bool("copystyle", "Copy opponent's style", true)
	menu.add_bool("copycharacter", "Copy opponent's character pick", true)
	add_menu(menu)
