class_name Bubble extends RigidBody3D

const VOLUME_SPHERE : float = 4.0/3.0 * PI

@export_range(0.1, 5.0, 0.1) var max_size : float
@export var mesh : MeshInstance3D
@export var collision : CollisionShape3D

var _size : float
var _sphere_mesh : SphereMesh
var _sphere_collisions : SphereShape3D

signal has_pierced()

func _ready() -> void :
	_size = 0.0
	_sphere_mesh = mesh.mesh as SphereMesh
	_sphere_collisions = collision.shape as SphereShape3D 

	_sphere_mesh.radius = 0.0
	_sphere_mesh.height = 0.0
	_sphere_collisions.radius = 0.0

	contact_monitor = true

func get_size() -> float :
	return _size

func expand(volume_add : float, getting_away_from : Vector3) -> void :
	_size = (_size**3 + volume_add/VOLUME_SPHERE) ** (1.0/3.0)

	if _size > max_size :
		has_pierced.emit()
		queue_free()

	else :
		_sphere_mesh.radius = _size
		_sphere_mesh.height = _size*2.0
		_sphere_collisions.radius = _size
		self.position = getting_away_from * _size

func on_trash_end_recentring(trash : Trash) -> void :
	if trash.size >= _size : 
		has_pierced.emit()
		queue_free()
