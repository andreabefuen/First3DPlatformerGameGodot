extends CharacterBody3D

@export_subgroup("Components")
@export var view: Node3D

@export_subgroup("Properties")
@export var movement_speed = 250
@export var run_speed = 500
@export var jump_strenght = 7

var movement_velocity : Vector3
var rotation_direction : float
var gravity = 0;

var previously_floored = false

var jump_single = true
var jump_double = true
var is_running = false

@onready var particle_trail = $ParticlesTrail
@onready var model = $FemaleCharacter
@onready var animation = $FemaleCharacter/AnimationPlayer


func _physics_process(delta):
	handle_controls(delta)
	handle_gravity(delta)
	
	handle_animations()
	
	#Movement
	var applied_velocity : Vector3
	
	applied_velocity = velocity.lerp(movement_velocity, delta *10)
	applied_velocity.y = -gravity
	
	velocity = applied_velocity
	move_and_slide()
	
	if Vector2(velocity.z, velocity.y).length() > 0:
		rotation_direction = Vector2(velocity.z, velocity.x).angle()
	
	rotation.y = lerp_angle(rotation.y, rotation_direction, delta * 10)
	
	if position.y < -10:
		get_tree().reload_current_scene()


	previously_floored = is_on_floor()

	
func handle_controls(delta):
	
	#Movement control
	var input := Vector3.ZERO
	
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	
	input = input.rotated(Vector3.UP, view.rotation.y).normalized()
	
	
	if Input.is_action_pressed("run"):
		movement_velocity = input * run_speed * delta
		is_running = true
	else:
		movement_velocity = input * movement_speed * delta
		is_running = false
		
	
	#Jump control
	
	if Input.is_action_just_pressed("jump"):
			
		if jump_double:
			gravity = -jump_strenght
			jump_double = false
		
		if(jump_single): jump()
	

	
func handle_gravity(delta):
	
	gravity += 25 * delta
	
	if gravity > 0 and is_on_floor():
		
		jump_single = true
		gravity = 0

# Jumping

func handle_animations():
	particle_trail.emitting = false
	
	if is_on_floor():
		if abs(velocity.x) > 1 or abs(velocity.z) > 1:
			if is_running:
				animation.play("localMotion-library/run", 0.5)
				particle_trail.emitting = true
			else:
				animation.play("localMotion-library/walk", 0.5, 2.0)
		else:
			animation.play("localMotion-library/Idle", 0.5)
	
	else:
		animation.play("localMotion-library/jump",0.5)
			
func jump():
	gravity = -jump_strenght
	jump_single = false;
	jump_double = true;
