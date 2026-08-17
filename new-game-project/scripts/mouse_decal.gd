extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	Global.player_colour.connect(colour_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	
	colour_change()

func colour_change():
	print("occured")
	if name == GameManager.players[0]:
		modulate = Color(0.0, 1.0, 1.0, 1.0)
	elif name == GameManager.players[1]:
		modulate = Color(0.0, 1.0, 0.0, 1.0)
	elif name == GameManager.players[2]:
		modulate = Color(1.0, 0.5, 0.0, 1.0)
	elif name == GameManager.players[3]:
		modulate = Color(1.0, 0.0, 0.0, 1.0)
