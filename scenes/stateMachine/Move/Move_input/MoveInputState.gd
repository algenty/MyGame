extends MoveState
class_name MoveInputstate

var _levelMap : LevelMap

func _ready():
	# To test
	_levelMap = get_tree().get_nodes_in_group(CONSTANTS.GROUP_LEVELMAP)[0]
	pass
	
### IMPLEMENATION ##
func enter_state() -> void:
	.enter_state()
	
func exit_state() -> void:
	.exit_state()

func update_state(my_delta : float) -> void:
	var __ = my_delta
	process_input()
	.update_state(my_delta)
#	_levelMap.get_neighborMap_free_cell(get_state_owner())
#	_levelMap.get_direction_free_cell(get_state_owner())
#	_levelMap.get_neighborPos_free_cell(get_state_owner())

### EVENTS ###
	
### LOGIC ###
func process_input() -> void:
	var _new_direction = Vector2.ZERO
	var _owner = get_state_owner()
	if _owner == null : return
	if (state_properties.enable_diagonal) :
		_new_direction.x = int(int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")) )
		_new_direction.y = int(int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up")) )
		_new_direction.normalized()
	else :
		if _new_direction.y == 0 :
			_new_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
		if _new_direction.x == 0 :
			_new_direction.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	if _new_direction != Vector2.ZERO :
		if _owner.has_method("can_move_toward") :
			if _owner.can_move_toward(_new_direction) :
				set_move_direction(_new_direction)
		else :
			set_move_direction(_new_direction)
