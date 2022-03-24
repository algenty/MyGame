extends State
class_name IdleState

### BUILT_IN ###


### IMPLEMENATION ##

func enter_state() -> void:
#	var move_state : MoveState = get_state_owner().state_machine.get_state_node("Move")
#	move_state.set_move_direction(move_state.get_move_direction() * -1)
#	get_state_owner().state_machine.set_state("Move")
	.enter_state()
#	update_animation()

	
func exit_state() -> void:
	.exit_state()

func update_state(my_delta : float) -> void:
	.update_state(my_delta)


### LOGIC ###

