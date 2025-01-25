class_name BlowingEffect extends Node3D

#################################### ATTRIBUTES ####################################

@export var looping_wind : GPUParticles3D
@export var default_wind : GPUParticles3D

var looping_material : ParticleProcessMaterial
var default_material : ParticleProcessMaterial

func _ready() -> void :
	looping_material = looping_wind.process_material as ParticleProcessMaterial
	default_material = default_wind.process_material as ParticleProcessMaterial

func deactivate_flow() -> void :
	looping_wind.emitting = false
	default_wind.emitting = false

func activate_flow() -> void :
	looping_wind.emitting = true
	default_wind.emitting = true

func set_flow_velocity(flow : float) -> void :

	var norm_flow : float = flow / 5.0

	looping_wind.lifetime = max(0.1, norm_flow * 2.0)
	default_wind.lifetime = max(0.1, norm_flow * 2.0)

	looping_wind.speed_scale = norm_flow
	default_wind.speed_scale = norm_flow
