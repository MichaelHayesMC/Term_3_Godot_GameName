extends MarginContainer

@export var Card_template: PackedScene

var current_player: Player

var CardData = [
	{
		"name": "ATK SPEED",
		"description": "Increase Attack Speed by 5%",
		"color": Color(1.0, 1.0, 1.0, 1.0),
		"tier": "Common",
		"emblem_texture": Color(1.0, 0.0, 0.0, 1.0), # Will change to a texture
		"value" : 0.05
	},
	{
		"name": "ATK SPEED +",
		"description": "Increase Attack Speed by 20%",
		"color": Color(0.223, 0.597, 0.626, 1.0),
		"tier": "Uncommon",
		"emblem_texture": Color(1.0, 0.0, 0.0, 1.0), # Will change to a texture
		"value" : 0.2
	},
	{
		"name": "MOVE SPEED",
		"description": "Increase Movement Speed by 5%",
		"color": Color(1.0, 1.0, 1.0, 1.0),
		"tier": "Common",
		"emblem_texture": Color(0.0, 0.589, 0.752, 1.0), # Will change to a texture
		"value" : 0.05
	},
	{
		"name": "MOVE SPEED +",
		"description": "Increase Movement Speed by 20%",
		"color": Color(0.223, 0.597, 0.626, 1.0),
		"tier": "Uncommon",
		"emblem_texture": Color(0.0, 0.589, 0.752, 1.0), # Will change to a texture
		"value" : 0.2
	},
	{
		"name": "GHOST WALK (WIP)",
		"description": "Provides Intangibility for 5 seconds to obstacles",
		"color": Color(0.813, 0.267, 0.771, 1.0),
		"tier": "Epic",
		"emblem_texture": Color(1.0, 1.0, 1.0, 1.0), # Will change to a texture
		"value" : null
	},
	{
		"name": "ECHO SHIELD (WIP)",
		"description": "Froms a defensive barrier around the player providing an extra life (One time use)",
		"color": Color(1.0, 0.78, 0.231, 1.0),
		"tier": "Legendary",
		"emblem_texture": Color(0.375, 0.001, 0.488, 1.0), # Will change to a texture
		"value" : null
	}
]

var players_loaded := {}

func _ready() -> void:
	var peer_id := multiplayer.get_unique_id()

	print("\n============================")
	print("CARD READY")
	print("PEER: ", peer_id)
	print("CARD PATH: ", get_path())

	var players_node = get_node_or_null("../../../Players")

	print("PLAYERS NODE: ", players_node)

	if players_node:
		print("PLAYER CHILDREN:")
		for child in players_node.get_children():
			print(
				"  NAME: ",
				child.name,
				" | PATH: ",
				child.get_path(),
				" | AUTHORITY: ",
				child.get_multiplayer_authority()
			)

	current_player = get_node_or_null(
		"../../../Players/" + str(peer_id)
	)

	print("CURRENT PLAYER: ", current_player)
	print("============================\n")

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

	print("CARD UI READY FROM: ", peer_id)

	check_all_players_ready()


func check_all_players_ready() -> void:
	if !multiplayer.is_server():
		return

	if players_loaded.size() < GameManager.players.size():
		return

	generate_cards()

func generate_cards() -> void:
	var card_ids: Array[int] = []

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in range(8):
		card_ids.append(
			rng.randi_range(0, CardData.size() - 1)
		)

	print("GENERATED CARDS: ", card_ids)

	card_loader.rpc(card_ids)

@rpc("authority", "call_local", "reliable")
func card_loader(card_ids: Array[int]) -> void:
	var index := 0

	for row in range(2):
		var row_load := HBoxContainer.new()
		$VBoxContainer.add_child(row_load)
		row_load.add_theme_constant_override("separation", 70)

		for column in range(4):
			var card_id: int = card_ids[index]
			var card_data: Dictionary = CardData[card_id]
			index += 1

			var loaded_card = Card_template.instantiate()

			loaded_card.setup_card(card_id, card_data)
			loaded_card.card_selected.connect(_on_card_selected)

			row_load.add_child(loaded_card)

func _on_card_selected(card_id: int) -> void:
	var card_data: Dictionary = CardData[card_id]
	
	current_player.apply_card(card_data)
	
	done_state.rpc(current_player.name)
	
	GameManager.player_chosen = true

@rpc("call_local", "reliable", "any_peer")
func done_state(player):
	GameManager.players_ready += 1
	
	if player == GameManager.players[0]:
		$"../PlayerBar/Player_Done".show()
	elif player == GameManager.players[1]:
			$"../PlayerBar/Player_Done2".show()
	elif player == GameManager.players[2]:
			$"../PlayerBar/Player_Done3".show()
	elif player == GameManager.players[3]:
			$"../PlayerBar/Player_Done4".show()
		
