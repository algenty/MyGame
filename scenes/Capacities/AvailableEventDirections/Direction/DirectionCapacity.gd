extends Capacity
class_name DirectionCapacty

var _available : bool = false setget set_available, is_available
var _direction : Vector2 setget set_direction, get_direction
#var _previous_direction : Vector2
#var _rounded_direction : Vector2
#var _default_direction : Vector2
var _size : int setget set_size, get_size
var _default_direction : Vector2 = Vector2.LEFT
#var _initial_direction : Vector2 = _default_direction

### CONSTANTS ###
#const INITIAL_DIRECTION := Vector2.LEFT


### Exports ###
export(int) var weight : int = 10 setget set_weight, get_weight
export(bool) var available_when_all_Raycast : bool = true

### SIGNAL ###
signal capacity_changed(direction, available)
signal capacity_available(direction)
signal capacity_unavailable(direction)
signal direction_changed(new_direction)
signal weight_changed(direction, weight)

### INIT  & EXIT ###
func init_capacity() -> void :
	.init_capacity()
#	$Label.text = name
#	set_direction(compute_initial_direction())
	_direction = compute_initial_direction()
	var __ : int 
	__ = connect("capacity_changed", self, "_on_Direction_capacity_changed")
	__ = connect("direction_changed", self, "_on_Direction_direction_changed")
	

func on_capacity_enable_changed(enabled : bool = is_enable()) -> void :
	$Sprite.visible = is_enable() && is_display()
	$Label.visible = is_enable() && is_debug() && is_display()
	for __child in get_children() :
		if __child is RayCast2D :
			__child.enabled = is_enable()
	.on_capacity_enable_changed(enabled)

func on_capacity_rotated(new_direction : Vector2) -> void :
	set_direction(compute_global_direction())
	.on_capacity_rotation_changed(new_direction)


func free_capacity() -> void :
	pass


func update_capacity(_delta : float = 0.0) -> void :
	var __available = true
	for _child in get_children() :
		if _child is RayCast2D :
			var __ray2D = ! _child.is_colliding()
			if available_when_all_Raycast :
				__available =  __ray2D
				if ! __available : break
			else :
				__available =  __ray2D
				if __available : break
	set_available(__available)


### ACCESSORS ###
func set_weight(value : int) -> void :
	if value != weight :
		weight = value
		emit_signal("weight_changed", get_direction(), value)


func get_weight() -> int :
	return weight


func set_available(value : bool) -> void :
	if value != _available :
		_available = value
		if _available : 
			emit_signal("capacity_available", _direction)
		else :
			emit_signal("capacity_unavailable", _direction)
		emit_signal("capacity_changed", _direction, _available)


func is_available() -> bool :
	if not is_enable() : return false
	if not process_mode : update_capacity()
	return _available


func set_direction(value : Vector2) -> void :
	if value != _direction :
#		_previous_direction = _direction
		_direction = value
		emit_signal("direction_changed", _direction)


func get_direction() -> Vector2 :
	if not process_mode : update_capacity()
	return _direction


func set_size(value : int) -> void :
	for __child in get_children() :
		if __child is RayCast2D :
			__child.cast_to.x = value * -1
	_size = value


func get_size() -> int :
	return _size

### LOGIC ###
func compute_initial_direction() -> Vector2 :
	var __direction = _default_direction.rotated(global_rotation)
	return __direction.round()


func compute_global_direction() -> Vector2 :
	var __direction = _default_direction.rotated(global_rotation)
	return __direction.round()


### EVENTS ###
func _on_Direction_capacity_changed(direction : Vector2, available : bool) -> void :
	if is_display() :
		$Sprite.visible = available


func _on_Direction_direction_changed(new_direction :Vector2) -> void : 
	if is_display() && is_debug() :
		$Label.set_text(name + "\n" + Utils.get_direction_name(get_direction()))

