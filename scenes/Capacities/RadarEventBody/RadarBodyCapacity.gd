extends Capacity
class_name RadarBodyCapacity, "./RadarBodyCapacity.svg"

export(String, "Heros", "Enemies") var detected_group_name : String = "Actors"
export(int) var dectector_size = 100

### VARIABLES ####

### SIGNALS ###
signal body_detected(body)


### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	.init_capacity()
	var __agent = get_owner_node()
	for __child in get_children() :
		if __child is RadarBodySens :
			var __ = __child.connect("body_entered", self, "_on_child_body_entered")
			__child.set_size(dectector_size)
			__child.set_owner_node(__agent)
			 
	
func free_capacity() -> void :
	.free_capacity()
	
func update_capacity(delta : float = get_physics_process_delta_time()) -> void :
	.update_capacity(delta)

### EVENTS ###
func _on_child_body_entered(my_body) -> void :
	emit_signal("body_detected", my_body)
