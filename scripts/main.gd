extends Node

@export var main_camera : FocusCamera
@export var player : Player
@export var environment : WorldEnvironment
@export var _rain : GPUParticles3D
@export_range(1.0, 240.0, 0.1) var _weather_time_trans : float
@export var _sunny_duration_random : Vector2
@export var _rainy_duration_random : Vector2

@export var rtpc_weather : WwiseRTPC

var _sky_material : ShaderMaterial

var _sunny_clouds_cutoff : float = 0.45
var _sunny_clouds_weight : float = 0

var _rainy_clouds_cutoff : float = 0.09
var _rainy_clouds_weight : float = 1

var _current_state : String

var _meteo_timer : Timer
var _timer_trans : float
var _is_weather_trans : bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void :
	_sky_material = environment.environment.sky.sky_material as ShaderMaterial

	_current_state = GlobalState.state
	var weather_duration : float = GlobalUtils.random_generator.randi_range(_sunny_duration_random.x as int, _sunny_duration_random.y as int)
	_meteo_timer = Timer.new()
	_meteo_timer.autostart = true
	_meteo_timer.one_shot = true
	add_child(_meteo_timer)
	_meteo_timer.start(weather_duration)
	
	if _current_state == "rainy" :
		_set_clouds_params(_rainy_clouds_cutoff, _rainy_clouds_weight, true)

	elif _current_state == "sunny" :
		_set_clouds_params(_sunny_clouds_cutoff, _sunny_clouds_weight, false)

	_timer_trans = 0
	_is_weather_trans = false

	var cannon : Cannon = get_node("Player/Robot/cannon_anchor/cannon_end/Cannon")
	cannon.bubble_released.connect(_on_cannon_bubble_released)
	cannon.turret_mod_start.connect(_on_turret_mod_started)
	cannon.turret_mod_end.connect(_on_turret_mod_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void :
	if _is_weather_trans :
		_timer_trans -= delta
		_timer_trans = max(0, _timer_trans)

		var clouds_cutoff : float
		var clouds_weight : float
		var t : float = 1 - _timer_trans / _weather_time_trans

		rtpc_weather.set_value($AmbientSound, t*100.0)

		if _current_state == "sunny" :
			clouds_cutoff = lerp(_rainy_clouds_cutoff, _sunny_clouds_cutoff, t)
			clouds_weight = lerp(_rainy_clouds_weight, _sunny_clouds_weight, t)
			

		elif _current_state == "rainy" :
			clouds_cutoff = lerp(_sunny_clouds_cutoff, _rainy_clouds_cutoff, t)
			clouds_weight = lerp(_sunny_clouds_weight, _rainy_clouds_weight, t)

		_set_clouds_params(clouds_cutoff, clouds_weight, t)

		if _timer_trans == 0 :
			_is_weather_trans = false

			if _current_state == "rainy" :
				var weather_duration : float = GlobalUtils.random_generator.randi_range(_rainy_duration_random.x as int, _rainy_duration_random.y as int)
				_meteo_timer.start(weather_duration)
				_set_clouds_params(_rainy_clouds_cutoff, _rainy_clouds_weight, 1.0)

			elif _current_state == "sunny" :
				var weather_duration : float = GlobalUtils.random_generator.randi_range(_sunny_duration_random.x as int, _sunny_duration_random.y as int)
				_meteo_timer.start(weather_duration)
				_set_clouds_params(_sunny_clouds_cutoff, _sunny_clouds_weight, 0.0)


	else :
		if _meteo_timer.is_stopped() :
			_is_weather_trans = true
			_timer_trans = _weather_time_trans
			if _current_state == "rainy" :
				_current_state = "sunny"
				GlobalState.state = "sunny"

			elif _current_state == "sunny" :
				_current_state = "rainy"
				GlobalState.state = "rainy"

func _set_clouds_params(cutoff : float, weight : float, raining_amount : float) -> void :
	_sky_material.set_shader_parameter("clouds_cutoff", cutoff)
	_sky_material.set_shader_parameter("clouds_weight", weight)
	if raining_amount <= 0.4 :
		_rain.emitting = false
	else :
		_rain.emitting = true
		_rain.amount_ratio = (raining_amount - 0.4) / 0.6

func _on_cannon_bubble_released(bubble : Bubble, world_position : Vector3) -> void :
	self.add_child(bubble)
	bubble.global_position = world_position

func _on_turret_mod_started() :
	main_camera.deactivate_camera()
	player.activate_turret_camera()

func _on_turret_mod_ended() :
	player.deactivate_turret_camera()
	main_camera.activate_camera()
