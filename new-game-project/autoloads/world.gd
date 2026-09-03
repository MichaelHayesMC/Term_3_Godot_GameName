extends Node
class_name World

@onready var world = get_tree().current_scene

@onready var title_screen: CanvasLayer = $TitleScreen
@onready var HUD = preload("res://scenes/hud.tscn")
@export var levels : Array[PackedScene]

#signal player_colour

const PORT = 9999
const PlayerLoad = preload("res://scenes/player.tscn")
const MouseLoad = preload("res://scenes/mouse_decal.tscn")

var enet_peer = ENetMultiplayerPeer.new()
var ip_test = "localhost"

func _on_host_pressed() -> void:
	title_screen.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())
	$LobbyUI.show()
	
	#upnp_setup() # Blueprint to create a online multiplayer hosting and client system unrestricted to the confines of local multiplayer

func _on_client_pressed() -> void:
	title_screen.hide()
	enet_peer.create_client(ip_test, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	#player_colour.emit()

func add_player(peer_id):
	if !multiplayer.is_server():
		return

	add_player_rpc.rpc(peer_id)

@rpc("authority", "call_local", "reliable")
func add_player_rpc(peer_id):
	var player = PlayerLoad.instantiate()
	player.name = str(peer_id)
	$Players.add_child(player)

	var mouse = MouseLoad.instantiate()
	mouse.name = str(peer_id)
	$CanvasLayer/PlayerCursors.add_child(mouse)

func add_cursor(peer_id):
	var mouse = MouseLoad.instantiate()
	mouse.name = str(peer_id)
	$PlayerCursors.add_child(mouse)
	world.player_colour.emit()

# Calls function to change scene with all player clients changing with it
func _on_start_pressed() -> void:
	if !multiplayer.is_server(): return
	
	if len(GameManager.players) >= 2: 
		HUD_display.rpc()
		level_pick()

func level_pick():
	if not multiplayer.is_server():
		return

	print("SERVER LEVELS: ", levels)

	if levels.is_empty():
		push_error("No levels have been assigned!")
		return

	var chosen_level: PackedScene = levels.pick_random()

	if chosen_level == null:
		push_error("A level in the levels array is null!")
		return

	Level_change(chosen_level)

func Level_change(chosen_level):
	if not multiplayer.is_server():
		return

	print("SERVER CHOSE: ", chosen_level.resource_path)
	level_sync.rpc(chosen_level.resource_path)

@rpc("authority", "call_local", "reliable")
func level_sync(level_path):
	print("LOADING LEVEL ON PEER: ", multiplayer.get_unique_id())

	for child in $Platform.get_children():
		child.queue_free()

	var current_level = load(level_path).instantiate()
	$Platform.add_child(current_level)

	print("LEVEL LOADED: ", current_level)

@rpc("call_local", "reliable")
func HUD_display():
	if $LobbyUI:
		$LobbyUI.hide()
	var new_HUD = HUD.instantiate()
	add_child(new_HUD)

func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result) 
	
	assert(upnp.get_gateway() and upnp.get_gate_way().is_valid_gateway(), \
		"UPNP Invalid Gateway!")
		
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)
		
	print("Success! Join Address: %s" % upnp.query_external_address())
