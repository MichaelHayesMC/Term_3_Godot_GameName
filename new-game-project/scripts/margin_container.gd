extends MarginContainer

@export var card_roster: Array[PackedScene]

func _ready() -> void:
	if multiplayer.is_server():
		var card_ids: Array[int] = []

		var rng := RandomNumberGenerator.new()
		rng.randomize()

		for i in range(8):
			card_ids.append(rng.randi_range(0, card_roster.size() - 1))
			print(card_ids)

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
			index += 1

			var current_card := card_roster[card_id]
			var loaded_card := current_card.instantiate()
			row_load.add_child(loaded_card)
