extends Node

var number = 0
var players : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		i.name == str(number)
		number += 1
		players.append(i)
	
	print(players)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
