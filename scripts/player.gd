extends CharacterBody3D

@onready var head = $head

#Speeds
var current_speed = 7.0
const walking_speed = 7.0
const sprinting_speed = 14.0
const crouching_speed = 5.0
var larp_speed = 10.0

const mouse_sens = 0.25

const JUMP_VELOCITY = 4.5

var direction = Vector3.ZERO

var crouching_depth = 0.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _physics_process(delta):
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
	else:	
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		else:
			current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * larp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
