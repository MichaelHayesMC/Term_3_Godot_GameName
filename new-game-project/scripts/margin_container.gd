extends MarginContainer

@export var card_roster : Array[PackedScene]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_loader()


func card_loader():
	for row in range(2):
		var row_load = HBoxContainer.new()
		$VBoxContainer.add_child(row_load)
		row_load.add_theme_constant_override("separation", 70)
		for column in range(4):
			var current_card = card_roster.pick_random()
			var loaded_card = current_card.instantiate()
			row_load.add_child(loaded_card)
