extends Label


export(bool) var enable : bool = true


func _ready():
	set_process(enable)
	set_physics_process(enable)
	set_visible(enable)

func is_enable() -> bool :
	return enable
