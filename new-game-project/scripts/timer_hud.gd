extends ColorRect

@export var timer_lb: Label
@export var in_game_minutes := 5
@export var in_game_seconds := 59
@export var pre_game_minutes := 0
@export var pre_game_seconds := 3
@export var main_game_scene : PackedScene
@export var modifiers_hud : PackedScene

var game_state := "pre_game"
var timer_const = 0
var counting = false
var ready_next_phase := false
var minutes 
var seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counting = !counting
	
	minutes = pre_game_minutes
	seconds = pre_game_seconds


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var minutes_label : String
	var seconds_label : String
	
	if minutes == 0 and seconds == 0 and ready_next_phase == false:
		if game_state == "post_game":
			counting = false
			ready_next_phase = true
			modifiers_proceed()
		elif game_state == "pre_game":
			minutes = in_game_minutes
			seconds = in_game_seconds
			game_state = "post_game"
	elif seconds == 0 and counting:
		minutes -= 1
		seconds = 59
	elif timer_const <= 1 and counting:
		timer_const += 1 * delta
	elif timer_const >= 1:
		timer_const = 0
		seconds -= 1
		
	if minutes <= 9:
		minutes_label = "0" + str(minutes)
	else:
		minutes_label = str(minutes)
		
	if seconds <= 9:
		seconds_label = "0" + str(seconds)
	else:
		seconds_label = str(seconds)
		
	timer_lb.text = (minutes_label + " : " + seconds_label)

func modifiers_proceed():
	var modifiers_load = modifiers_hud.instantiate()
	get_tree().current_scene.add_child(modifiers_load)

func _on_timer_timeout() -> void:
	print("game finish")
