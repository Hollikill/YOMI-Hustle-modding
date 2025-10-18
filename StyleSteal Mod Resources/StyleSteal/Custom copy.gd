extends "res://Custom.gd"

var option_copy = true
var option_save = true
var option_invert = true
var option_grayscale = true
var option_grayscale_factor = 5

func save_player_style(style, player_name):
	var style_save = style.duplicate(true)
	if style_save.get("style_name") != null:
		style_save["style_name"] = str(player_name) + "_" + style_save.get("style_name")
	make_custom_folder()
	var file = File.new()
	var filename_ = "user://custom/" + str(player_name) + "_" + style.style_name + ".style"
	file.open(filename_, File.WRITE)
	file.store_var(style_save, true)
	file.close()
	return filename_

func stylesteal_update_settings():
#	print("updated settings")
	var option = get_tree().get_root().get_node_or_null("Main/ModOptions")
	if option != null:
		option_copy = option.get_setting("stylesteal","copy")
		option_save = option.get_setting("stylesteal","save")
		option_save_type = option.get_setting("stylesteal","save_type")

		option_invert = option.get_setting("stylesteal","invert")
		option_grayscale = option.get_setting("stylesteal","grayscale")
		option_grayscale_factor = option.get_setting("stylesteal","grayscale_factor")

		option_tint_color = option.get_setting("stylesteal","tint_color")
		option_tint_red = option.get_setting("stylesteal","tint_red")
		option_tint_green = option.get_setting("stylesteal","tint_green")
		option_tint_blue = option.get_setting("stylesteal","tint_blue")

#	Below are custom functions to deal with color changing
#   ughhh.... i realized I could just use Color() but it's too late now. fix if i come back to this
func alter_style(styleToCopy):
	var style = styleToCopy.duplicate(true)

#	base colors
	if style.get("character_color") != null:
		var vec3 = alter_color(style.get("character_color"))
		style["character_color"][0] = vec3[0]
		style["character_color"][1] = vec3[1]
		style["character_color"][2] = vec3[2]
	if style.get("extra_color_1") != null:
		var vec3 = alter_color(style.get("extra_color_1"))
		style["extra_color_1"][0] = vec3[0]
		style["extra_color_1"][1] = vec3[1]
		style["extra_color_1"][2] = vec3[2]
	if style.get("extra_color_2") != null:
		var vec3 = alter_color(style.get("extra_color_2"))
		style["extra_color_2"][0] = vec3[0]
		style["extra_color_2"][1] = vec3[1]
		style["extra_color_2"][2] = vec3[2]
	if style.get("outline_color") != null:
		var vec3 = alter_color(style.get("outline_color"))
		style["outline_color"][0] = vec3[0]
		style["outline_color"][1] = vec3[1]
		style["outline_color"][2] = vec3[2]

#	Legacy ADV+ check
	if style.get("aura_settings") is Array:
		for aura in style.get("aura_settings"):
			alter_style_aura(aura)
#	vanilla aura
	else:
		if style.get("aura_settings") != null:
			alter_style_aura(style.get("aura_settings"))

#	ADV+ revamp auras
	if style.get("adv_aura") is Array:
		for aura in style.get("adv_aura"):
			alter_style_aura(aura)
	else:
		if style.get("adv_aura") != null:
			alter_style_aura(style.get("adv_aura"))
	
	return style

func alter_style_aura(aura):
	if aura.get("end_color") != null:
		var vec3 = alter_color(aura.get("end_color"))
		aura["end_color"][0] = vec3[0]
		aura["end_color"][1] = vec3[1]
		aura["end_color"][2] = vec3[2]
	if aura.get("mid_color") != null:
		var vec3 = alter_color(aura.get("mid_color"))
		aura["mid_color"][0] = vec3[0]
		aura["mid_color"][1] = vec3[1]
		aura["mid_color"][2] = vec3[2]
	if aura.get("start_color") != null:
		var vec3 = alter_color(aura.get("start_color"))
		aura["start_color"][0] = vec3[0]
		aura["start_color"][1] = vec3[1]
		aura["start_color"][2] = vec3[2]

func alter_color(baseColor):
	var color = Vector3(baseColor[0], baseColor[1], baseColor[2])
	if option_invert:
		color = invertRGB(color)
	if option_grayscale:
		var oklchColor = toOklch(toOklab(color))
		# reduce chroma by an order of magnitude
		oklchColor.y = oklchColor.y/ option_grayscale_factor
		color = toRGB(toOklab_back(oklchColor))
	if option_tint:
		color.x = clamp(color.x*0.5, 0, 1)
		color.y = clamp(color.y*0.5, 0, 1)
		color.z = clamp(color.z*0.5, 0, 1)
		var colorTint = Color(option_tint_red/255, option_tint_green/255, option_tint_blue/255, 1)
	return color

func invertRGB(vec):
	return Vector3( 1-vec.x, 1-vec.y, 1-vec.z)

func toOklab(vec):
	var l = 0.4122214708 * vec.x + 0.5363325363 * vec.y + 0.0514459929 * vec.z
	var m = 0.2119034982 * vec.x + 0.6806995451 * vec.y + 0.1073969566 * vec.z
	var s = 0.0883024619 * vec.x + 0.2817188376 * vec.y + 0.6299787005 * vec.z

	var l_ = pow(l, 1.0/3.0)
	var m_ = pow(m, 1.0/3.0)
	var s_ = pow(s, 1.0/3.0)

	var L = 0.2104542553*l_ + 0.7936177850*m_ - 0.0040720468*s_
	var A = 1.9779984951*l_ - 2.4285922050*m_ + 0.4505937099*s_
	var B = 0.0259040371*l_ + 0.7827717662*m_ - 0.8086757660*s_
	
	return Vector3(L, A, B)

func toOklch(vec):
	var chroma = sqrt((vec.y*vec.y) + (vec.z*vec.z))
	var hue = atan2(vec.z, vec.y)
	
	return Vector3(vec.x, chroma, hue)

func toOklab_back(vec):
	var a = vec.y * cos(vec.z)
	var b = vec.y * sin(vec.z)
	
	return Vector3(vec.x, a, b)

func toRGB(vec):
	var A = vec.y
	var B = vec.z

	var l_ = vec.x + 0.3963377774 * A + 0.2158037573 * B;
	var m_ = vec.x - 0.1055613458 * A - 0.0638541728 * B;
	var s_ = vec.x - 0.0894841775 * A - 1.2914855480 * B;

	var l = l_*l_*l_;
	var m = m_*m_*m_;
	var s = s_*s_*s_;

	return Vector3( +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s, -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s, -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)


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