extends Node2D
class_name Capacity

# Owner
export(NodePath) onready var owner_node = owner setget set_owner,get_owner

# Enable / Disable capacity
export var _enable : bool = true setget set_enable, is_enable
# Auto refresh state in physique process
export(int, "Idle", "Process") var process_mode : bool = 1
# debug mode
export(bool) var debug : bool = false
# Display icons
export(bool) var display : bool = true
# Rotate with Owner
export(bool) var rotate_with_owner : bool = false 

### INIT  & UPDATE & EXIT ###
func init() -> void :
	set_enable(_enable)


func free() -> void :
	pass
	
func update(_delta : float = 0.0) -> void :
	pass

func input(_event : InputEvent) -> void :
	pass

### ACCESSORS ###
func set_owner(new_owner : Node) -> void :
	owner_node = new_owner

func get_owner() -> Node :
	return owner_node
	
func set_enable(value : bool) -> void :
	_enable = value
	set_physics_process(value && process_mode)
	set_process(value && process_mode)
	set_process_input(value)

func is_enable() -> bool :
	return _enable
	

### BUIT-IT ###
func _ready():
#	if name == "StateHandlerCapacity" : breakpoint
	init()

func _exit_tree():
	free()
	
func _physics_process(delta):
	update(delta)

func _input(event):
	input(event)

### LOCIC ###
