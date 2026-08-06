extends CharacterBody3D

@onready var current_preview: Label = $"../Current_preview"
@onready var velocity_preview: Label = $"../Velocity_preview"
@onready var previous_preview: Label = $"../Previous_preview"

const Speed := 50.0
const Friction := -40.0
const TopSpeed := 10
const Jump_Strength := 15
const Gravity := 50


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += Jump_Strength
	else:
		velocity.y -= Gravity * delta
	
	
	if Input.is_action_pressed("move_down"):
		velocity.z += Speed * delta
		current_preview.text = "Current_Input: Down"
		if velocity.z > TopSpeed:
			velocity.z = TopSpeed
	elif velocity.z > 0:
		velocity.z += Friction * delta
		if velocity.z < 0:
			velocity.z = 0
			
	if Input.is_action_pressed("move_up"):
		current_preview.text = "Current_Input: Up"
		velocity.z -= Speed * delta
		if velocity.z < -TopSpeed:
			velocity.z = -TopSpeed
	elif velocity.z < 0:
		velocity.z -= Friction * delta
		if velocity.z > 0:
			velocity.z = 0
			
	if Input.is_action_pressed("move_right"):
		velocity.x += Speed * delta
		current_preview.text = "Current_Input: Right"
		if velocity.x > TopSpeed:
			velocity.x = TopSpeed
	elif velocity.x > 0:
		velocity.x += Friction * delta
		if velocity.x < 0:
			velocity.x = 0
			
	if Input.is_action_pressed("move_left"):
		current_preview.text = "Current_Input: Left"
		velocity.x -= Speed * delta
		if velocity.x < -TopSpeed:
			velocity.x = -TopSpeed
	elif velocity.x < 0:
		velocity.x -= Friction * delta
		if velocity.x > 0:
			velocity.x = 0
		
	velocity_preview.text = "Velocity: x" + str(int(velocity.x)) + " y" + str(int(velocity.y)) + " z" + str(int(velocity.z))
	
	move_and_slide()
