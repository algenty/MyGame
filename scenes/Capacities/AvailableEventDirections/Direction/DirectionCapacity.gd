extends Capacity
class_name DirectionCapacty

var _available : bool = false setget set_available, is_available
var _direction : Vector2 setget set_direction, get_direction
var _previous_direction : Vector2
var _rounded_direction : Vector2
var _default_direction : Vector2

### CONSTANTS ###
#const INITIAL_DIRECTION := Vector2.LEFT


### Exports ###
export(int) var weight : int = 10 setget set_weight, get_weight
export(bool) var available_when_all_Raycast : bool = true

### SIGNAL ###
signal capacity_changed(direction, available)
signal capacity_available(direction)
signal capacity_unavailable(direction)
signal direction_changed(old_direction, new_direction)
signal weight_changed(direction, weight)

### INIT  & EXIT ###
func init() -> void :
	$Label.text = name
	compute_default_direction()
	var __ = connect("capacity_changed", self, "_on_DirectionCapacty_capacity_changed")
	.init()


func free() -> void :
	pass


func update(_delta : float = 0.0) -> void :
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
	if not process_mode : update()
	return _available


func set_direction(value : Vector2) -> void :
	if value != _direction :
		_previous_direction = _direction
		_direction = value
		emit_signal("direction_changed", _previous_direction, _direction)


func get_direction() -> Vector2 :
	if not process_mode : update()
	return _direction


func set_enable(value) -> void :
		$Label.visible = value && debug && display
		$Sprite.visible = value && display
		for __child in get_children() :
			if __child is RayCast2D :
				__child.enabled = value
		.set_enable(value)

### BUILT-IN ###


### LOGIC ###
# Calculate direction according poistion "Direction"
# with the global_rotation
func compute_default_direction() -> void :
	if ! $Direction :
		DEBUG.critical("Enable to define direction of " + name)
		return
	var _rot_pos = $Direction.position.rotated(global_rotation)
	_default_direction = Vector2(0.0, 0.0).direction_to(_rot_pos)
	_rounded_direction = Vector2(_default_direction.round())
	if debug :
		$Label.set_text(name + "\n" + Utils.get_direction_name(_rounded_direction))
	set_direction(_rounded_direction)


### EVENTS ###
func _on_DirectionCapacty_capacity_changed(
	direction : Vector2 = _direction, 
	available : bool = _available
	) -> void :
	var __ = direction
	if display :
		$Sprite.visible = available
