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
		"value" : 0.2
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
		"value" : 0.2
	},
	{
		"name": "ECHO SHIELD (WIP)",
		"description": "Froms a defensive barrier around the player providing an extra life (One time use)",
		"color": Color(1.0, 0.78, 0.231, 1.0),
		"tier": "Legendary",
		"emblem_texture": Color(0.375, 0.001, 0.488, 1.0), # Will change to a texture
		"value" : 0.2
	}
]

func _ready() -> void:
	var peer_id = multiplayer.get_unique_id()
	current_player = get_node("../../../Players/" + str(peer_id))

	if multiplayer.is_server():
		var card_ids: Array[int] = []

		var rng := RandomNumberGenerator.new()
		rng.randomize()

		for i in range(8):
			card_ids.append(rng.randi_range(0, CardData.size() - 1))

		card_loader.rpc(card_ids)

@rpc("call_local", "reliable")
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

	print("Selected: ", card_data["name"])
	print("Attack speed modifier: ", current_player.attack_speed_modifier)
