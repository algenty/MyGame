extends Actor
class_name Hero

### INIT/UPDATE/FREE ###
func init_actor() -> void :
	.init_actor()
	pass
	
func update_actor(delta : float = get_process_delta_time()) -> void :
	.update_actor(delta)
	pass
	
func free_actor() -> void :
	.free_actor()
	pass


### BUILT_IT ###



### EVENTS ###

### LOGIC ###
func collect(my_collectable : Collectable) -> bool :
	print( name + " is Collecting " + my_collectable.name)
	return true
