extends "res://SteamLobby.gd"

#   stripped version of cat's code from the Perfect Mirror mod
#   mod is at https://steamcommunity.com/sharedfiles/filedetails/?id=3296713084

#   this code is useless in the current iteration of the mod, but may become useful in the future

var OPPONENT_MIRROR_MOD = false

#   broadcasts to other mods that this user is using a mirror match mod
func sendMirrorModConfirmPacket(steam_id):
	_send_P2P_Packet(steam_id, {"pf_mod": null})

func challenge_user(user):
	sendMirrorModConfirmPacket(user.steam_id)

func _receive_challenge(steam_id, match_settings):
	sendMirrorModConfirmPacket(steam_id)

#   should flag that we are using a mirror-match mod
func _read_P2P_Packet_custom(readable):
	if readable.has("pf_mod"):
		OPPONENT_MIRROR_MOD = true
	else:
		OPPONENT_MIRROR_MOD = false
