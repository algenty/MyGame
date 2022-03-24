extends Node2D
class_name State_old

var _is_enter : bool = false
var _is_finished : bool = true
var state_properties : Dictionary = {}

onready var state_name : String = self.name 

### SIGNAL ###
signal STATE_FINISHED

### ACCESSORS ###

func get_state_owner() -> Node :
	return owner

func get_state_properties() -> Dictionary :
	return state_properties
	
func get_state_name() -> String : 
	return state_name

### BUILT-IN ###

### INTERFACE ###

func enter_state() -> void:
	DEBUG.debug("Object [" + owner.name + "] Enter to state ["+ state_name +"]")
	_is_finished = false
	_is_enter = true
	
func exit_state() -> void:
	DEBUG.debug("Object [" + owner.name + "] Exit to state ["+ state_name +"]")
	_is_finished = true
	_is_enter = false
	
func finish_state() -> void:
	DEBUG.debug("Object [" + owner.name + "] Finish state ["+ state_name +"]")
	emit_signal("STATE_FINISHED", self)
	
func update_state(my_delta) -> void:
	var __ = my_delta
	pass

func is_current_state() -> bool:
	return _is_enter
	
func is_finished_state() -> bool:
	return _is_finished

### EVENTS ###


### LOGIC ###

