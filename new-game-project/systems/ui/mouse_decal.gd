extends TextureRect

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	if multiplayer.is_server():
		var player_index = GameManager.players.find(name)
		colour_change.rpc(player_index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !is_multiplayer_authority() : return
	
	global_position = get_global_mouse_position()

@rpc("call_local", "any_peer")
func colour_change(player_index: int):
	#print("My name: ", name)
	#print("Index received: ", player_index)

	match player_index:
		0:
			self_modulate = Color.CYAN
		1:
			self_modulate = Color.GREEN
		2:
			self_modulate = Color.ORANGE
		3:
			self_modulate = Color.RED
