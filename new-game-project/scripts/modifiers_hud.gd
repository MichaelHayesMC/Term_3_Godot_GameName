extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(GameManager.players_ready)
	print(GameManager.players)
	if GameManager.players_ready == len(GameManager.players):
		if self != null:
			Global.HUD_display()
			GameManager.players_ready = 0
			self.queue_free()
