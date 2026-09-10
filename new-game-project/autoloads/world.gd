extends Node
class_name World

@onready var world = get_tree().current_scene

@onready var title_screen: CanvasLayer = $TitleScreen
@onready var HUD = preload("res://systems/ui/hud.tscn")
@export var levels : Array[PackedScene]

#signal player_colour

const PORT = 9999
const PlayerLoad = preload("res://entities/characters/player.tscn")
const MouseLoad = preload("res://systems/ui/mouse_decal.tscn")

var enet_peer = ENetMultiplayerPeer.new()
var ip_test = "localhost"

###############################################################
@onready var spawner: FusionSpawner = $FusionSpawner
@onready var photon_host: Button = %"Photon Host"
@onready var photon_client: Button = %"Photon Client"

func _ready() -> void:
	Fusion.room_joined.connect(_on_room_joined)
	photon_host.pressed.connect(_connect_room)
	photon_client.pressed.connect(_join_room)
	spawner.add_spawnable_scene(PlayerLoad)

func _connect_room():
	print("clicked connect")
	var user_id = "user_%d" % randi()
	Fusion.connect_to_photon(user_id)
	Fusion.connected_to_photon.connect(func():
		var options := FusionRoomOptions.new()
		options.max_players = 4
		Fusion.create_room(%RoomID.text, options)
	)
	$LobbyUI.show()
	title_screen.hide()

func _join_room():
	print("clicked connect")
	var user_id = "user_%d" % randi()
	Fusion.connect_to_photon(user_id)
	Fusion.connected_to_photon.connect(func():
		var options := FusionRoomOptions.new()
		options.max_players = 4
		print("trying to join/create room as user: ", user_id)
		Fusion.join_room(%RoomID.text, options)
	)
	title_screen.hide()

func _on_room_joined():
	var pos = Vector3(0, 1, 0)
	var player = spawner.spawn()
	player.position = pos
	print("Joined room and spawned player scene")

###############################################################

func _on_host_pressed() -> void:
	title_screen.hide()
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())
	$LobbyUI.show()

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
