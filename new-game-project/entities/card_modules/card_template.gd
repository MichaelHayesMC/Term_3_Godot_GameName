extends ColorRect

signal card_selected(card_id: int)

var default_color = color
var enabled = true

var card_id: int
var card_name: String
var card_description: String
var card_color: Color
var card_tier: String
var card_emblem: Color # Will change to texture

func setup_card(id: int, data: Dictionary) -> void:
	card_id = id
	card_name = data["name"]
	card_description = data["description"]
	card_color = data["color"]
	card_tier = data["tier"]
	card_emblem = data["emblem_texture"]
	
	$Label.text = card_name
	$Label2.text = card_description
	color = card_color
	$Icon.color = card_emblem

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if enabled and !GameManager.player_chosen:
			vanity.rpc()
			modifier_apply()
		elif !enabled:
			print("disabled")

func modifier_apply():
	card_selected.emit(card_id)

@rpc("call_local", "any_peer")
func vanity():
	modulate.a = .5
	enabled = false

func effect_add():
	pass

func _on_mouse_entered() -> void:
	color = Color(0.815, 0.344, 0.719, 1.0)

func _on_mouse_exited() -> void:
	color = card_color
