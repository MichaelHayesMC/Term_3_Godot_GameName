extends ColorRect

var default_color = color
var enabled = true

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if enabled:
			vanity.rpc()
		elif !enabled:
			print("disabled")

@rpc("call_local", "any_peer")
func vanity():
	modulate.a = .5
	enabled = false

func effect_add():
	pass

func _on_mouse_entered() -> void:
	color = Color(0.815, 0.344, 0.719, 1.0)

func _on_mouse_exited() -> void:
	color = default_color
