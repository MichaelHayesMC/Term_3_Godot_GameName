extends RigidBody3D

var speed := 30.0
var gravity := 2.0

var shooter_id: int = -1


func _process(delta: float) -> void:
	global_position += -global_transform.basis.z * speed * delta
	global_position += -global_transform.basis.y * gravity * delta


func _on_bullet_collider_body_entered(body: Node3D) -> void:
	# ONLY the server processes collisions.
	if !multiplayer.is_server():
		return

	if body is Player:
		var victim_id := body.get_multiplayer_authority()

		# Don't shoot yourself.
		if victim_id == shooter_id:
			return

		print("BULLET HIT: ", body.name)

		# Damage the victim.
		body.receive_damage.rpc()

		# Find the shooter.
		var shooter: Player = null

		for player in get_tree().get_nodes_in_group("players"):
			if player.get_multiplayer_authority() == shooter_id:
				shooter = player
				break

		# Give shooter exactly one point.
		if shooter:
			print("GIVING POINT TO: ", shooter.name)
			shooter.add_point.rpc()

		# Tell ALL clients to destroy their bullet.
		destroy_bullet.rpc()

	else:
		print("BULLET HIT: ", body)

		# Wall/object collision.
		destroy_bullet.rpc()


func _on_bullet_collider_area_entered(area: Area3D) -> void:
	if !multiplayer.is_server():
		return

	if area.name != "Bullet_collider":
		destroy_bullet.rpc()


@rpc("authority", "call_local", "reliable")
func destroy_bullet() -> void:
	queue_free()
