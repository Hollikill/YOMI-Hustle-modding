extends "res://ui/CSS/CharacterSelect.gd"

#   options
var option_copycharacter = true
var option_copystyle = true

#   retrieved charcter and style
var retrieved_character = null
var retrieved_style = null

#   text variables
var text_selectionwhilecopying = ""
var text_basebeforeopponentselection = ""
var text_baseafteropponentselection = ""

func _on_network_character_selected(player_id, character, style = null):
	print("P" + str(player_id) + " selected character hook")
	selected_characters[player_id] = character
	selected_styles[player_id] = style
	#   stores the selections of opponent
	if player_id != current_player:
		#	store opponent's choices
		retrieved_character = character
		retrieved_style = style

		#   switches selection text to indicate to the user that the mod is working
		if option_copycharacter or option_copystyle:
			$"%SelectingLabel".text = text_baseafteropponentselection + text_selectionwhilecopying
			$"%SelectingLabel".modulate = Color.green
		
		#	display knowledge of opponent that gives no advantage
		if option_copycharacter:
			var data = get_display_data(character)
			display_character(player_id, data)
		if player_id == 1:
			$"%P1Display".load_last_style()
		else:
			$"%P2Display".load_last_style()
		
	if Network.is_host() and player_id == Network.player_id:
		$"%GameSettingsPanelContainer".hide()
	if selected_characters[1] != null and selected_characters[2] != null:

		if Network.is_host():
			Network.rpc_("send_match_data", get_match_data())

func init(singleplayer = true):
	show()
	emit_signal("opened")

#   grab options from mod options menu
	var option = get_tree().get_root().get_node_or_null("Main/ModOptions")
	if option != null:
		option_copycharacter = option.get_setting("mirrorplus","copycharacter")
		option_copystyle = option.get_setting("mirrorplus","copystyle")
	
#   ensure we don't use old opponent selections
	retrieved_character = null
	retrieved_style = null

	for button in buttons:
		button.disabled = false

	$"%GoButton".disabled = true
	$"%GoButton".show()
	self.singleplayer = singleplayer
	$"%GameSettingsPanelContainer".init(singleplayer)

	#   ensure the selection text will display correctly
	text_basebeforeopponentselection = "WAIT FOR OPPONENT TO SELECT CHARACTER"
	text_baseafteropponentselection = "SELECTING A CHARACTER WILL COPY OPPONENT'S "

	if option_copycharacter and option_copystyle:
		text_selectionwhilecopying = "CHARACTER AND STYLE"
	elif option_copycharacter:
		text_selectionwhilecopying = "CHARACTER"
	elif option_copystyle:
		text_selectionwhilecopying = "STYLE"
	else:
		text_basebeforeopponentselection = "SELECT YOUR CHARACTER"

	#alert user if the opponent is using this mod or cat's Perfect Mirror mod
#	if SteamLobby.OPPONENT_MIRROR_MOD:
#		$"%SelectingLabel".text = "NOT COPYING: OPPONENT USING INCOMPATIBLE MIRROR MATCH MOD"

	$"%SelectingLabel".text = "P1 SELECT YOUR CHARACTER" if singleplayer else text_basebeforeopponentselection
	$"%SelectingLabel".modulate = Color.dodgerblue
	if not singleplayer and (option_copycharacter or option_copystyle):
		$"%SelectingLabel".modulate = Color.red
	$"%P1Display".init()
	$"%P2Display".init()
	if Network.steam:
		$"%GameSettingsPanelContainer".hide()


	selected_styles = {
		1: null, 
		2: null
	}
	
	hovered_characters = {
		1: null, 
		2: null, 
	}

	selected_characters = {
		1: null, 
		2: null
	}
	
	current_player = 1 if singleplayer else Network.player_id
	
	if not singleplayer:
		if current_player == 1:
			if not option_copycharacter and not option_copystyle:
				$"%P2Display".set_enabled(false)
			$"%P1Display".load_last_style()
		else:
			if not option_copycharacter and not option_copystyle:
				$"%P1Display".set_enabled(false)
			$"%P2Display".load_last_style()
		$"%GoButton".hide()
	else:
		$"%P2Display".load_style_button.save_style = false
	$"%P1Display".load_last_style()
	pressed_button = null
	buttons = []
	for child in $"%CharacterButtonContainer".get_children():
		child.queue_free()
	for name in Global.name_paths:


		var button = preload("res://ui/CSS/CharacterButton.tscn").instance()
		if name in Global.characters_cache:
			button.character_scene = Global.get_cached_character(name)
#			print(name)
#			print(Global.get_cached_character(name))
		else:
			continue
		$"%CharacterButtonContainer".add_child(button)


		button.text = name
		buttons.append(button)
		if not button.is_connected("pressed", self, "_on_button_pressed"):
			button.connect("pressed", self, "_on_button_pressed", [button])
			button.connect("mouse_entered", self, "_on_button_mouse_entered", [button])
		$ButtonSoundPlayer.add_container($"%CharacterButtonContainer")
		$ButtonSoundPlayer.setup()
	_on_button_mouse_entered(buttons[0])

func get_character_data(button):
	var data = {}
	var scene = null
	if "CharacterButton" in button.name:
		scene = button.character_scene.instance()
	else:
		scene = Global.get_cached_character(button.name).instance()
	data["name"] = scene.name
	scene.free()
	return data

func get_display_data(button):
	var data = {}
	if not isCustomChar(button.name) or (button.name in loadedChars):
		var scene = null
		if "CharacterButton" in button.name:
			scene = button.character_scene.instance()
		else:
			scene = Global.get_cached_character(button.name).instance()
		data["name"] = scene.name
		data["portrait"] = scene.character_portrait
		scene.free()
	else:
		data["name"] = button.name
		data["portrait"] = charPortrait[button.name]
		if (button.name in errorMessage.keys()):
			data["name"] = errorMessage[button.name]
	return data

func _on_button_mouse_entered(button):
	var data = get_display_data(button)
	if retrieved_character != null and option_copycharacter:
		selected_characters[current_player] = retrieved_character
		data = get_display_data(selected_characters[current_player])
	display_character(current_player, data)
	if retrieved_style != null and option_copystyle:
		selected_styles[current_player] = retrieved_style
		if current_player == 1:
			$"%P1Display".load_last_style()
		else:
			$"%P2Display".load_last_style()
	pass

func _on_button_pressed(button):
	if btt_disableTimer > 0 or currentlyLoading:
		button.set_pressed_no_signal(false)
		return
	var miss = []
	if retrieved_character != null and option_copycharacter:
		button = selected_characters[current_player]
	if (isCustomChar(button.name)):
		loadThread = Thread.new()
		loadThread.start(self, "async_loadButtonChar", button)
	else:
		buffer_select(button)

	for button in buttons:
		button.set_pressed_no_signal(false)