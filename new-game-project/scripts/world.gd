extends Node
class_name World

@onready var title_screen: CanvasLayer = $TitleScreen

const PORT = 9999
const PlayerLoad = preload("res://scenes/player.tscn")

var enet_peer = ENetMultiplayerPeer.new()

func _on_host_pressed() -> void:
	title_screen.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())
	$LobbyUI.show()

func _on_client_pressed() -> void:
	title_screen.hide()
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = PlayerLoad.instantiate()
	player.name = str(peer_id)
	$Players.add_child(player)
