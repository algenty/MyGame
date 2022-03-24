extends State_old
class_name CollectState

### SIGNAL ###

### ACCESSORS ###

### BUILT-IN ###


### INTERFACE ###

func enter_state() -> void:
	.enter_state()
	var _owner = get_state_owner()
	if _owner.target_in_collect_erea && _owner.target != null :
		if _owner.target is Character && _owner.target.has_method("collect") :
			_owner.target.collect(_owner)
			finish_state()
	
func exit_state() -> void:
	.exit_state()
	
func finish_state() -> void:
	.finish_state()
	
func update_state(my_delta) -> void:
	var __ = my_delta
	pass

### EVENTS ###


### LOGIC ###
