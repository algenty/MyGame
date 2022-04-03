extends Capacity
class_name InputSetDirectionCapacity, "./InputSetDirectionCapacity.svg"


### Exports
export(String) var owner_method_direction : String = "set_direction"


### Constants

### Variables
var _input_event : InputEventDirectionCapacity
var _available_event  : AvailableEventDirectionsCapacity

### Properties
var _direction : Vector2 = Vector2.ZERO setget set_direction, get_direction
var _available_directions : Array = []
# True if owner have the method else use signal "direction_changed"
var _owner_method_direction_available : bool = false
var _last_input_direction : Vector2 = Vector2.ZERO

### SIGNALS
signal direction_changed(direction)

### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	.init_capacity()
	### INIT CHILD
	_input_event = $InputEvent
	_available_event = $AvailableEvent

	var __agent = get_owner_node()
	_input_event.set_owner_node(__agent)
	_available_event.set_owner_node(__agent)

	if owner_method_direction != null && ! owner_method_direction.empty() :
		if __agent.has_method(owner_method_direction) :
			_owner_method_direction_available = true
		else :
			DEBUG.critical("Owner has no method " + owner_method_direction )
	### CHECKS

	### SIGNALS
	var __ = _input_event.connect("input_direction_changed", self, "_on_input_event_input_direction_changed")
	__ = _available_event.connect("available_directions_changed", self, "_on_available_event_available_directions_changed")


func free_capacity() -> void :
	.free_capacity()


func update_capacity(_delta : float = 0.0) -> void :
	pass


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

func on_capacity_enable_changed(value : bool = is_enable()) -> void :
	.on_capacity_enable_changed(value)
	$InputEvent.set_enable(is_enable())
	$AvailableEvent.set_enable(is_enable())


### BUIT-IT ###
#IN MOTHER CLASS CAPACITY

### EVENTS ###
func _on_input_event_input_direction_changed(new_direction) -> void :
	_last_input_direction = new_direction
	if $AvailableEvent.is_available_direction(_last_input_direction) :
		set_direction(_last_input_direction)
	pass


func _on_available_event_available_directions_changed(new_directions_array : Array) -> void :
	_available_directions = new_directions_array
	if _last_input_direction in _available_directions :
		set_direction(_last_input_direction)

### LOCIC ###

