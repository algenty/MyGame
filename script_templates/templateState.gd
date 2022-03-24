extends State
class_name MyState

### SIGNAL ###

### ACCESSORS ###

### BUILT-IN ###

### INTERFACE ###

func enter_state() -> void:
#	Debug.debug("Enter to state ["+ state_name +"]")
	.enter_state()
	
func exit_state() -> void:
#	Debug.debug("Exit to state ["+ state_name +"]")
	.exit_state()
	
func finish_state() -> void:
#	Debug.debug("Finish state ["+ state_name +"]")
	.finish_state()
func update_state(my_delta) -> void:
	var __ = my_delta
	pass

### EVENTS ###


### LOGIC ###
func init_state_properties() -> void :
	state_properties = {
		victory_ point = 10,
		experience_point = 10
	}
