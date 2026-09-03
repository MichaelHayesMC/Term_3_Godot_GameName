extends Node3D

@onready var w_spawner: Marker3D = $WSpawner
@onready var e_spawner: Marker3D = $ESpawner
@onready var n_spawner: Marker3D = $NSpawner
@onready var s_spawner: Marker3D = $SSpawner

var spawn_locations: Array[Marker3D] = []

var current_player: Player
var players_loaded := {}
var players_spawned := false


func _ready() -> void:
	print("new level created")

	# Reset state for this arena
	players_loaded.clear()
	players_spawned = false

	spawn_locations = [
		w_spawner,
		e_spawner,
		n_spawner,
		s_spawner
	]

	var peer_id := multiplayer.get_unique_id()

	current_player = get_node_or_null(
		"../../Players/" + str(peer_id)
	)

	if !multiplayer.is_server():
		player_card_ui_ready.rpc_id(1, peer_id)
	else:
		players_loaded[1] = true
		check_all_players_ready()


@rpc("any_peer", "reliable")
func player_card_ui_ready(peer_id: int) -> void:
	if !multiplayer.is_server():
		return

	players_loaded[peer_id] = true

	check_all_players_ready()


func check_all_players_ready() -> void:
	if !multiplayer.is_server():
		return

	if players_spawned:
		return

	if players_loaded.size() < GameManager.players.size():
		return

	players_spawned = true

	var available_spawns := spawn_locations.duplicate()

	for player in get_tree().get_nodes_in_group("players"):
		if available_spawns.is_empty():
			break

		var chosen_spawn: Marker3D = available_spawns.pick_random()
		available_spawns.erase(chosen_spawn)

		var spawn_position := chosen_spawn.global_position
		var peer_id := player.get_multiplayer_authority()

		print("Spawning player ", peer_id, " at ", spawn_position)

		if peer_id == 1:
			# Host
			player.global_position = spawn_position
		else:
			# Client
			player.spawn_location.rpc_id(peer_id, spawn_position)
