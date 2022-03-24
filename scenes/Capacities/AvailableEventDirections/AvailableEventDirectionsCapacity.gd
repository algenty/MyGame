extends Capacity
class_name AvailableEventDirectionsCapacity, "./AvailableEventDirectionsCapacity.svg"

signal available_directions_changed(directions_array)

### VARIABLES ####
var _available_directions : Array = []
var _available_names : Array = []
var _available_childs : Array = []
var _random = RandomNumberGenerator.new()
var _random_weighted = RandomWeighted.new()
var initial_direction : Vector2 = Vector2.DOWN

### INIT  & EXIT ###
func init() -> void :
	yield(get_parent(), "ready")
	### CHECKS
	assert( connect("available_directions_changed", self, "_on_self_available_directions_changed") == 0)
	for child in get_children() :
		if ! (child is DirectionCapacty) :
			DEBUG.critical("[%s] is not a DirectionCapacty in [%s]" % [child.name, name])
	var _owner : Object = get_owner()
	if rotate_with_owner :
		# Init direction angle
		if _owner.has_method("get_direction") :
			initial_direction = _owner.get_direction()
		else :
			DEBUG.critical("Owner [%s] has not method get_direction to calculate rotation with initial direction")
		# Connect signal direction changed	
		if _owner.has_signal("direction_changed") :
			assert(_owner.connect("direction_changed", self, "_on_owner_direction_changed") == 0)
		else :
			DEBUG.error("No signal [direction_changed] for owner") 
			
	_random.randomize()
	update()
	.init()

func free() -> void :
	_available_directions.clear()
	.free()


func update(_delta : float = 0.0) -> void :
#	var _hash = _available_directions.hash()
	var __changed = false
	var __new_available_direction = []
	for __child in get_children() :
		if __child is DirectionCapacty :
			var __available = __child.is_available()
			if __available :
				__changed = _add_direction(__child) || __changed
			else :
				__changed = _remove_direction(__child) || __changed
		else :
			DEBUG.critical("Only DirectionCapacty childs are valid")
	if __changed :
		emit_signal("available_directions_changed", _available_directions)
	.update()

### LOGIC ###
func is_available_direction(direction : Vector2) -> bool :
	if not process_mode : update()
	return direction in _available_directions


func get_available_directions() -> Array :
	return _available_directions


func _add_direction(child : DirectionCapacty) -> bool :
	var direction = child.get_direction()
	var name = child.get_name()
	var _index = _available_directions.find(direction)
	if _index == -1 : 
		_available_directions.append(direction)
		_available_names.append(name)
		_available_childs.append(child)
		return true
	return false


func _remove_direction(child : DirectionCapacty) -> bool :
	var direction = child.get_direction()
	var name = child.get_name()
	var _index = _available_directions.find(direction)
	if _index != -1 : 
		_available_directions.remove(_index)
		_available_names.remove(_index)
		_available_childs.remove(_index)
		return true
	return false


func get_capacity(direction_or_name) -> DirectionCapacty :
	for __child in get_children() :
		if __child is DirectionCapacty : 
			if direction_or_name is String && __child.get_name() == direction_or_name :
				return __child
			elif direction_or_name is Vector2 && __child.get_direction() == direction_or_name :
				return __child
	return null

func set_enable_direction(direction_or_name, __enable  = true) -> void :
	var __child :  DirectionCapacty = get_capacity(direction_or_name)
	if __child != null :
		__child.set_enable(__enable)

func get_random_direction(with_weight : bool = true) -> Vector2 :
	if not process_mode : 
		update() 
	var __size = _available_directions.size()
	if __size :
		if not with_weight :
			var __index = _random.randi() % (__size)
			return _available_directions[__index]
		else :
			_random_weighted.clear()
			for __child in _available_childs :
				_random_weighted.add(__child.get_direction(), __child.get_weight())
			return _random_weighted.rando()
	return Vector2.ZERO


### BUILT-IN ###
# IN MOTHER CLASS

### EVENTS ###
func _on_self_available_directions_changed(available_dirs : Array) -> void :
	if debug : ONSCREEN.put(get_owner(), "Available Dir.", available_dirs)


func _on_owner_direction_changed(direction : Vector2) -> void :
	if rotate_with_owner :
		rotation = direction.angle() - initial_direction.angle()
		for __child in get_children() :
			if __child is DirectionCapacty :
				__child.compute_default_direction()
