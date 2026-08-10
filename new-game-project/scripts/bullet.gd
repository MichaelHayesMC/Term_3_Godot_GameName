extends RigidBody3D

var speed = 30
var gravity = 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += -global_transform.basis.z * speed * delta
	global_position += -global_transform.basis.y * gravity * delta

func _on_bullet_collider_body_entered(body: Node3D) -> void:
	if body != self:
		queue_free()

func _on_bullet_collider_area_entered(area: Area3D) -> void:
	if area.name != "Bullet_collider":
		print(area)
		queue_free()
