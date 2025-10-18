extends "res://SoupModOptions/ModOptions.gd"

func _ready():
	print("Loaded stylesteal mod menu")
	var menu = generate_menu("stylesteal", "StyleSteal")

	menu.add_bool("copy", "Copy opponent's style", true)

	menu.add_bool("save", "Save style after copying", true)

	var save_type_dropdown = menu.add_dropdown_menu("save_type", "Which styles to save?")
	save_type_dropdown.add_item("Save unmodified style")
	save_type_dropdown.add_item("Save modified style")
	save_type_dropdown.add_item("Save both styles")

	menu.add_label("--spacer", "")

	menu.add_label("label1", "Modifiers Applied to Copied Style During Match")

	menu.add_bool("invert", "Invert the style colors", false)

	menu.add_bool("grayscale", "Grayscale the style colors", false)
	menu.add_number_slider("grayscale_factor", "How grayscale to turn the style", 5, {min_value=1,max_value=10})

	menu.add_bool("tint", "Tint the style colors", false)
	menu.add_label("label2", "The sliders below control the RGB values of the tint")
	menu.add_number_slider("tint_red", "Red value of tint color", 255, {min_value=0,max_value=255})
	menu.add_number_slider("tint_green", "Green value of tint color", 128, {min_value=0,max_value=255})
	menu.add_number_slider("tint_blue", "Blue value of tint color", 0, {min_value=0,max_value=255})

	add_menu(menu)
