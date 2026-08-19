extends CharacterBody3D
class_name Player

@onready var camera_3d = get_tree().get_first_node_in_group("global_camera")
@onready var mat = $MeshInstance3D.get_active_material(0) as StandardMaterial3D
@export var Bullet : PackedScene

var shooting = true

var score : int

# Kinematic Variables
const Speed := 75.0
const Friction := -40.0
const TopSpeed := 10.0
const Jump_Strength := 15.0
const Gravity := 50.0

var ghost_walk := false
var echo_shield := false

var attack_speed_modifier := 1.0
var move_speed_modifier := 1.0

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

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority() : return
	
	colour_change.rpc()
	
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = camera_3d.project_ray_origin(mousepos)
	var end = origin + camera_3d.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end, 2)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	result.position.y = position.y
	look_at(result.position)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += Jump_Strength
	else:
		velocity.y -= Gravity * delta
	
	if Input.is_action_pressed("move_down") and is_on_floor():
		velocity.z += Speed * delta * move_speed_modifier
		if velocity.z > TopSpeed * move_speed_modifier:
			velocity.z = TopSpeed * move_speed_modifier
	elif velocity.z > 0 and is_on_floor():
		velocity.z += Friction * delta
		if velocity.z < 0:
			velocity.z = 0
			
	if Input.is_action_pressed("move_up") and is_on_floor():
		velocity.z -= Speed * delta * move_speed_modifier
		if velocity.z < -TopSpeed * move_speed_modifier:
			velocity.z = -TopSpeed * move_speed_modifier
	elif velocity.z < 0 and is_on_floor():
		velocity.z -= Friction * delta
		if velocity.z > 0:
			velocity.z = 0
			
	if Input.is_action_pressed("move_right") and is_on_floor():
		velocity.x += Speed * delta * move_speed_modifier
		if velocity.x > TopSpeed * move_speed_modifier:
			velocity.x = TopSpeed * move_speed_modifier
	elif velocity.x > 0 and is_on_floor():
		velocity.x += Friction * delta
		if velocity.x < 0:
			velocity.x = 0
			
	if Input.is_action_pressed("move_left") and is_on_floor():
		velocity.x -= Speed * delta * move_speed_modifier
		if velocity.x < -TopSpeed * move_speed_modifier:
			velocity.x = -TopSpeed * move_speed_modifier
	elif velocity.x < 0 and is_on_floor():
		velocity.x -= Friction * delta
		if velocity.x > 0:
			velocity.x = 0

	if GameManager.players_moving:
		move_and_slide()
		
	if Input.is_action_just_pressed("left_click"):
		shoot.rpc()

@rpc("call_local")
func shoot():
	if shooting:
		shooting = false
		var bullet = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_transform = $Weapon/Marker3D.global_transform
		bullet.global_rotation = $".".global_rotation
		await get_tree().create_timer(1.9 - (0.9 * attack_speed_modifier)).timeout
		shooting = true

@rpc("call_local")
func colour_change():
	if name == GameManager.players[0]:
		mat.albedo_color = Color(0.0, 1.0, 1.0, 1.0)
	elif name == GameManager.players[1]:
		mat.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
	elif name == GameManager.players[2]:
		mat.albedo_color = Color(1.0, 0.5, 0.0, 1.0)
	elif name == GameManager.players[3]:
		mat.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
