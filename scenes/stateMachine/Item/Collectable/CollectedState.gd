extends State_old
class_name CollectedState


### SIGNAL ###

### ACCESSORS ###

### BUILT-IN ###

### INTERFACE ###

func enter_state() -> void:
	.enter_state()
	var _owner = get_state_owner()
#	_owner.visible = false
	finish_state()
	
func exit_state() -> void:
	.exit_state()
	queue_free()
	
func finish_state() -> void:
	.finish_state()
	
func update_state(my_delta) -> void:
	var __ = my_delta
	pass

### EVENTS ###


### LOGIC ###

