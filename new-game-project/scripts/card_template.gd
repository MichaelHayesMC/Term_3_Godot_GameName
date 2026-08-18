extends ColorRect

var default_color = color
var enabled = true

var CardData = [
	{
		"name" : "ATK_SPEED",
		"description" : "Increase Attack Speed by 5%",
		"color" : Color(1.0, 1.0, 1.0, 1.0),
		"tier" : "Common",
		"emblem_texture" : Color() # Change color to texture when pngs have been uploaded
	},
	{
		"name" : "ATK_SPEED",
		"description" : "Increase Attack Speed by 20%",
		"color" : Color(0.223, 0.597, 0.626, 1.0),
		"tier" : "Uncommon",
		"emblem_texture" : Texture2D
	}
]

var Card_name
var Card_desc 
var Card_color 
var Card_tier 
var Card_emblem

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

	print("I am card: ", card_name)
	print("My effect: ", card_description)
	
	$Label.text = card_name
	$Label2.text = card_description
	color = card_color
	$Icon.color = card_emblem

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		if enabled:
			vanity.rpc()
			modifier_apply()
		elif !enabled:
			print("disabled")

func modifier_apply():
	pass

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
