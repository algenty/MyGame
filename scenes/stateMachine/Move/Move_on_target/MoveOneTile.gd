extends MoveState
class_name MoveOnTile

var _levelMap : LevelMap
var target_cell_grid : Vector2 setget set_target_grid_cell
var target_direction : Vector2 setget set_target_direction
var _previous_distance : float = 0.0


signal TARGET_CELL_CHANGED(cell)
signal TARGET_DIRECTION_CHANGED(dir)

### BUILT-IN ###
func _ready():
	if $Polygon2D :
		$Polygon2D.set_as_toplevel(true)
	_levelMap = get_tree().get_nodes_in_group(CONSTANTS.GROUP_LEVELMAP)[0]
	randomize()
	state_properties.stop_on_vel_zero = false
	connect("TARGET_CELL_CHANGED", self, "_on_Movetarget_cell_grid_CHANGED")

### ACCESSORS ###
func set_target_grid_cell(_target : Vector2) -> void :
	if _target != target_cell_grid :
		target_cell_grid = _target
		emit_signal("TARGET_CELL_CHANGED", _target)

func set_target_direction(_dir : Vector2) -> void :
	if target_direction !=  _dir :
		target_direction = _dir
		emit_signal("TARGET_DIRECTION_CHANGED", _dir)

### IMPLEMENATION ##
func enter_state() -> void:
	.enter_state()
	
func exit_state() -> void:
	.exit_state()

func update_state(my_delta : float) -> void:
	var __ = my_delta
	process_navigation(my_delta)
	.update_state(my_delta)

#### LOGIC ###

func process_navigation(delta) -> void :
	var _owner = get_state_owner()
	var _current_grid = _levelMap.get_cell_grid_from_object(_owner)
	var _distance : float = _levelMap.get_global_distance_between_gridcell_and_obj(target_cell_grid, _owner) if target_cell_grid != Vector2.ZERO else 0.0 
#	ONSCREEN.put(_owner, "Target Cell", target_cell_grid)
#	ONSCREEN.put(_owner, "Distance Cell", _distance)
	if _distance >= _previous_distance or _distance <= 4.0 :
		var _dirs = _levelMap.get_direction_free_cell(_owner)
		if _dirs.size() > 1 :
			var _i : int = _dirs.find(get_move_direction() * -1)
			if _i != -1 : _dirs.remove(_i)
		var _dir_index = randi() % _dirs.size()
		var _new_dir = _dirs[_dir_index]
		var _target_cell_grid = _current_grid + _new_dir
		set_target_grid_cell(_target_cell_grid)
		set_target_direction(_new_dir)
		_previous_distance = _levelMap.get_global_distance_between_gridcell_and_obj(_target_cell_grid, _owner)
		set_move_direction(_new_dir)
	else :
		_previous_distance = _distance

### EVENTS ###
func _on_Movetarget_cell_grid_CHANGED(my_cell) :
	if $Polygon2D && $Polygon2D.visible :
		var _pos = _levelMap.get_global_position_from_grid(my_cell)
		$Polygon2D.global_position = _pos + _levelMap.half_size
