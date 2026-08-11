extends ColorRect

var default_color = color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_parent().get_parent().get_parent().get_parent().get_parent().queue_free()
		GameManager.game_start = true

func _on_mouse_entered() -> void:
	color = Color(0.0, 1.0, 1.0, 1.0)


func _on_mouse_exited() -> void:
	color = default_color
