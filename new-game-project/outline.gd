extends Node3D

func _ready() -> void:
	get_parent().get_parent().color_changing.connect(hi)

func hi(new_color: Color) -> void:
	$Circle.material_override.stencil_color = new_color
