extends Node
class_name World

@onready var world = get_tree().current_scene

@onready var title_screen: CanvasLayer = $TitleScreen
@onready var HUD = preload("res://systems/ui/HUD/hud.tscn")
@export var levels : Array[PackedScene]

#signal player_colour
const PlayerLoad = preload("res://entities/characters/player.tscn")
const MouseLoad = preload("res://systems/ui/Mouse Cursor/mouse_decal.tscn")

var enet_peer = ENetMultiplayerPeer.new()
var tube_client := TubeClient.new()
var tube_enabled = true

const PORT = 9999
const TUBE_CONTEXT = preload("uid://c772ag8jxcwo4")
var ip_test = "localhost"

func _ready() -> void:
	if tube_enabled:
		tube_client.context = TUBE_CONTEXT
		get_tree().root.add_child.call_deferred(tube_client)
	
	#tube_client = GameManager.tube_clientm

func tube_create():
	multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	tube_client.create_session()
	add_player(1)

func tube_join(session_id: String):
	multiplayer.peer_connected.connect(add_player)
	#multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	tube_client.join_session(session_id)

func on_connected_to_server():
	add_player(multiplayer.get_unique_id())

func _exit_tree() -> void:
	if tube_enabled:
		tube_client.leave_session()

func _on_create_tube_pressed() -> void:
	tube_create()
	#add_world()

func _on_join_tube_pressed() -> void:
	tube_join(%Lineeditsession.text)
	#multiplayer.connected_to_server.connect(add_world)

#func _on_host_pressed() -> void:
	#title_screen.hide()
	#enet_peer.create_server(PORT)
	#multiplayer.multiplayer_peer = enet_peer
	#multiplayer.peer_connected.connect(add_player)
	##multiplayer.peer_disconnected.connect(remove_player)
	#
	#add_player(multiplayer.get_unique_id())
	#$LobbyUI.show()

#func _on_client_pressed() -> void:
	#title_screen.hide()
	#enet_peer.create_client(ip_test, PORT)
	##multiplayer.peer_disconnected.connect(remove_player)
	#multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	if !multiplayer.is_server() and multiplayer.multiplayer_peer is ENetMultiplayerPeer:
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
