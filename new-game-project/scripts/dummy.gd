extends CharacterBody3D

@export var camera_3d: Camera3D

@onready var mat = $MeshInstance3D.get_active_material(0) as StandardMaterial3D

var READY := true

func _physics_process(_delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera_3d.project_ray_origin(mousepos)
	var end = origin + camera_3d.project_ray_normal(mousepos) * 1000
	var query2 = PhysicsRayQueryParameters3D.create(origin, end, 3)
	query2.collide_with_areas = true
	
	var result = space_state.intersect_ray(query2)

func _on_dummy_hitbox_area_entered(area: Area3D) -> void:
	print("registered")
	if area.name == "Bullet_collider":
		mat.albedo_color = Color(0.871, 0.157, 0.451, 1.0)
		READY = false
		await get_tree().create_timer(1.5).timeout
		mat.albedo_color = Color(0.255, 0.412, 0.71, 1.0)


#func _on_dummy_hitbox_area_exited(area: Area3D) -> void:
	#
	#if area.name == "Bullet_collider":
		#mat.albedo_color = Color(0.255, 0.412, 0.71, 1.0)
		#READY = true
		
