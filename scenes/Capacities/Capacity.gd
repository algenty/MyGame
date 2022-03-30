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
var _init_direction : Vector2


### INIT  & UPDATE & EXIT ###
func init() -> void :
	yield(owner, "ready")
	set_display(_display)
	set_debug(_debug)
	on_capacity_enable_changed()
	var __agent : = get_owner_node()
	if __agent == null :
		DEBUG.critical("Owner node must be assigned to the capacity")
		return
	if rotate_with_direction_owner :
		if not __agent.has_signal(SIGNAL_DIRECTION_CHANGED) :
			DEBUG.critical("Owner node [%s] have no signal [%s]" % [__agent, SIGNAL_DIRECTION_CHANGED])
		if not VARIABLE_INITIAL_DIRECTION in __agent :
			DEBUG.critical("Owner node [%s] have no variable [%s]" % [__agent, VARIABLE_INITIAL_DIRECTION])
		_init_direction = __agent.get(VARIABLE_INITIAL_DIRECTION)
		var error = __agent.connect(SIGNAL_DIRECTION_CHANGED, self, "rotate_capacity")
		if error : 
			DEBUG.critical("Unable to connect Signal [%s] with owner node [%s]" % [SIGNAL_DIRECTION_CHANGED, __agent])

func free() -> void :
	pass
	
func update(_delta : float = 0.0) -> void :
	pass

func input(_event : InputEvent) -> void :
	pass

### ACCESSORS ###
func set_owner_node(new_owner : Node) -> void :
	owner_node = new_owner

func get_owner_node() -> Node :
	return owner_node


func set_enable(value : bool) -> void :
	if _enable != value :
		_enable = value
		on_capacity_enable_changed(value)

func is_enable() -> bool :
	return _enable

func on_capacity_enable_changed(value : bool = is_enable()) -> void :
	set_physics_process(is_enable() && process_mode)
	set_process(is_enable() && process_mode)
	set_process_input(is_enable())

func on_capacity_rotation_changed() -> void :
	pass

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
	init()

func _exit_tree():
	free()
	
func _physics_process(delta):
	update(delta)

func _input(event):
	input(event)

### LOGIC ###
func rotate_capacity(rotation_direction : Vector2, rounded : bool = true) -> void :
	if rounded :
		rotation_direction = rotation_direction.round()
#	print("Global_rotation : ",global_rotation)
#	print("rotation : ", rotation)
#	print("Direction  : ", rotation_direction)
#	print("Direction  Name : ", Utils.get_direction_name(rotation_direction))
#	print("Direction rotation : ",rotation_direction.angle())
	set_rotation(rotation_direction.angle() - Vector2.DOWN.angle())
	on_capacity_rotation_changed()

