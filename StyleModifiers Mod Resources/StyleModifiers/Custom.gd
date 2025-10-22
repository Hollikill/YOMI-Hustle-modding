extends "res://Custom.gd"

var option_copy = true
var option_modify_self = true

var option_invert = false

var option_grayscale = false
var option_grayscale_factor = 5

var option_tint = false
var option_tint_red = 255
var option_tint_green = 128
var option_tint_blue = 0

# load mod menu options
func stylemodifiers_update_settings():
#	print("updated settings")
	var option = get_tree().get_root().get_node_or_null("Main/ModOptions")
	if option != null:
		option_copy = option.get_setting("stylemodifiers","copy")
		option_copy = option.get_setting("stylemodifiers","modify_self")

		option_invert = option.get_setting("stylemodifiers","invert")
		option_grayscale = option.get_setting("stylemodifiers","grayscale")
		option_grayscale_factor = option.get_setting("stylemodifiers","grayscale_factor")

		option_tint = option.get_setting("stylemodifiers","tint")
		option_tint_red = option.get_setting("stylemodifiers","tint_red")
		option_tint_green = option.get_setting("stylemodifiers","tint_green")
		option_tint_blue = option.get_setting("stylemodifiers","tint_blue")

#	Below are custom functions to deal with color changing
#   ughhh.... i realized I could just use Color() but it's too late now. fix if i come back to this
func alter_style(styleToCopy):
	var style = styleToCopy.duplicate(true)

#	base colors
	if style.get("character_color") != null:
		var color = alter_color(style.get("character_color"))
		style["character_color"] = color
	if style.get("extra_color_1") != null:
		var color = alter_color(style.get("extra_color_1"))
		style["extra_color_1"] = color
	if style.get("extra_color_2") != null:
		var color = alter_color(style.get("extra_color_2"))
		style["extra_color_2"] = color
	if style.get("outline_color") != null:
		var color = alter_color(style.get("outline_color"))
		style["outline_color"] = color

#	Legacy ADV+ check
	if style.get("aura_settings") is Array:
		for aura in style.get("aura_settings"):
			alter_style_aura(aura)
#	vanilla aura
	elif style.get("aura_settings") != null:
			alter_style_aura(style.get("aura_settings"))

#	ADV+ revamp auras
	if style.get("adv_aura") is Array:
		for aura in style.get("adv_aura"):
			alter_style_aura(aura)
	elif style.get("adv_aura") != null:
		alter_style_aura(style.get("adv_aura"))
	
	return style

func alter_style_aura(aura):
	if aura.get("end_color") != null:
		var color = alter_color(aura.get("end_color"))
		aura["end_color"] = color
	if aura.get("mid_color") != null:
		var color = alter_color(aura.get("mid_color"))
		aura["mid_color"] = color
	if aura.get("start_color") != null:
		var color = alter_color(aura.get("start_color"))
		aura["start_color"] = color

func alter_color(baseColor):
	var color = Color(baseColor[0], baseColor[1], baseColor[2])
	if option_invert:
		color = color.inverted()
	if option_grayscale:
		var oklchColor = toOklch(toOklab(color))
		# reduce chroma by an order of magnitude
		oklchColor.y = oklchColor.y / option_grayscale_factor
		color = toRGB(toOklab_back(oklchColor))
	if option_tint:
		var tint_color = Color(option_tint_red/255, option_tint_green/255, option_tint_blue/255)
		color = tintColor(color, tint_color, 1)
	return Color(color.r, color.g, color.b, baseColor.a)

func tintColor(color, tint_color, tint_factor):
	var oklchColor = toOklch(toOklab(color))
	oklchColor.y = 0
	var color_grayed = toRGB(toOklab_back(oklchColor))

	var oklabColor = toOklab(color)

	var tint_oklabColor = toOklab(tint_color)
	tint_oklabColor.x = oklabColor.x
	var tint_color_adjusted = toRGB(tint_oklabColor)

	var color_adjusted = Color(color_grayed.r*(1-tint_factor), color_grayed.g*(1-tint_factor), color_grayed.b*(1-tint_factor))
	tint_color_adjusted = Color(tint_color_adjusted.r*tint_factor, tint_color_adjusted.g*tint_factor, tint_color_adjusted.b*tint_factor)
#	var tint_color_adjusted = Color(tint_color.r*tint_factor, tint_color.g*tint_factor, tint_color.g*tint_factor)
	
	return Color(color_adjusted.r + tint_color_adjusted.r, color_adjusted.g + tint_color_adjusted.g, color_adjusted.b + tint_color_adjusted.b)
	

#func invertRGB(color):
#	return Color( 1-color.r, 1-color.g, 1-color.b)

func toOklab(color):
	var l = 0.4122214708 * color.r + 0.5363325363 * color.g + 0.0514459929 * color.b
	var m = 0.2119034982 * color.r + 0.6806995451 * color.g + 0.1073969566 * color.b
	var s = 0.0883024619 * color.r + 0.2817188376 * color.g + 0.6299787005 * color.b

	var l_ = pow(l, 1.0/3.0)
	var m_ = pow(m, 1.0/3.0)
	var s_ = pow(s, 1.0/3.0)

	var L = 0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_
	var A = 1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_
	var B = 0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_
	
	return Vector3(L, A, B)

func toOklch(color):
	var chroma = sqrt((color.y*color.y) + (color.z*color.z))
	var hue = atan2(color.z, color.y)
	
	return Vector3(color.x, chroma, hue)

func toOklab_back(color):
	var a = color.y * cos(color.z)
	var b = color.y * sin(color.z)
	
	return Vector3(color.x, a, b)

func toRGB(color):
	var A = color.y
	var B = color.z

	var l_ = color.x + 0.3963377774 * A + 0.2158037573 * B;
	var m_ = color.x - 0.1055613458 * A - 0.0638541728 * B;
	var s_ = color.x - 0.0894841775 * A - 1.2914855480 * B;

	var l = l_*l_*l_;
	var m = m_*m_*m_;
	var s = s_*s_*s_;

	return Color( +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s, -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s, -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)


##   diagnostic fucntions I used to figure out file structure
#func savePlaintextDataStructure(structure, identifier):
#	make_custom_folder()
#	var file = File.new()
#	var filename_ = "user://custom/structures/" + str(int(Time.get_unix_time_from_system())) + "_" + identifier + ".txt"
#	file.open(filename_, File.WRITE)
#	file.store_string(iterateHolder(structure))
#	file.close()
#	return filename_
#
#func iterateHolder(holder, prefix=""):
#	var output = ""
#	if holder is Dictionary:
#		for item in holder:
#			output += prefix + "" + str(item) + "\n"
#			if holder.get(item) != null:
#				var item_value = holder.get(item)
#				if item_value is Dictionary or item_value is Array:
#					output += iterateHolder(item_value, prefix+" -- ")
#				else:
#					output += prefix + "    = " + str(item_value) + "\n"
#	elif holder is Array:
#		for item in holder.size():
#			output += prefix + "[" + str(item) + "]\n"
#			if holder[item] != null:
#				if holder[item] is Dictionary or holder[item] is Array:
#					output += iterateHolder(holder[item], prefix+" -- ")
#				else:
#					output += prefix + "    = " + str(holder[item]) + "\n"
#	elif holder != null:
#		output += prefix + "" + str(holder) + "\n"
#	return output