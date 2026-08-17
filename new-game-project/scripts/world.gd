extends Node
class_name World

@onready var title_screen: CanvasLayer = $TitleScreen

signal player_colour

const PORT = 9999
const PlayerLoad = preload("res://scenes/player.tscn")

var enet_peer = ENetMultiplayerPeer.new()
var players = []

func _on_host_pressed() -> void:
	title_screen.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())
	$LobbyUI.show()
	
	player_colour.emit()

func _on_client_pressed() -> void:
	title_screen.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	player_colour.emit()

func add_player(peer_id):
	var player = PlayerLoad.instantiate()
	player.name = str(peer_id)
	$Players.add_child(player)

# Calls function to change scene with all player clients changing with it
func _on_start_pressed() -> void:
	if !multiplayer.is_server(): return
	modifiers_level.rpc()

@rpc("call_local", "reliable")	
func modifiers_level():
	get_tree().change_scene_to_file("res://scenes/modifiers_hud.tscn")
