extends CharacterBody3D

@onready var velocity_preview: Label = $"../VBoxContainer/Velocity_preview"
@onready var current_preview: Label = $"../VBoxContainer/Current_preview"
@onready var mouse_loc: Label = $"../VBoxContainer/Mouse_loc"
@onready var player_direction: Label = $"../VBoxContainer/Player_direction"
@onready var player_rotation: Label = $"../VBoxContainer/Player_rotation"

@export var camera_3d: Camera3D

@export var Bullet : PackedScene

const Speed := 75.0
const Friction := -40.0
const TopSpeed := 10.0
const Jump_Strength := 15.0
const Gravity := 50.0

func _physics_process(delta: float) -> void:
	mouse_loc.text = "Mouse Location: " + str(get_viewport().get_mouse_position()) 
	player_direction.text = "Player Location: " + str(self.position)
	
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera_3d.project_ray_origin(mousepos)
	var end = origin + camera_3d.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end, 2)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	result.position.y = position.y
	
	look_at(result.position)
	
	player_rotation.text = "Player_Rotation " + str(rotation_degrees)
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += Jump_Strength
	else:
		velocity.y -= Gravity * delta
	
	if Input.is_action_pressed("move_down") and is_on_floor():
		velocity.z += Speed * delta
		current_preview.text = "Current_Input: Down"
		if velocity.z > TopSpeed:
			velocity.z = TopSpeed
	elif velocity.z > 0 and is_on_floor():
		velocity.z += Friction * delta
		if velocity.z < 0:
			velocity.z = 0
			
	if Input.is_action_pressed("move_up") and is_on_floor():
		current_preview.text = "Current_Input: Up"
		velocity.z -= Speed * delta
		if velocity.z < -TopSpeed:
			velocity.z = -TopSpeed
	elif velocity.z < 0 and is_on_floor():
		velocity.z -= Friction * delta
		if velocity.z > 0:
			velocity.z = 0
			
	if Input.is_action_pressed("move_right") and is_on_floor():
		velocity.x += Speed * delta
		current_preview.text = "Current_Input: Right"
		if velocity.x > TopSpeed:
			velocity.x = TopSpeed
	elif velocity.x > 0 and is_on_floor():
		velocity.x += Friction * delta
		if velocity.x < 0:
			velocity.x = 0
			
	if Input.is_action_pressed("move_left") and is_on_floor():
		current_preview.text = "Current_Input: Left"
		velocity.x -= Speed * delta
		if velocity.x < -TopSpeed:
			velocity.x = -TopSpeed
	elif velocity.x < 0 and is_on_floor():
		velocity.x -= Friction * delta
		if velocity.x > 0:
			velocity.x = 0
		
	velocity_preview.text = "Velocity: x" + str(int(velocity.x)) + " y" + str(int(velocity.y)) + " z" + str(int(velocity.z))
	
	move_and_slide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("left_click"):
		var bullet = Bullet.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_transform = $Weapon/Marker3D.global_transform
		bullet.global_rotation = $".".global_rotation
		
#		get_slide_collision()
		
