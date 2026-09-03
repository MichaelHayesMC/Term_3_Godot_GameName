extends CharacterBody3D

@onready var mat = $MeshInstance3D.get_active_material(0) as StandardMaterial3D

func _on_dummy_hitbox_area_entered(area: Area3D) -> void:
	print("registered")
	if area.name == "Bullet_collider":
		mat.albedo_color = Color(0.871, 0.157, 0.451, 1.0)
		await get_tree().create_timer(.5).timeout
		mat.albedo_color = Color(0.255, 0.412, 0.71, 1.0)
