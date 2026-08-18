extends ColorRect

var default_color = color
var enabled = true

var CardData = [
	{
		"name" : "ATK_SPEED",
		"description" : "Increase Attack Speed by 20%",
		"color" : Color(1.0, 1.0, 1.0, 1.0),
		"tier" : "Common",
		"emblem_texture" : Color() # Change color to texture when pngs have been uploaded
	},
	{
		"name" : "ATK_SPEED",
		"description" : "Increase Attack Speed by 20%",
		"color" : Color(1.0, 0.0, 0.0, 1.0),
		"tier" : "Common",
		"emblem_texture" : Texture2D
	}
]

func _ready() -> void:
	var Card_ID = CardData.pick_random()
	var Card_name = Card_ID["name"]
	var Card_desc = Card_ID["description"]
	var Card_color = Card_ID["color"]
	var Card_tier = Card_ID["tier"]
	var Card_emblem = Card_ID["emblem_texture"]
	
	color = Card_color
	#$Icon.texture = Card_emblem
	$Label.text = Card_name
	$Label2.text = Card_desc

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
