extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(GameManager.players)
	if len(GameManager.players) >= 4:
		$MarginContainer/VBoxContainer/Player_Pfp.show()
		$MarginContainer/VBoxContainer/Player_Pfp2.show()
		$MarginContainer/VBoxContainer/Player_Pfp3.show()
		$MarginContainer/VBoxContainer/Player_Pfp4.show()
	elif len(GameManager.players) >= 3:
		$MarginContainer/VBoxContainer/Player_Pfp4.hide()
	elif len(GameManager.players) >= 2:
		$MarginContainer/VBoxContainer/Player_Pfp3.hide()
		$MarginContainer/VBoxContainer/Player_Pfp4.hide()
	
