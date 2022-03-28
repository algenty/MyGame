extends Capacity
class_name AutomaticPathFinderCapacity, "res://scenes/Capacities/AutomaticPathFinder/AutomaticPathFinderCapacity.svg"

### CONSTANTS
const POSITION_PROPERTY : String = "global_position"

### Variables
var target : Vector2 setget set_target, get_target
var obstables_vectors : Array = []
var _direction : Vector2 = Vector2.ZERO setget set_direction, get_direction
var _owner_method_direction_available : bool = false
var _timer  : Timer 


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
	init_when_enable()
	### CHECKS
	var __agent = get_owner()
	if owner_method_direction != null && ! owner_method_direction.empty() :
		if __agent.has_method(owner_method_direction) :
			_owner_method_direction_available = true
		else :
			DEBUG.critical("Owner has no method [%s]" % owner_method_direction )

func init_when_enable() -> void :
	if is_enable() :
		if _timer == null :
			_timer = Timer.new()
			_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS) 
			_timer.autostart = true
			_timer.set_wait_time(refresh_path_every_seconds)
			var __ =_timer.connect("timeout", self, "_on_Timer_timeout")
			add_child(_timer)
	else :
		if _timer != null :
			_timer.stop()
			_timer.disconnect("timeout", self, "_on_Timer_timeout")
			remove_child(_timer)
			_timer = null
	$PathFinderSetDirection.set_enable(is_enable())


func free() -> void :
	.free()


func update(delta : float = get_physics_process_delta_time()) -> void :
	.update(delta)


### ACCESSORS ###
func set_enable(value : bool) -> void :
	init_when_enable()
	.set_enable(value)


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
