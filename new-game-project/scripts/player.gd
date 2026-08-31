extends CharacterBody3D
class_name Player

signal score_changed(new_score: int)

@onready var camera_3d = get_tree().get_first_node_in_group("global_camera")
@onready var mat = $MeshInstance3D.get_active_material(0) as StandardMaterial3D
@export var Bullet: PackedScene

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var shooting := true
var health := 1

const Speed := 75.0
const Friction := -40.0
const TopSpeed := 10.0
const Jump_Strength := 15.0
const Gravity := 50.0

var ghost_walk := false
var echo_shield := false

var attack_speed_modifier := 1.0
var move_speed_modifier := 1.0

var time : float
var moving

func _process(delta):
	time += delta
	
	$Anchor.scale.y = 0.15 * sin(time * 10.0) + 1

	if !moving:
		$Anchor.rotation.z = 0.15 * sin(time * 5.0)
	else:
		$Anchor.rotation.z = 0.15 * sin(time * 30.0) * move_speed_modifier


# Called every frame. 'delta' is the elapsed time since the previous frame.
@rpc("any_peer", "call_local", "reliable")
func set_moving(value: bool) -> void:
	moving = value
		

func apply_card(card_data: Dictionary) -> void:
	match card_data["name"]:
		"ATK SPEED":
			attack_speed_modifier += card_data["value"]
		"ATK SPEED +":
			attack_speed_modifier += card_data["value"]
		"MOVE SPEED":
			move_speed_modifier += card_data["value"]
		"MOVE SPEED +":
			move_speed_modifier += card_data["value"]


func _ready() -> void:
	GameManager.players.append(name)
	add_to_group("players")
	colour_change()


func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera_3d.project_ray_origin(mousepos)
	var end = origin + camera_3d.project_ray_normal(mousepos) * 1000

	var query = PhysicsRayQueryParameters3D.create(origin, end, 1)
	query.collide_with_bodies = true

	var result = space_state.intersect_ray(query)

	if !result.is_empty():
		result.position.y = position.y
		look_at(result.position)

	velocity.y -= Gravity * delta

	if Input.is_action_pressed("move_down") and is_on_floor():
		if moving != true:
			moving = true
			set_moving.rpc(true)
		velocity.z += Speed * delta * move_speed_modifier
		if velocity.z > TopSpeed * move_speed_modifier:
			velocity.z = TopSpeed * move_speed_modifier
	elif velocity.z > 0 and is_on_floor():
		velocity.z += Friction * delta
		if velocity.z < 0:
			velocity.z = 0
		if moving != false:
			moving = false
			set_moving.rpc(false)


	if Input.is_action_pressed("move_up") and is_on_floor():
		if moving != true:
			moving = true
			set_moving.rpc(true)
		velocity.z -= Speed * delta * move_speed_modifier
		if velocity.z < -TopSpeed * move_speed_modifier:
			velocity.z = -TopSpeed * move_speed_modifier
	elif velocity.z < 0 and is_on_floor():
		velocity.z -= Friction * delta
		if velocity.z > 0:
			velocity.z = 0
		if moving != false:
			moving = false
			set_moving.rpc(false)


	if Input.is_action_pressed("move_right") and is_on_floor():
		if moving != true:
			moving = true
			set_moving.rpc(true)
		velocity.x += Speed * delta * move_speed_modifier
		if velocity.x > TopSpeed * move_speed_modifier:
			velocity.x = TopSpeed * move_speed_modifier
	elif velocity.x > 0 and is_on_floor():
		velocity.x += Friction * delta
		if velocity.x < 0:
			velocity.x = 0
		if moving != false:
			moving = false
			set_moving.rpc(false)


	if Input.is_action_pressed("move_left") and is_on_floor():
		if moving != true:
			moving = true
			set_moving.rpc(true)
		velocity.x -= Speed * delta * move_speed_modifier
		if velocity.x < -TopSpeed * move_speed_modifier:
			velocity.x = -TopSpeed * move_speed_modifier
	elif velocity.x < 0 and is_on_floor():
		velocity.x -= Friction * delta
		if velocity.x > 0:
			velocity.x = 0
		if moving != false:
			moving = false
			set_moving.rpc(false)

	if GameManager.players_moving:
		move_and_slide()

	if Input.is_action_just_pressed("left_click"):
		shoot.rpc()


# --------------------------------------------------
# DAMAGE
# --------------------------------------------------

# ONLY the server is allowed to process damage.
@rpc("authority", "call_local", "reliable")
func receive_damage():
	health -= 1

	if health <= 0:
		print(name, " Died")

# Temporary Stasis when killed
@rpc("call_local")
func kill_update():
	position.z += 100

# --------------------------------------------------
# SCORE
# --------------------------------------------------

# ONLY the server is allowed to award points.
@rpc("any_peer", "call_local", "reliable")
func add_point():
	if !multiplayer.is_server():
		return

	score += 1
	update_score.rpc(score)

	print("Player ", name, " got a point! Score: ", score)


@rpc("authority", "call_remote", "reliable")
func update_score(new_score: int):
	score = new_score

# --------------------------------------------------
# SHOOTING
# --------------------------------------------------

@rpc("any_peer", "call_local", "reliable")
func shoot():
	if shooting:
		shooting = false

		var bullet = Bullet.instantiate()

		# Remember who fired this bullet.
		bullet.shooter_id = get_multiplayer_authority()

		get_tree().current_scene.add_child(bullet)

		bullet.global_transform = $Weapon/Marker3D.global_transform
		bullet.global_rotation = global_rotation

		await get_tree().create_timer(
			1.9 - (0.9 * attack_speed_modifier)
		).timeout

		shooting = true


# --------------------------------------------------
# COLOUR
# --------------------------------------------------

signal color_changing(color)

func colour_change():
	if name == GameManager.players[0]:
		mat.albedo_color = Color(0.0, 1.0, 1.0)
		color_changing.emit(Color(0.0, 1.0, 1.0))
	elif name == GameManager.players[1]:
		mat.albedo_color = Color(0.0, 1.0, 0.0)
		color_changing.emit(Color(0.0, 1.0, 0.0))
	elif name == GameManager.players[2]:
		mat.albedo_color = Color(1.0, 0.5, 0.0)
		color_changing.emit(Color(1.0, 0.5, 0.0))
	elif name == GameManager.players[3]:
		mat.albedo_color = Color(1.0, 0.0, 0.0)
		color_changing.emit(Color(1.0, 0.0, 0.0))
		
@rpc("any_peer", "reliable")
func spawn_location(pos: Vector3) -> void:
	global_position = pos
