extends ColorRect

@export var timer_lb: Label

@export var minutes := 5
@export var seconds := 59

var timer_const = 0
var counting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counting = !counting


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var minutes_label : String
	var seconds_label : String
	
	if minutes == 0 and seconds == 0:
		counting = false
		game_proceed()
	elif seconds == 0:
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

func game_proceed():
	pass

func _on_timer_timeout() -> void:
	print("game finish")
