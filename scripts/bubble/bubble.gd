class_name Bubble extends RigidBody3D

const VOLUME_SPHERE : float = 4.0/3.0 * PI

@export var mesh : MeshInstance3D
@export var collision : CollisionShape3D

var max_size : float = 1.75
var _default_distorsion_vert : float = 0.03
var _max_distorsion_vert : float = 0.2

var _default_speed_vert : float = 0.1
var _max_speed_vert : float = 0.75

var _size : float
var _sphere_mesh : SphereMesh
var _sphere_collisions : SphereShape3D

var _bubble_shader : ShaderMaterial

signal has_pierced_c()
signal has_pierced_t(lin_vel : Vector3, ang_vel : Vector3)

func _ready() -> void :
	_size = 0.0
	_sphere_mesh = mesh.mesh as SphereMesh
	_sphere_collisions = collision.shape as SphereShape3D 

	_sphere_mesh.radius = 0.0
	_sphere_mesh.height = 0.0
	_sphere_collisions.radius = 0.0

	contact_monitor = true

	Wwise.register_game_obj(self, self.name)

	_bubble_shader = mesh.get_surface_override_material(0)

func get_size() -> float :
	return _size

func expand(volume_add : float, getting_away_from : Vector3) -> void :
	_size = (_size**3 + volume_add/VOLUME_SPHERE) ** (1.0/3.0)

	var t : float = 1.0 / (1.0 + exp(-15.0 * (_size - 1.5)))

	var dist_vert = lerp(_default_distorsion_vert, _max_distorsion_vert, t)
	var speed_vert = lerp(_default_speed_vert, _max_speed_vert, t)

	_bubble_shader.set_shader_parameter("distortionVertex", dist_vert)
	_bubble_shader.set_shader_parameter("speedVertex", speed_vert)

	if _size > max_size :
		explode()

	else :
		_sphere_mesh.radius = _size
		_sphere_mesh.height = _size*2.0
		_sphere_collisions.radius = _size
		self.position = getting_away_from * _size

func explode() -> void :
	Wwise.set_3d_position(self, self.global_transform)
	Wwise.post_event_id(AK.EVENTS.BUBBLEEXPLODE, self)
	has_pierced_t.emit(linear_velocity, angular_velocity)
	has_pierced_c.emit()
	queue_free()

func on_trash_start_recentring() -> void :
	Wwise.set_3d_position(self, self.global_transform)
	Wwise.post_event_id(AK.EVENTS.BUBBLETAKEOBJECT, self)

func on_trash_end_recentring(trash : Trash) -> void :
	if trash.size >= _size : 
		explode()

func on_released(_bubble : Bubble, _world_pos : Vector3) -> void :
	_bubble_shader.set_shader_parameter("distortionVertex", _default_distorsion_vert)
	_bubble_shader.set_shader_parameter("speedVertex", _default_speed_vert)
