extends MoveState
class_name MoveOnTargetState

var _nav2d : NavGridMap2D = null setget set_nav2d
var _levelMap : LevelMap
var _path_initialized : bool = false
var _target_position : Vector2
var only_one = false

### BUILT-IN ###
func _ready():
	if ! get_tree().has_group("Navigation2D") : DEBUG.critical("No Navigation2D")
	set_nav2d(get_tree().get_nodes_in_group("Navigation2D")[0])
	var line : Line2D = get_node_or_null("Line2D")
	if line :
		line.set_as_toplevel(true)
	### TEST ###
	_levelMap = get_tree().get_nodes_in_group(CONSTANTS.GROUP_LEVELMAP)[0]
#	print(_levelMap.get_obstables(2))

### ACCESSORS ###
func set_nav2d(my_nav2d) -> void :
	_nav2d = my_nav2d

### IMPLEMENATION ##
func enter_state() -> void:
	.enter_state()
	
func exit_state() -> void:
	.exit_state()

func update_state(my_delta : float) -> void:
	var __ = my_delta
	process_target()
	process_navigation()
	.update_state(my_delta)

### LOGIC ###
func process_target() -> void :
	var _owner := get_state_owner()
	var _path : Array = []
#	_line2d.global_position = Vector2.ZERO
	if "target" in _owner :
		var _target : KinematicBody2D = _owner.target
		var size = get_move_path().size()
		if _target != null :
#			if _target.global_position != _target_position :
				print("size ", get_move_path().size())
				var _start_pos = _owner.global_position
				var _end_pos = _target.global_position
				_target_position = _end_pos
				_path = _nav2d.get_advanced_simple_path(_start_pos , _end_pos)
				print(_path.size())
		else :
			_path = []
	else :
		_path = []
		DEBUG.critical(_owner.name + " can't chase, no target variable")
	set_move_path(_path)

func process_navigation() -> void :
	var _owner = get_state_owner()
	var _path = get_move_path()
	if _path.size() > 0 :
		set_move_direction(_owner.global_position.direction_to(_path[1]))
		if _owner.global_position == _path[0] :
			pop_move_path()
