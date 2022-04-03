extends Capacity
class_name AvailableEventDirectionsCapacity, "./AvailableEventDirectionsCapacity.svg"

signal available_directions_changed(directions_array)

### VARIABLES
var _available_directions : Array = []
var _available_names : Array = []
var _available_childs : Array = []
var _available_weights : Array = []
var _random = RandomNumberGenerator.new()
var _random_weighted = RandomWeighted.new()
#var initial_direction : Vector2 = Vector2.DOWN

### EXPORTS
export(int) var init_raycast_size : int = 10

### INIT  & EXIT ###
func init_capacity() -> void :
	### CHECKS
	.init_capacity()
	var __ = connect("available_directions_changed", self, "_on_self_available_directions_changed")
	for __child in get_children() :
		if ! __child is DirectionCapacty :
			DEBUG.critical("[%s] is not a DirectionCapacty in [%s]" % [__child.name, name])
		elif __child is DirectionCapacty :
			__child.set_size(init_raycast_size)


func free_capacity() -> void :
	_available_directions.clear()
	.free_capacity()


func update_capacity(_delta : float = 0.0) -> void :
	var __hash = _available_names.hash()
	var __changed = false
	_clear_direction()
	for __child in get_children() :
		if __child is DirectionCapacty :
			var __available = __child.is_available()
			if __available :
				__changed = _add_direction(__child) || __changed
			else :
				__changed = _remove_direction(__child) || __changed
		else :
			DEBUG.critical("Only DirectionCapacty childs are valid")
#	if __changed :
	if _available_names.hash() != __hash :
		emit_signal("available_directions_changed", _available_directions)
	.update_capacity()

### LOGIC ###
func is_available_direction(direction : Vector2) -> bool :
	if not process_mode : update_capacity()
	return direction in _available_directions


func get_available_directions() -> Array :
	return _available_directions


func _clear_direction() -> void :
	_available_directions = []
	_available_names = []
	_available_weights = []
	_available_childs = []
	

func _add_direction(child : DirectionCapacty) -> bool :
	var __direction = child.get_direction()
	var __name = child.get_name()
	var __weight = child.get_weight()
	var _index = _available_directions.find(__direction)
	if _index == -1 : 
		_available_directions.append(__direction)
		_available_names.append(__name)
		_available_weights.append(__weight)
		_available_childs.append(child)
		return true
	return false


func _remove_direction(child : DirectionCapacty) -> bool :
	var __direction = child.get_direction()
	var __name = child.get_name()
	var _index = _available_directions.find(__direction)
	if _index != -1 : 
		_available_directions.remove(_index)
		_available_names.remove(_index)
		_available_weights.remove(_index)
		_available_childs.remove(_index)
		return true
	return false


func get_random_direction(with_weight : bool = true) -> Vector2 :
	if not process_mode : 
		update_capacity() 
	var __size = _available_directions.size()
	if __size == 1 : return _available_directions[0]
	if __size :
		if not with_weight :
			var __index = _random.randi() % (__size)
			return _available_directions[__index]
		else :
			_random_weighted.clear()
			for __i in range(_available_directions.size()) :
				_random_weighted.add(_available_directions[__i], _available_weights[__i])
			var __result = _random_weighted.rando()
			var __i = _available_directions.find(__result)
#			print("Selected ", _available_names[__i])
			return __result
	return Vector2.ZERO


### BUILT-IN ###
# IN MOTHER CLASS

### EVENTS ###
func _on_self_available_directions_changed(available_dirs : Array) -> void :
	if is_debug() : 
		ONSCREEN.put(get_owner_node(), "Available Dir.", available_dirs)


func on_capacity_enable_changed(enabled : bool = is_enable()) -> void :
	.on_capacity_enable_changed(enabled)
	if enabled :
		_random.randomize()
		update_capacity()

