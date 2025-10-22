extends "res://ui/CSS/CharacterSelect.gd"

var retrieved_style = null

func _on_network_character_selected(player_id, character, style = null):
	print("P" + str(player_id) + " selected character hook")
	selected_characters[player_id] = character
	selected_styles[player_id] = style
	var text_selectinglabel_original = null

	#   grabs and converts opponents style
	if player_id != current_player:
		#	get settings
		Custom.stylesteal_update_settings()

		#   switches selection text to indicate to the user that the mod is working
		text_selectinglabel_original = $"%SelectingLabel".text
		$"%SelectingLabel".text = "LOADED OPPONENT STYLE"
		$"%SelectingLabel".modulate = Color.green
		
		var opponentNetworkID = -1
		if Network.network_id == Network.network_ids[1]:
			opponentNetworkID = Network.network_ids[2]
		else:
			opponentNetworkID = Network.network_ids[1]
			
		if Custom.option_copy && selected_styles[current_player] == null:
			retrieved_style = Custom.alter_style(style)
			selected_styles[current_player] = retrieved_style
			if current_player == 1:
				$"%P1Display"._on_style_selected(retrieved_style)
			else:
				$"%P2Display"._on_style_selected(retrieved_style)
		
#		if Custom.option_save:
#			match int(Custom.option_save_type):
#				0:
#					Custom.save_player_style(style, Network.players[opponentNetworkID])
#				1:
#					Custom.save_player_style(retrieved_style, Network.players[opponentNetworkID]+"_Mod")
#				2:
#					Custom.save_player_style(style, Network.players[opponentNetworkID])
#					Custom.save_player_style(retrieved_style, Network.players[opponentNetworkID]+"_Mod")
		
	if Network.is_host() and player_id == Network.player_id:
		$"%GameSettingsPanelContainer".hide()
	if selected_characters[1] != null and selected_characters[2] != null:

		if Network.is_host():
			Network.rpc_("send_match_data", get_match_data())

func buffer_select(button):
	var data = get_character_data(button)
	var display_data = get_display_data(button)
	display_character(current_player, display_data)
	selected_characters[current_player] = data

	#	get settings
	Custom.stylesteal_update_settings()
	
	if singleplayer and current_player == 1:
		current_player = 2
		$"%SelectingLabel".text = "P2 SELECT YOUR CHARACTER"
		$"%SelectingLabel".modulate = Color.red
	else :
		for button in buttons:
			button.disabled = true
		if singleplayer:
			$"%GoButton".disabled = false
	if not singleplayer:
		var style_grabbed = $"%P1Display".selected_style if current_player == 1 else $"%P2Display".selected_style		
		if retrieved_style != null:
			Network.select_character(data, retrieved_style)
		elif Custom.option_modify_self and style_grabbed != null:
			retrieved_style = Custom.alter_style(style_grabbed)
			selected_styles[current_player] = retrieved_style
			if current_player == 1:
				$"%P1Display"._on_style_selected(retrieved_style)
			else:
				$"%P2Display"._on_style_selected(retrieved_style)
			Network.select_character(data, retrieved_style)
		else:
			Network.select_character(data, $"%P1Display".selected_style if current_player == 1 else $"%P2Display".selected_style)
