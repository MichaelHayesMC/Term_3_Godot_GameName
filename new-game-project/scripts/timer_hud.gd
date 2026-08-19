extends ColorRect

@export var timer_lb: Label

@export var default_in_game_minutes := 2
@export var default_in_game_seconds := 0
@export var default_pre_game_minutes := 0
@export var default_pre_game_seconds := 3
@export var modifiers_hud : PackedScene

var in_game_minutes := default_in_game_minutes
var in_game_seconds := default_in_game_seconds
var pre_game_minutes := default_pre_game_minutes
var pre_game_seconds := default_pre_game_seconds

var game_state
var timer_const = 0
var counting = false
var ready_next_phase := false
var minutes 
var seconds

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_start()

func game_start():
	in_game_minutes = default_in_game_minutes
	in_game_seconds = default_in_game_seconds
	pre_game_minutes = default_pre_game_minutes
	pre_game_seconds = default_pre_game_seconds
	
	GameManager.players_moving = false
	counting = !counting
	
	minutes = pre_game_minutes
	seconds = pre_game_seconds
	
	GameManager.game_start = false
	game_state = "pre_game"
	ready_next_phase = false
	#print(pre_game_minutes)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.game_start:
		game_start()
	
	var minutes_label : String
	var seconds_label : String
	
	if minutes == 0 and seconds == 0 and ready_next_phase == false:
		if game_state == "pre_game":
			minutes = in_game_minutes
			seconds = in_game_seconds
			game_state = "post_game"
			GameManager.players_moving = true
		elif game_state == "post_game" and GameManager.players_moving:
			counting = false
			ready_next_phase = !ready_next_phase
			modifiers_proceed.rpc()
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

@rpc("any_peer", "call_local")
func modifiers_proceed():
	var modifiers_load = modifiers_hud.instantiate()
	get_tree().current_scene.add_child(modifiers_load)
	GameManager.players_moving = false
	get_parent().queue_free()
