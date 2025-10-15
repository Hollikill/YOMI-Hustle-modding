extends "res://SoupModOptions/ModOptions.gd"

func _ready():
	print("Loaded stylesteal mod menu")
	var menu = generate_menu("stylesteal", "StyleSteal")
	menu.add_bool("copy", "Copy opponent's style", true)
	menu.add_bool("invert", "Invert colors when copying style", true)
	menu.add_bool("grayscale", "Grayscale colors when copying style", true)
	menu.add_number_slider("grayscale_factor", "How grayscale to turn the style", 6, {min_value=2,max_value=10})
	menu.add_bool("save", "Save style after copying", true)
	add_menu(menu)
