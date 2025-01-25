extends Node

@export var environment : WorldEnvironment
@export var _rain : GPUParticles3D
@export_range(1.0, 240.0, 0.1) var _weather_time_trans : float
@export var _weather_duration_random : Vector2


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
	var switch_meteo : float = GlobalUtils.random_generator.randi_range(_weather_duration_random.x as int, _weather_duration_random.y as int)
	_meteo_timer = Timer.new()
	_meteo_timer.autostart = true
	_meteo_timer.one_shot = true
	add_child(_meteo_timer)
	_meteo_timer.start(switch_meteo)
	
	if _current_state == "rainy" :
		_set_clouds_params(_rainy_clouds_cutoff, _rainy_clouds_weight, true)

	elif _current_state == "sunny" :
		_set_clouds_params(_sunny_clouds_cutoff, _sunny_clouds_weight, false)

	_timer_trans = 0
	_is_weather_trans = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float) -> void :
	if _is_weather_trans :
		_timer_trans -= delta
		_timer_trans = max(0, _timer_trans)

		var clouds_cutoff : float
		var clouds_weight : float
		var t : float = 1 - _timer_trans / _weather_time_trans

		if _current_state == "sunny" :
			clouds_cutoff = lerp(_rainy_clouds_cutoff, _sunny_clouds_cutoff, t)
			clouds_weight = lerp(_rainy_clouds_weight, _sunny_clouds_weight, t)
			

		elif _current_state == "rainy" :
			clouds_cutoff = lerp(_sunny_clouds_cutoff, _rainy_clouds_cutoff, t)
			clouds_weight = lerp(_sunny_clouds_weight, _rainy_clouds_weight, t)

		_set_clouds_params(clouds_cutoff, clouds_weight, false)

		if _timer_trans == 0 :
			_is_weather_trans = false
			var switch_meteo : float = GlobalUtils.random_generator.randi_range(_weather_duration_random.x as int, _weather_duration_random.y as int)
			_meteo_timer.start(switch_meteo)

			if _current_state == "rainy" :
				_set_clouds_params(_rainy_clouds_cutoff, _rainy_clouds_weight, true)

			elif _current_state == "sunny" :
				_set_clouds_params(_sunny_clouds_cutoff, _sunny_clouds_weight, false)


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

func _set_clouds_params(cutoff : float, weight : float, is_raining : bool) -> void :
	_sky_material.set_shader_parameter("clouds_cutoff", cutoff)
	_sky_material.set_shader_parameter("clouds_weight", weight)
	_rain.emitting = is_raining
