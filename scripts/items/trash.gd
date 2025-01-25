class_name Trash extends RigidBody3D

@export var bubble_detector  : Area3D
@export var bubble_comparison : CollisionShape3D

@export_range(0.1, 5.0, 0.1) var recentring_duration : float = 3.5
@export var size : float = 0.867

var _recentring : bool
var _recentring_timer : float
var _from_position : Vector3

signal end_recentring()

func _ready() -> void :
	_recentring = false
	_recentring_timer = 0.0

func _physics_process(delta : float) -> void :
	if bubble_detector.monitoring and bubble_detector.has_overlapping_bodies() :
		var bubble : Bubble = bubble_detector.get_overlapping_bodies()[0] as Bubble
		var parent : Node = get_parent()
		
		var global_pos : Vector3 = self.global_position
		parent.remove_child(self)
		bubble.add_child(self)
		self.global_position = global_pos

		end_recentring.connect(bubble.on_trash_end_recentring.bind(self))
		bubble.has_pierced.connect(_on_bubble_pierced)

		self.freeze = true

		_recentring = true
		_recentring_timer = 0.0
		_from_position = self.position

		bubble_detector.monitoring = false

	if _recentring : 
		_recentring_timer += delta

		if _recentring_timer < recentring_duration :
			var t : float = 1.0 - _recentring_timer / recentring_duration

			self.position = t*_from_position

		else :
			_recentring = false
			self.position = Vector3.ZERO
			end_recentring.emit()

func _on_bubble_pierced() -> void :
	var bubble : Bubble = get_parent()
	var main : Node = bubble.get_parent()

	var global_pos : Vector3 = self.global_position
	bubble.remove_child(self)
	main.add_child(self)
	self.global_position = global_pos

	print(self.global_position)

	bubble_detector.monitoring = true
	self.freeze = false
