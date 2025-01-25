class_name CaterpillarTrack extends Path3D

var _parts: Array[PathFollow3D]
var _parts_count: int = 26

func _ready() -> void:
    var scene: PackedScene = preload("res://assets/robot/parts_scenes/caterpillar.tscn")
    for i in range(_parts_count):
        var follow: PathFollow3D = PathFollow3D.new()
        _parts.append(follow)
        var node: Node3D = scene.instantiate()
        
        follow.add_child(node)
        add_child(follow)
        
        follow.progress_ratio = float(i) / float(_parts_count)

func advance_by(x: float) -> void:
    for f: PathFollow3D in _parts:
        f.progress_ratio += x
