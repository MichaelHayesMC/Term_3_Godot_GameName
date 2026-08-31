extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().color_changing.connect(hi)
	
func hi(new_color):
	$Circle.material_override.stencil_color = new_color
