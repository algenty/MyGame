extends Capacity
class_name PathFinderSetDirectionCapacity, "res://scenes/Capacities/PathFinderSetDirection/PathFinderSetDirectionCapacity.svg"


### Exports
export(String) var owner_method_direction : String = "set_direction"
export(String) var owner_target_properties : String = "target"
export(bool) var follow_target : bool = false
export(bool) var enable_diagonals = false
export(bool) var add_disable_point_with_mouse : bool = true
export(bool) var change_path_with_mouse : bool = true


### Constants

### Variables
var _direction : Vector2 = Vector2.ZERO setget set_direction, get_direction
var _target : Vector2 = Vector2.ZERO setget set_target, get_target
#var _generated_path : Array = []
# True if owner have the method else use signal "direction_changed"
var _owner_method_direction_available : bool = false
var _owner_propertie_target_available : bool = false
var _owner_current_postion : Vector2 = Vector2.ZERO
var _taken_path : Array = []

onready var _line2D = $Line2D
onready var _pathfinder : PathFinderCapacity = $PathFinderCapacity


### SIGNALS
signal direction_changed(direction)
signal target_changed(target)
signal taken_path_changed(_taken_path)
signal path_achieved(position)

### INIT  & UPDATE & EXIT ###
func init() -> void :
	.init()
	### INIT CHILD
	var __agent = get_owner_node()
	$PathFinderCapacity.enable_diagonals = enable_diagonals
	$Line2D.set_as_toplevel(true)
	$PathFinderCapacity.set_owner(__agent)

	### CHECKS
	if owner_method_direction != null && ! owner_method_direction.empty() :
		if __agent.has_method(owner_method_direction) :
			_owner_method_direction_available = true
		else :
			DEBUG.critical("Owner has no method [%s]" % owner_method_direction )

	if owner_target_properties !=null &&  ! owner_target_properties.empty() :
		if owner_target_properties in __agent :
			_owner_propertie_target_available = true
		else :
			DEBUG.critical("Owner has no property [%s]" % owner_target_properties )

	### SIGNALS
	var __ : int
#	__ = $PathFinderCapacity.connect("path_generated", self, "_on_pathfinder_path_generated")
	__ = self.connect("direction_changed", self, "_on_self_direction_changed")
	__ = self.connect("target_changed", self, "_on_self_target_changed")
	__ = self.connect("taken_path_changed", self, "_on_self_taken_path_changed")

func free() -> void :
	.free()


func update(_delta : float = 0.0) -> void :
	if _pathfinder.has_path() :
		_owner_current_postion = get_owner_node().global_position
		var __targeted : bool = _pathfinder.is_on_target(_owner_current_postion)
		if not __targeted :
			var __direction : Vector2 = _pathfinder.get_direction(_owner_current_postion)
			set_direction(__direction)
		else :
			emit_signal("path_achieved", _owner_current_postion)
	else : 
		pass


func input(event):
	if event is InputEventMouseButton and is_enable() :
		if change_path_with_mouse && event.button_index == BUTTON_LEFT and event.pressed :
			var __target = get_global_mouse_position()
			if _pathfinder.is_valid_target(__target) :
				set_target(__target)


func on_capacity_enable_changed(value : bool = is_enable()) -> void :
	.on_capacity_enable_changed(value)
	$Line2D.visible = is_enable() && is_display()


### ACCESSORS ###
func set_direction(value : Vector2) -> void :
	if value != _direction :
		_direction = value
		var __agent = get_owner_node()
		if _owner_method_direction_available :
			__agent.call(owner_method_direction, value)
		emit_signal("direction_changed", value)


func get_direction() -> Vector2 :
	return _direction


func set_target(value : Vector2, force : bool = false) -> void :
	if value != _target || force:
		_target = value
		_pathfinder.set_origin(get_owner_node().global_position)
		_pathfinder.set_target(_target)
#		_pathfinder.get_finded_path()
		set_physics_process(true)
		clear_taken_points()
		emit_signal("target_changed", value)


func get_target() -> Vector2 :
	return _target


func add_taken_point(world_point : Vector2) -> void :
	if not _taken_path.has(world_point) :
		_taken_path.append(world_point)
		emit_signal("taken_path_changed", _taken_path)


func clear_taken_points() -> void :
	_taken_path = []
	emit_signal("taken_path_changed", _taken_path)


### BUIT-IT ###
#IN MOTHER CLASS CAPACITY

### BUILT-IN ###


### EVENTS ###
func _on_self_direction_changed(__direction) -> void :
	if is_display()  :
		add_taken_point(_owner_current_postion)
	pass


func _on_self_target_changed(target) -> void :
	pass


func _on_self_taken_path_changed(path) -> void :
	if is_display() :
		_line2D.points = path
