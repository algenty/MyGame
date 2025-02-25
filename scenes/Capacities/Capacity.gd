extends Node2D
class_name Capacity

### CONSTANT
const SIGNAL_DIRECTION_CHANGED = "direction_changed"
const VARIABLE_INITIAL_DIRECTION = "init_direction"


### Exports
# Owner
export(NodePath) onready var owner_node = owner setget set_owner_node,get_owner_node
# Enable / Disable capacity
export(bool) var _enable : bool = true setget set_enable, is_enable
# Auto refresh state in physique process
export(int, "Idle", "Process") var process_mode : bool = 1
# debug mode
export(bool) var _debug : bool = false setget set_debug, is_debug
# Display icons
export(bool) var _display : bool = true  setget set_display, is_display
# Rotate with Owner
export(bool) var rotate_with_direction_owner : bool = false

### Variable
#var _init_direction : Vector2

### Signals
signal capacity_rotated(new_direction)
signal capacity_enabled(new_value)


### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	yield(owner, "ready")
	set_display(_display)
	set_debug(_debug)
	on_capacity_enable_changed()
	var error : int
	error = connect("capacity_enabled", self, "on_capacity_enable_changed")
	error = connect("capacity_rotated", self, "on_capacity_rotation_changed")
	var __agent : = get_owner_node()
	if __agent == null :
		DEBUG.critical("Owner node must be assigned to the capacity")
		return
	if rotate_with_direction_owner :
		if not __agent.has_signal(SIGNAL_DIRECTION_CHANGED) :
			DEBUG.critical("Owner node [%s] have no signal [%s]" % [__agent, SIGNAL_DIRECTION_CHANGED])
		if not VARIABLE_INITIAL_DIRECTION in __agent :
			DEBUG.critical("Owner node [%s] have no variable [%s]" % [__agent, VARIABLE_INITIAL_DIRECTION])
#		_init_direction = __agent.get(VARIABLE_INITIAL_DIRECTION)
		error = __agent.connect(SIGNAL_DIRECTION_CHANGED, self, "rotate_capacity")
		if error : 
			DEBUG.critical("Unable to connect Signal [%s] with owner node [%s]" % [SIGNAL_DIRECTION_CHANGED, __agent])
		pass

func draw_capacity() -> void :
	pass

func free_capacity() -> void :
	pass
	
func update_capacity(_delta : float = 0.0) -> void :
	update()
	pass

func input_capacity(_event : InputEvent) -> void :
	pass

### ACCESSORS ###
func set_owner_node(new_owner : Node) -> void :
	owner_node = new_owner

func get_owner_node() -> Node :
	return owner_node


func set_enable(value : bool) -> void :
	if _enable != value :
		_enable = value
		emit_signal("capacity_enabled", value)
#		on_capacity_enable_changed(value)

func is_enable() -> bool :
	return _enable


func enable() -> void :
	set_enable(true)


func disable() -> void :
	set_enable(false)


func set_display(value : bool) -> void :
	_display = value
	for __child in get_children() :
		if __child.has_method("set_display") :
			__child.set_display(value)


func is_display() -> bool :
	return _display


func set_debug(value : bool) -> void :
	_debug = value
	for __child in get_children() :
		if __child.has_method("set_display") :
			__child.set_debug(value)


func is_debug()  -> bool :
	return _debug


### BUIT-IT ###
func _ready():
	init_capacity()


func _exit_tree():
	free_capacity()


func _physics_process(delta):
	update_capacity(delta)


func _input(event):
	input_capacity(event)


func _draw():
	draw_capacity()


### LOGIC ###
func rotate_capacity(rotation_direction : Vector2, rounded : bool = true) -> void :
	if rounded :
		rotation_direction = rotation_direction.round()
	set_rotation(rotation_direction.angle() - Vector2.DOWN.angle())
	emit_signal("capacity_rotated", rotation_direction)
#	on_capacity_rotation_changed(rotation_direction)


### EVENTS ###
func on_capacity_enable_changed(enabled : bool = is_enable()) -> void :
	set_physics_process(enabled && process_mode)
	set_process(enabled && process_mode)
	set_process_input(enabled)

func on_capacity_rotation_changed(new_direction : Vector2) -> void :
	for __child in get_children():
		if __child.has_method("on_capacity_rotation_changed") :
			__child.on_capacity_rotated(new_direction)
