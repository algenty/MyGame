extends Capacity
class_name RadarBodyCapacity, "./RadarBodyCapacity.svg"

export(String, "Heros", "Enemies") var detected_group_name : String = "Actors"
export(String) var orwner_target_property = "target"
export(int) var dectector_size = 100

### VARIABLES ####
var owner_target_property_available : bool = false
var body_target : Node = null setget set_target, get_target

### SIGNALS ###
signal body_detected(body)


### ACCESSORS ###
func set_target(value) -> void :
	if value != body_target :
		body_target = value
		if owner_target_property_available :
			get_owner_node().target = value
		if value != null :
			emit_signal("body_detected", value)


func get_target() -> Node :
	return body_target


func get_target_position() -> Vector2 :
	if has_target() :
		return body_target.global_position
	return Vector2.ZERO


### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	.init_capacity()
	var __ : int = 0
	var __agent = get_owner_node()
	if __agent == null :
			DEBUG.critical("Owner node cannot be null")
	if __agent && orwner_target_property != null && not orwner_target_property.empty() :
		if orwner_target_property in __agent :
			owner_target_property_available = true
		else :
			DEBUG.critical("Owner node [%s] have no property [%s]" % [str(__agent), orwner_target_property])
	for __child in get_children() :
		if __child is RadarBodySens :
			__ = __child.connect("body_entered", self, "_on_child_body_entered")
			__ = __child.connect("body_exited", self, "_on_child_body_exited")
			__child.set_size(dectector_size)
			__child.set_owner_node(__agent)


func free_capacity() -> void :
	.free_capacity()


func update_capacity(delta : float = get_physics_process_delta_time()) -> void :
	.update_capacity(delta)


### LOGIC ###
func has_target() -> bool :
	return body_target != null

### EVENTS ###
func _on_child_body_entered(my_body) -> void :
	set_target(my_body)
	
func _on_child_body_exited() -> void :
	set_target(null)
