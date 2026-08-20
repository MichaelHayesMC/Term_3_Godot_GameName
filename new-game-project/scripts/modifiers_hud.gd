extends Control

@onready var world = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.players_ready == len(GameManager.players):
		if self != null:
			world.HUD_display()
			GameManager.players_ready = 0
			GameManager.player_chosen = false
			world.level_pick()
		
			queue_free()
