extends RigidBody3D

var speed := 30.0
var gravity := 2.0

var shooter_id: int = -1


func _process(delta: float) -> void:
	global_position += -global_transform.basis.z * speed * delta
	global_position += -global_transform.basis.y * gravity * delta


func _on_bullet_collider_body_entered(body: Node3D) -> void:
	#print("BULLET HIT: ", body.name)
	
	if body is Player:
		
		var victim_id = body.get_multiplayer_authority()
		
		#print("VICTIM ID: ", victim_id)
		#print("SHOOTER ID: ", shooter_id)
		
		if victim_id != shooter_id:
			print(body)
			body.position.y = 10
		
		# Don't shoot yourself
		if victim_id == shooter_id:
			return
		
		# Damage the victim
		body.receive_damage.rpc()
		
		# Find the shooter
		var shooter: Player = null
		
		for player in get_tree().get_nodes_in_group("players"):
			if player.get_multiplayer_authority() == shooter_id:
				shooter = player
				break
		
		# Give shooter a point
		if shooter:
			print("GIVING POINT TO: ", shooter.name)
			shooter.add_point.rpc()
		else:
			print("SHOOTER NOT FOUND!")
		
		queue_free()
	else:
		print(body)
		queue_free()


func _on_bullet_collider_area_entered(area: Area3D) -> void:
	if area.name != "Bullet_collider":
		queue_free()
