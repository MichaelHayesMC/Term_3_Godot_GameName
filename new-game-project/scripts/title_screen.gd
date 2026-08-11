extends Control

@export var main_game : PackedScene

func _on_host_pressed() -> void:
	HighLevelNetworkHandler.start_server()
	get_tree().change_scene_to_packed(main_game)


func _on_client_pressed() -> void:
	HighLevelNetworkHandler.start_client()
	get_tree().change_scene_to_packed(main_game)
