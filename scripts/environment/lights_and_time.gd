extends Node

#################################### ATTRIBUTES ####################################


@export var _sun  : DirectionalLight3D
@export var _moon : DirectionalLight3D

## How many minutes pass in game for one minute in real-life
@export_range(1, 1000, 10) var _minute_duration : float = 200
## Start time of the game in minutes (0 -> 00h00, 720 -> 12h00)
@export_range(0, 1440, 30) var _start_time : float = 720
var _current_time : float

#################################### PRIVATE METHODS ####################################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_time = _start_time * 60
	var _rotation : float = 90 - _current_time/240
	_sun.rotation_degrees = Vector3(_rotation, 0, 0)
	_moon.rotation_degrees = Vector3(_rotation+180, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta : float) -> void:
	_current_time += _delta * _minute_duration
	var _rotation : float = 90 - _current_time/240
	_sun.rotation_degrees = Vector3(_rotation, 0, 0)
	_moon.rotation_degrees = Vector3(_rotation+180, 0, 0)