class_name AlphaCamera extends Camera3D

var _camera_to_follow : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(_delta : float) -> void :
	self.transform = _camera_to_follow.transform

func set_camera_to_follow(camera : Node3D) -> void :
	_camera_to_follow = camera;
