extends Capacity
class_name RadarBodyCapacity, "./RadarBodyCapacity.svg"

export(String, "Heros", "Enemies") var detected_group_name : String = "Actors"
export(int) var dectector_size = 100
export(bool) var detector_rotate = false

### VARIABLES ####

### SIGNALS ###
signal body_detected(body)


### INIT  & UPDATE & EXIT ###
func init() -> void :
	for _child in get_children() :
		if _child is RadarBodySens :
			var __ = _child.connect("body_detected", self, "_on_child_body_detected")
			_child.set_size(dectector_size) 
	.init()
	
func free() -> void :
	.free()
	
func update(delta : float = get_physics_process_delta_time()) -> void :
	.update(delta)

### EVENTS ###
func _on_child_BODY_DETECTED(my_body) -> void :
	emit_signal("body_detected", my_body)
