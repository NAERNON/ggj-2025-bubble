class_name Player extends CharacterBody3D

const G_FORCE : float = 9.8

#################################### ATTRIBUTES ####################################
@export var robot : Robot

@export_group("Camera")
@export var _main_camera    : Node3D

var _desired_velocity      : Vector3

# Walking and falling deplacement parameters (using velocity)
@export_group("Walking - Running")
@export_range(0, 100, 1)   var _walking_acceleration  : float = 60
@export_range(0, 100, 1)   var _walking_decceleration : float = 80
@export_range(0, 1.6, 0.1) var _reversal_angle        : float = 1.6
@export_range(0, 100, 1)   var _run_speed             : float = 40
@export_range(0, 100, 1)   var _walk_speed            : float = 25

@export_range(0, 10, 0.1) var ratio_speed_wheel : float = 1.0


# Player 3D model (mesh, hitbox, etc...)

# Inputs and deplacements parameters
var _can_move              : bool
var _frames_without_inputs : int
var _previous_inputs       : Vector3
var _process_inputs        : bool

# Player states for inputs and interactions
var _is_falling          : bool
var _is_just_falling     : bool
var _is_walking          : bool

#################################### PRIVATE METHODS ####################################

func _ready() -> void :

	# Number of time player try to climb a slope before stopping
	max_slides = 3

	_frames_without_inputs = 100
	_previous_inputs       = Vector3(0, 0, 0)
	_process_inputs        = true

	_can_move = true
	_is_just_falling = true


func _process(_delta : float) -> void :
	pass
					
func _physics_process(delta : float) -> void :
	if is_on_floor() :
		_is_walking      = true
		_is_just_falling = true
	else :
		_is_walking            = false
		if _is_just_falling :
			_is_just_falling    = false
			_is_falling         = true

	var _as_collided : bool = move_and_slide()

	if Input.is_action_just_pressed("turret_mod") :
		_can_move = false

	elif Input.is_action_just_released("turret_mod") :
		_can_move = true

	if _process_inputs :
		# Check for deplacements inputs in terms of player states (walking, falling, gliding)
		if _can_move :
			if _is_walking :
				if not (velocity * Vector3(1, 0, 1)).is_zero_approx() :
					var to_look : Vector3 = global_position
					to_look.x -= velocity.x
					to_look.z -= velocity.z
					look_at(to_look, Vector3.UP)

				_walking_inputs(delta)
				velocity = _desired_velocity

			elif _is_falling :
				_desired_velocity.y -= G_FORCE*delta

				velocity = _desired_velocity


	if not _can_move :
		velocity.x          = 0
		velocity.z          = 0
		_desired_velocity.x = 0
		_desired_velocity.z = 0


#################################### INPUTS MOVEMENT DEALING METHODS #####################################
# All of this methods check for inputs in regards with the current player state (walking, falling, gliding, etc.)
# They all update the _desired_velocity attributes

func _walking_inputs(delta : float) -> void : 
	var inputs : Vector3 = Vector3.ZERO
	var to_velocity : Vector3 = Vector3.ZERO

	var slide_inputs : Vector2 = Input.get_vector("movement_left", "movement_right", "movement_down", "movement_up")
	inputs.x = slide_inputs.x
	inputs.z = slide_inputs.y
	inputs.y = velocity.y

	var camera_look_at_forward : Vector3 = -_main_camera.basis.z
	camera_look_at_forward.y = 0
	camera_look_at_forward   = camera_look_at_forward.normalized()

	var camera_look_at_right : Vector3 = _main_camera.basis.x
	camera_look_at_right.y = 0
	camera_look_at_right   = camera_look_at_right.normalized()

	var is_running : bool = Input.is_action_pressed("movement_run")
	
	to_velocity   = inputs.z * camera_look_at_forward + inputs.x * camera_look_at_right
	to_velocity  *= _run_speed if is_running else _walk_speed
	to_velocity.y = inputs.y

	if _frames_without_inputs < 5 and inputs.angle_to(-_previous_inputs) < _reversal_angle :
		velocity.x = 0
		velocity.z = 0

	var is_inputs : bool = (inputs.length() != 0)

	if is_inputs :
		_frames_without_inputs = 0
		_previous_inputs = inputs
	else :
		_frames_without_inputs += 1
	
	var velocity_changed : bool = is_inputs or _frames_without_inputs < 3

	var max_speed_change : float = 0
	if velocity_changed :
		max_speed_change = _walking_acceleration * delta
	else :
		if velocity.length() != 0 :
			max_speed_change = _walking_decceleration * delta

	_desired_velocity.x = move_toward(velocity.x, to_velocity.x, max_speed_change)
	_desired_velocity.z = move_toward(velocity.z, to_velocity.z, max_speed_change)
	_desired_velocity.y = to_velocity.y

	robot.left_wheel_speed = _desired_velocity.length() * ratio_speed_wheel
	robot.right_wheel_speed = _desired_velocity.length() * ratio_speed_wheel

#################################### PUBLIC METHODS #####################################

func process_input(pi : bool) -> void :
	_process_inputs = pi

func stop_movement() -> void :
	velocity.x = 0
	velocity.z = 0