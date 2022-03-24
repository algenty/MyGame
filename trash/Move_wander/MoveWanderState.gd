extends MoveState
class_name MoveWanderState

var _nav2d : Navigation2D = null setget set_nav2d
var _leveMap : LevelMap = null setget set_levelmap
onready var line2D : Line2D = $Line2D

### BUILT-IN ###
func _ready():
	line2D.points = []
	if ! get_tree().has_group("Navigation2D") : DEBUG.critical("No Navigation2D")
	set_nav2d(get_tree().get_nodes_in_group("Navigation2D")[0])

### ACCESSORS ###
func set_nav2d(my_nav2d : Navigation2D) -> void :
	_nav2d = my_nav2d
	
func set_levelmap(my_lvl : LevelMap) -> void :
	_leveMap = my_lvl

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
func process_nextcell() -> void :
	var _owner := get_state_owner()
	var _path : Array = []
	line2D.global_position = Vector2.ZERO
	if "target" in _owner :
		var _target : KinematicBody2D = _owner.target
		ONSCREEN.put(_owner, "Target", _target.get_instance_id())
		if _target != null :
			_path = _nav2d.get_simple_path(_owner.global_position + Vector2(8,8) , _target.global_position + Vector2(8,8) , false)
			_path.remove(0)
		else :
			_path = []
	else :
		_path = []
		DEBUG.critical(_owner.name + " can't chase, no target variable")
	set_move_path(_path)
	line2D.points = get_move_path()

func process_navigation() -> void :
	var _owner = get_state_owner()
	var _path = get_move_path()
	if _path.size() > 0 :
		set_move_direction(_owner.global_position.direction_to(_path[1]))
		if global_position == _path[0]:
			var __ = pop_move_path()
