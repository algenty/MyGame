extends Capacity
class_name RandomSetDirectionCapacity, "./RandomSetDirectionCapacity.svg"


### Exports
export(String) var owner_method_direction : String = "set_direction"
export(float) var owner_min_distance_before_change : float = 10.0
export(bool) var ramdon_with_weight : bool= true

### Constants

### Variables
#onready var _available_event  : AvailableEventDirectionsCapacity = $AvailableEvent

### Properties
var _direction : Vector2 = Vector2.ZERO setget set_direction, get_direction
var _available_directions : Array = []
# True if owner have the method else use signal "direction_changed"
var _owner_method_direction_available : bool = false
#var _last_random_direction : Vector2 = Vector2.ZERO
var _random = RandomNumberGenerator.new()
var _old_position : Vector2 = Vector2.ZERO

### SIGNALS
signal direction_changed(direction)

### INIT  & UPDATE & EXIT ###
func init() -> void :
	### INIT CHILD
	$AvailableEvent.set_enable(is_enable())

	var __agent = get_owner()
	$AvailableEvent.set_owner(__agent)

	### CHECKS
	if owner_method_direction != null && ! owner_method_direction.empty() :
		if __agent.has_method(owner_method_direction) :
			_owner_method_direction_available = true
		else :
			DEBUG.critical("Owner has no method " + owner_method_direction )
	_old_position = __agent.position

	### SIGNALS
	var __ = $AvailableEvent.connect("available_directions_changed", self, "_on_available_event_available_directions_changed")
	__ = self.connect("direction_changed", self, "_on_self_direction_changed")
	_random.randomize()
	.init()

func free() -> void :
	.free()


func update(_delta : float = get_physics_process_delta_time()) -> void :
	.update()


### ACCESSORS ###
func set_direction(value : Vector2) -> void :
	if value != _direction :
		_direction = value
		var __agent = get_owner()
		if _owner_method_direction_available :
			__agent.call(owner_method_direction, value)
		emit_signal("direction_changed", value)


func get_direction() -> Vector2 :
	return _direction


#func random_direction(array_directions : Array = _available_directions) -> void :
#	var __size = array_directions.size()
#	if array_directions.size() :
#		var __index = _random.randi() % (__size)
#		set_direction(array_directions[__index])

### BUIT-IT ###
#IN MOTHER CLASS CAPACITY

### EVENTS ###
func _on_available_event_available_directions_changed(new_directions_array : Array) -> void :
	_available_directions = new_directions_array
	var __new_position : Vector2 = get_owner().global_position
	var __distance = __new_position.distance_to(_old_position)
	if get_direction() == Vector2.ZERO || __distance  >= owner_min_distance_before_change || _old_position == __new_position :
		var new_direction : Vector2 = $AvailableEvent.get_random_direction(ramdon_with_weight)
		if get_direction() !=  new_direction :
			set_direction(new_direction)
			_old_position = __new_position


func _on_self_direction_changed(__direction) -> void :
	pass
### LOCIC ###

