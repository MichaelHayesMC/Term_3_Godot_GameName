#extends Control
#
#@onready var player_1: Label = $Panel/MarginContainer/VBoxContainer/Player1
#@onready var player_2: Label = $Panel/MarginContainer/VBoxContainer/Player2
#@onready var player_3: Label = $Panel/MarginContainer/VBoxContainer/Player3
#@onready var player_4: Label = $Panel/MarginContainer/VBoxContainer/Player4
#
#@onready var players = get_tree().get_nodes_in_group("players")
#
#func _ready():
	#for player in players:
		#player.score_changed.connect(_on_player_score_changed.bind(player))
#
#
#func _on_player_score_changed(new_score: int, player: Player):
	#var player_index = GameManager.players.find(player.name)
#
	#if player_index == -1:
		#return
#
	#var label = get_node("Player%d" % (player_index + 1))
	#label.text = str(new_score)
