extends Node3D

@export var left_wheel_speed: float = 0.0
@export var right_wheel_speed: float = 0.0

@export var head_rotation: Vector2:
    set(new_value): 
        head_rotation = new_value
        print("ok")

@export_group("Meshes")

@export var head: Node3D

@export var left_small_wheel_1: Node3D
@export var left_small_wheel_2: Node3D
@export var left_big_wheel: Node3D
@export var right_small_wheel_1: Node3D
@export var right_small_wheel_2: Node3D
@export var right_big_wheel: Node3D

@export var left_headset: Node3D
@export var right_headset: Node3D

var _big_wheel_rot_factor: float = 0.5

func _process(delta: float) -> void:
    _rotate_wheels(delta)
    head.rotation = Vector3(head_rotation.x, 0, head_rotation.y)

func _rotate_wheels(delta: float) -> void:
    left_small_wheel_1.rotate_x(delta * left_wheel_speed)
    left_small_wheel_2.rotate_x(delta * left_wheel_speed)
    left_big_wheel.rotate_x(delta * left_wheel_speed * _big_wheel_rot_factor)
    right_small_wheel_1.rotate_x(delta * right_wheel_speed)
    right_small_wheel_2.rotate_x(delta * right_wheel_speed)
    right_big_wheel.rotate_x(delta * right_wheel_speed * _big_wheel_rot_factor)
