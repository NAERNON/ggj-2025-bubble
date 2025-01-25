class_name SubViewportAlpha extends SubViewport

func _ready() -> void:
	size = get_tree().root.size;
	get_tree().root.size_changed.connect(_on_main_window_size_changed)
	deactivate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta : float) -> void:
	pass

func deactivate() -> void :
	render_target_clear_mode = SubViewport.CLEAR_MODE_NEVER
	render_target_update_mode = SubViewport.UPDATE_DISABLED

func activate() -> void :
	render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _on_main_window_size_changed() -> void :
	size = get_tree().root.size;