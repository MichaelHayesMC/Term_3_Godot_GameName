extends HBoxContainer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if len(GameManager.players) >= 4:
		$Player_Pfp.show()
		$Player_Pfp2.show()
		$Player_Pfp3.show()
		$Player_Pfp4.show()
	elif len(GameManager.players) >= 3:
		$Player_Pfp4.hide()
	elif len(GameManager.players) >= 2:
		$Player_Pfp3.hide()
		$Player_Pfp4.hide()
	
