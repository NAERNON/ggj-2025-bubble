class_name Blow extends RigidBody3D

@export var life_time : Timer
@export var collision : CollisionShape3D

var _sphere_collision : SphereShape3D

func _ready() -> void :
	_sphere_collision = collision.shape as SphereShape3D

func set_collision_size(radius : float) -> void : 
	_sphere_collision.radius = radius

func _process(_delta : float) -> void :
	if life_time.is_stopped() :
		queue_free()