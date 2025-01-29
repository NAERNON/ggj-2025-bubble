class_name Dumpster extends Node3D

@export var trash_detector : Area3D
var trash_speaker : WwiseEvent

@export var is_speaking: bool = false:
	set(new_value):
		is_speaking = new_value
		if new_value: 
			start_speaking()
			trash_speaker_start()
		else: call_deferred("end_speaking")

@export var animation_player: AnimationPlayer

var can_speak : bool

func _ready() -> void:
	Wwise.register_game_obj(self, self.name)
	
	can_speak = true

func start_speaking() -> void:
	animation_player.play("dumpster_mouse_speaking")
func end_speaking() -> void:
	animation_player.stop()

func _physics_process(_delta: float) -> void:
	if trash_detector.has_overlapping_bodies() :
		for node : Node in trash_detector.get_overlapping_bodies() :
			if node is Bubble :
				var bubble : Bubble = node
				bubble.explode()
			elif node is Trash :
				if can_speak :
					is_speaking = true
				var trash : Trash = node
				trash.recycled()
				
func trash_speaker_start() -> void :
	can_speak = false
	trash_speaker = WwiseEvent.new()
	trash_speaker.id = AK.EVENTS.ITEMBIN
	trash_speaker.post_callback(self, AkUtils.AK_END_OF_EVENT, _on_trash_speaker_ended)
				
func _on_trash_speaker_ended(_data) -> void :
	print("prout")
	can_speak = true
	is_speaking = false
	trash_speaker = null
