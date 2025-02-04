class_name Cannon extends Node3D

## Maximum blowing cannon power (represent how much the blow reach the bubble and push it)
@export_range(0.1, 10.0, 0.05) var max_blow_power = 5.0
## Blowing cannon range (represent the life time of the blow)
@export_range(0.0, 10.0, 0.5) var blow_range = 5.0
## Blowing cannon width (represent the width of effect of the blowing cannon)
@export_range(0.0, 2.0, 0.1) var blow_width = 1.0

@export var blow_timer   : Timer

@export var bubble_scene : PackedScene
@export var blow_scene   : PackedScene

@export var rtpc_blower_velocity : WwiseRTPC
@export var rtpc_bubble_size     : WwiseRTPC

var _can_blow : bool
var _blow_time : float

var _in_turret_mod : bool :
	set(new_value) :
		_in_turret_mod = new_value

		if _in_turret_mod :
			turret_mod_start.emit()
		else :
			turret_mod_end.emit()

var _in_bubble_mod : bool :
	set(new_value) :
		_in_bubble_mod = new_value

		_robot.is_reticule_active = _in_bubble_mod

var _current_expanding_bubble : Bubble

var _focus_camera : FocusCamera
var _robot : Robot

var _bubble_apparition : bool

var _player_event : AkEvent3D

signal bubble_released(bubble : Bubble, world_pos : Vector3)
signal turret_mod_start()
signal turret_mod_end()


func _ready() -> void :
	_can_blow = true
	_blow_time = blow_timer.wait_time

	_in_turret_mod = false
	_in_bubble_mod = false

	_bubble_apparition = true

	Wwise.register_game_obj(self, self.name)

func _physics_process(delta : float) -> void :
	if blow_timer.is_stopped() :
		_can_blow = true

	_input_mods()

	if _in_bubble_mod :
		_input_bubble_cannon(delta)

	else :
		_input_blowing_cannon()

func set_attributes(camera : FocusCamera, robot : Robot, player_event : AkEvent3D) -> void :
	_focus_camera = camera
	_robot = robot
	_player_event = player_event

func _input_mods() :
	if Input.is_action_just_pressed("turret_mod") :
		_in_turret_mod = true
	elif Input.is_action_just_released("turret_mod") :
		_in_turret_mod = false

	if Input.is_action_just_pressed("bubble_mod") :
		_in_bubble_mod = true
		_current_expanding_bubble = bubble_scene.instantiate()
		_current_expanding_bubble.has_pierced_c.connect(_on_current_expanding_bubble_pierced)
		bubble_released.connect(_current_expanding_bubble.on_released)
		self.add_child(_current_expanding_bubble)
	elif Input.is_action_just_released("bubble_mod") :
		_in_bubble_mod = false
		_try_release_bubble()

func _input_bubble_cannon(delta : float) :
	if Input.is_action_pressed("blow_cannon") :
		if _bubble_apparition :
			Wwise.post_event_id(AK.EVENTS.BUBBLECREATE, self)
			_bubble_apparition = false
		var blowing_strengh : float = Input.get_action_strength("blow_cannon")
		var blowing_power : float = max_blow_power * blowing_strengh

		_current_expanding_bubble.expand(blowing_power * delta, transform.basis.z)

func _input_blowing_cannon() : 
	if Input.is_action_pressed("blow_cannon") :
		var blowing_strengh : float = Input.get_action_strength("blow_cannon")
		var blowing_power : float = max_blow_power * blowing_strengh

		rtpc_blower_velocity.set_value(_player_event, blowing_strengh*100.0)

		var blowing_direction : Vector3

		if _in_turret_mod :
			blowing_direction = _robot.cannon_end.global_transform.basis.z

		else :
			blowing_direction = global_transform.basis.z

		if _can_blow :
			_can_blow = false
			blow_timer.start(_blow_time)
			var blow : Blow = blow_scene.instantiate()
			self.add_child(blow)
			blow.top_level = true
			blow.set_collision_size(blow_width)
			blow.apply_impulse(blowing_direction * blowing_power)
	else :
		rtpc_blower_velocity.set_value(_player_event,0.0)

func _on_current_expanding_bubble_pierced() :
	self.remove_child(_current_expanding_bubble)
	_current_expanding_bubble = null
	_in_bubble_mod = false
	_bubble_apparition = true

func _try_release_bubble() -> void :
	if _current_expanding_bubble != null and _current_expanding_bubble.get_size() > 0.0 :
		_current_expanding_bubble.has_pierced_c.disconnect(_on_current_expanding_bubble_pierced)
		var bubble_position_in_world : Vector3 = _current_expanding_bubble.global_position
		self.remove_child(_current_expanding_bubble)
		bubble_released.emit(_current_expanding_bubble, bubble_position_in_world)
		_current_expanding_bubble = null
		Wwise.set_3d_position(self, self.global_transform)
		Wwise.post_event_id(AK.EVENTS.BUBBLENOEXPLODE, self)
