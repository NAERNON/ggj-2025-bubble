class_name FocusCamera extends Camera3D

#################################### CONSTANTES ####################################

const E : float = 0.001
const PI180 : float = PI / 180

#################################### ATTRIBUTES ####################################

@export var _focus            : Player
@export var _check_obstacle   : ShapeCast3D

# Camera position attributes
@export_group("Position parameters")
@export_range(0, 10, 1)   var _max_distance                : float = 5
@export_range(0, 10, 1)   var _focus_radius                : float = 1
@export_range(1, 10, 0.1) var _rotation_speed              : float = 1
@export_range(0, 1, 0.1)  var _focus_centering             : float = 0.75
@export_range(-89, 0, 1)  var _min_vertical_angle          : float = -60
@export_range(0, 89, 1)   var _max_vertical_angle          : float = 30
@export_range(0, 2, 0.1)  var _distance_focus_start_fading : float = 1.5
@export_range(0, 1, 0.1)  var _distance_focus_end_fading   : float = 1.0

var _orbit_angles           : Vector3 = Vector3(0, PI, 0)
var _distance               : float
var _desired_distance       : float
@export_range(0, 1, 0.1) var _max_distance_changed   : float = 0.3
var _distance_from_obstacle : float
var _focus_point            : Vector3
var _previous_focus_point   : Vector3

var _can_change        : bool

#################################### PRIVATE METHODS ####################################

func _ready() -> void :
		
	_distance    = _max_distance
	_focus_point = _focus.global_position
	_min_vertical_angle = _min_vertical_angle * PI180
	_max_vertical_angle = _max_vertical_angle * PI180

	if _distance_focus_end_fading > _distance_focus_start_fading :
		var temp : float = _distance_focus_end_fading
		_distance_focus_end_fading = _distance_focus_start_fading
		_distance_focus_start_fading = temp

	_can_change        = true
	
	var viewport_size : Vector2 = get_viewport().get_visible_rect().size
	var box_shape : BoxShape3D = BoxShape3D.new()
	var aspect_ratio : float = viewport_size.x / viewport_size.y
	var half_extends_y : float = near * tan(0.5 * fov * PI180)
	box_shape.size = Vector3(8 * half_extends_y * aspect_ratio, 8 * half_extends_y, 0)
	_check_obstacle.shape = box_shape
	
	position = _focus_point - Quaternion.from_euler(_orbit_angles).normalized() * Vector3.FORWARD * _distance
	rotation = _orbit_angles
	
func _process(_delta : float) -> void :
	pass

	
func _physics_process(delta : float) -> void:

	_input_rotation(delta)
	_constraint_angles()
	
	_update_position(delta)

#################################### POSITION (UPDATE / CONSTRAINT) METHODS #####################################
	
func _input_rotation(delta : float) -> void :
	var input : Vector3 = Vector3.ZERO
	input.x = Input.get_axis("camera_down", "camera_up")
	input.y = Input.get_axis("camera_right", "camera_left")
	
	if input.x < -E or input.x > E or input.y < -E or input.y > E :
		_orbit_angles += _rotation_speed * delta * input
	
func _constraint_angles() -> void :
	_orbit_angles.x = clamp(_orbit_angles.x, _min_vertical_angle, _max_vertical_angle)
	
	if _orbit_angles.y < 0 :
		_orbit_angles.y += 2*PI
		
	elif _orbit_angles.y > 2*PI :
		_orbit_angles.y -= 2*PI
	
func _update_position(delta : float) -> void :
	_update_focus_point(delta)
	
	var look_direction : Vector3 = Quaternion.from_euler(_orbit_angles).normalized() * Vector3.FORWARD
	var look_position : Vector3 = _focus_point - look_direction * _distance
	
	# Check for obstacle between focus point and camera
	_check_obstacle.global_position = _focus.global_position
	_check_obstacle.global_rotation = _orbit_angles
	_check_obstacle.target_position = -Vector3.FORWARD * _distance

	_desired_distance = _distance

	if _check_obstacle.is_colliding() :
		print(_check_obstacle.get_collider(0))
		_desired_distance = min(_check_obstacle.get_closest_collision_safe_fraction() * _distance, _max_distance)     


	if _desired_distance > _distance_from_obstacle :
		_distance_from_obstacle = move_toward(_distance_from_obstacle, _desired_distance, _max_distance_changed)
	else :
		_distance_from_obstacle = _desired_distance

	look_position = _focus_point - look_direction * _distance_from_obstacle
	
	position = look_position
	rotation = _orbit_angles
	
func _update_focus_point(delta : float) -> void :
	_previous_focus_point = _focus_point
	var target_point : Vector3 = _focus.global_position
	
	if _focus_radius > 0 :
		var dist : float = target_point.distance_to(_focus_point)
		var t : float = 1
		
		if dist > 0.01 and _focus_centering > 0 :
			t = pow(1 - _focus_centering, delta)
		
		if dist > _focus_radius :
			t = min(t, _focus_radius / dist)
		
		_focus_point = _focus_point.lerp(target_point, t)
	
	else :
		_focus_point = target_point

func deactivate_camera() -> void :
	self.current = false

func activate_camera() -> void : 
	self.current = true