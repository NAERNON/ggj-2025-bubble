class_name Dumpster extends Node3D

@export var is_speaking: bool = false:
    set(new_value):
        is_speaking = new_value
        if new_value: start_speaking()
        else: end_speaking()

@export var animation_player: AnimationPlayer

func start_speaking() -> void:
    animation_player.play("dumpster_mouse_speaking")

func end_speaking() -> void:
    animation_player.stop()
