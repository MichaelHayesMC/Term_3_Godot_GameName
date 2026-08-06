extends CharacterBody3D

@onready var camera_3d: Camera3D = $"../Camera3D"

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera_3d.project_ray_origin(mousepos)
	var end = origin + camera_3d.project_ray_normal(mousepos) * 1000
	var query2 = PhysicsRayQueryParameters3D.create(origin, end, 3)
	query2.collide_with_areas = true
	
	var result = space_state.intersect_ray(query2)
	
	var mat = $MeshInstance3D.get_active_material(0) as StandardMaterial3D
	if result.collider == $Dummy_hitbox:
		mat.albedo_color = Color(0.871, 0.157, 0.451, 1.0)
	else:
		mat.albedo_color = Color(0.255, 0.412, 0.71, 1.0)
