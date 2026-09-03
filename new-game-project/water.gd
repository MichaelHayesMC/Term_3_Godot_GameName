extends MeshInstance3D

var time : float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	
	position.y = 1 * sin(0.5 * time) + 3
