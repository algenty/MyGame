extends Capacity
class_name AutomaticPathFinderCapacity, "res://scenes/Capacities/AutomaticPathFinder/AutomaticPathFinderCapacity.svg"

### CONSTANTS
const POSITION_PROPERTY : String = "global_position"

### Variables
var target : Vector2 setget set_target, get_target
var obstables_vectors : Array = []
var _direction : Vector2 = Vector2.ZERO setget set_direction, get_direction
var _owner_method_direction_available : bool = false


### Exports
export(String) var extented_obstacle_group : String = CONSTANTS.GROUP_ENEMIES
export(float) var refresh_path_every_seconds : float = 3.0
export(String) var owner_method_direction : String = "set_direction"

### Signals
signal target_changed(target)
signal direction_changed(direction)

### INIT  & UPDATE & EXIT ###
func init() -> void :
	### INITS
	.init()
	if is_enable() :
		$Timer.wait_time = refresh_path_every_seconds
		$Timer.start()

	### CHECKS
	var __agent = get_owner()
	if owner_method_direction != null && ! owner_method_direction.empty() :
		if __agent.has_method(owner_method_direction) :
			_owner_method_direction_available = true
		else :
			DEBUG.critical("Owner has no method [%s]" % owner_method_direction )


func free() -> void :
	.free()


func update(delta : float = get_physics_process_delta_time()) -> void :
	.update()


### ACCESSORS ###
func set_enable(value : bool) -> void :
	if value :
		$Timer.start()
	else :
		$Timer.stop()
	$PathFinderSetDirection.set_enable(value)
	.set_enable(value)
	print(name," Enable ", _enable)


func set_target(value : Vector2, force : bool = false) -> void :
	if target != value || force :
		target = value
		$PathFinderSetDirection.set_target(value, force)
		emit_signal("target_changed", value)

func set_direction(value : Vector2) -> void :
	if value != _direction :
		_direction = value
		var __agent = get_owner()
		if _owner_method_direction_available :
			__agent.call(owner_method_direction, value)
		emit_signal("direction_changed", value)

func get_direction() -> Vector2 :
	return _direction

func get_target() -> Vector2 :
	return target


### LOGIC ###
func refresh_obstables() -> void :
	obstables_vectors = []
	$PathFinderSetDirection/PathFinderCapacity.reset_disabled_points()
	var enemies = get_tree().get_nodes_in_group(extented_obstacle_group)
	for obj in enemies :
		if obj.get(POSITION_PROPERTY) != null :
			obstables_vectors.append(obj[POSITION_PROPERTY])
			$PathFinderSetDirection/PathFinderCapacity.disable_point(obj[POSITION_PROPERTY])
		else :
			DEBUG.warning("Obj [%s] in group [%s] has no property [%s]" % [obj, extented_obstacle_group, POSITION_PROPERTY])


func refresh_target() -> void :
#	var level_map : LevelMap = get_tree().get_nodes_in_group(CONSTANTS.GROUP_LEVELMAP)[0]
	var __target = $PathFinderSetDirection/PathFinderCapacity.get_random_available_points()
	set_target(__target)

### EVENTS ###
func _on_PathFinderSetDirection_path_achieved(position):
	target = Vector2.ZERO
	refresh_target()


func _on_Timer_timeout():
	refresh_obstables()
	if target == Vector2.ZERO :
		refresh_target()
	else :
		set_target(target, true)
