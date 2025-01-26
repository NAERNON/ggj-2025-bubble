class_name Robot extends Node3D

@export var left_wheel_speed: float = 0.0
@export var right_wheel_speed: float = 0.0

@export var head_rotation: Vector2

@export var is_reticule_active: bool = false
@export var reticule_speed: float = 1.0
var _reticule_angle: float = PI

@export var blow_arm_rotation: Vector2

@export var is_headset_active: bool = false
@export var headset_speed: float = 1.0
var _headset_angle: float = 0

@export_group("Meshes")

@export var head: Node3D

@export var blower_arm: Node3D
@export var cannon_anchor: Node3D
@export var cannon_end: Node3D
var _blower_armature: Skeleton3D

@export var left_small_wheel_1: Node3D
@export var left_small_wheel_2: Node3D
@export var left_big_wheel: Node3D
@export var right_small_wheel_1: Node3D
@export var right_small_wheel_2: Node3D
@export var right_big_wheel: Node3D

@export var left_headset: Node3D
@export var right_headset: Node3D

@export var left_caterpillar: CaterpillarTrack
@export var right_caterpillar: CaterpillarTrack

var _big_wheel_rot_factor: float = 0.75
var _caterpillar_factor: float = 0.07

func _ready() -> void:
    _blower_armature = blower_arm.get_node(^"./Armature/Skeleton3D")

func _process(delta: float) -> void:
    _rotate_wheels(delta)
    _rotate_head(delta)
    _rotate_reticule(delta)
    _rotate_headset(delta)
    _rotate_blow_arm(delta)

func _rotate_wheels(delta: float) -> void:
    left_small_wheel_1.rotate_x(delta * left_wheel_speed)
    left_small_wheel_2.rotate_x(delta * left_wheel_speed)
    left_big_wheel.rotate_x(delta * left_wheel_speed * _big_wheel_rot_factor)
    right_small_wheel_1.rotate_x(delta * right_wheel_speed)
    right_small_wheel_2.rotate_x(delta * right_wheel_speed)
    right_big_wheel.rotate_x(delta * right_wheel_speed * _big_wheel_rot_factor)
    
    left_caterpillar.advance_by(delta * left_wheel_speed * _caterpillar_factor)
    right_caterpillar.advance_by(delta * right_wheel_speed * _caterpillar_factor)
    
func _rotate_head(delta: float) -> void:
    head.rotation.x = clampf(head_rotation.x, -0.5, 0.72)
    head.rotation.y = head_rotation.y

func _rotate_reticule(delta: float) -> void:
    var i: int = _blower_armature.find_bone("Reticule")
    var dest_angle: float = 0 if is_reticule_active else PI
    _reticule_angle = move_toward(_reticule_angle, dest_angle, delta * reticule_speed)
    var r: Quaternion = Quaternion(Vector3.UP, _reticule_angle)
    _blower_armature.set_bone_pose_rotation(i, r)
    
func _rotate_headset(delta: float) -> void:
    var dest_angle: float = 0 if is_headset_active else PI/2
    _headset_angle = move_toward(_headset_angle, dest_angle, delta * headset_speed)
    left_headset.rotation.y = _headset_angle
    right_headset.rotation.y = -_headset_angle
    
func _rotate_blow_arm(delta: float) -> void:
    var i: int = _blower_armature.find_bone("Leaf")
    var rot_x = blow_arm_rotation.x
    var rot_y = blow_arm_rotation.y
    var r: Quaternion = Quaternion.from_euler(Vector3(rot_x, 0, rot_y))
    _blower_armature.set_bone_pose_rotation(i, r)
    var q: Quaternion = Quaternion.from_euler(Vector3(rot_x, 0, 0))
    q *= Quaternion.from_euler(Vector3(0, -rot_y, 0))
    cannon_anchor.quaternion = q
