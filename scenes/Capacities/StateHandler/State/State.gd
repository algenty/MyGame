extends Node
class_name State

### Constants
export(NodePath) var owner_node setget set_owner, get_owner
export(String) onready var owner_function : String = self.name.to_lower()
export(bool) var ignore_return_code = false
export(bool) var debug : bool = false

### Variable
var _is_running : bool = false setget ,is_running
var _is_finished : bool = true setget ,is_finished
var _result : int = RESULT.SUCCESS setget _set_result, get_result
enum RESULT  {
	FAILED = 0,
	SUCCESS = 1,
	RUNNING = 0
}

### Signals
signal state_finished(state, result)

### BUILT-IN ###
func _ready():
	init()

func _exit_tree():
	free()

### INIT/UPDATE/FREE ###
func init() -> void :
	if owner_node == null : DEBUG.critical("Owner node cannot be null")
	if owner_function == null or owner_function.empty() : DEBUG.critical("Owner function cannot be empty")
	var _agent := get_node(owner_node)
	if !_agent : DEBUG.critical("Owner node not valid")
	if !_agent.has_method(owner_function) : DEBUG.critical("Owner function not valid")

### INTERFACES ###
func enter() -> void :
	_is_running = true
	_is_finished = false
	_result = RESULT.RUNNING

func exit() -> void :
	_is_running = false
	
func finish() -> void :
	_is_running = false
	_is_finished = true
	emit_signal("state_finished", self)
	
func update(delta:float) -> void :
	var result_call = owner_node.call(owner_function, delta)
	if  ! ignore_return_code :
		if result_call : 
			_result = RESULT.SUCCESS
		else :
			_result = RESULT.FAILED
			finish()

### ACCESSORS ###
func is_running() -> bool :
	return _is_running


func is_finished() -> bool :
	return _is_finished


func _set_result(result : int) -> void :
	_result = result


func get_result() -> int :
	return _result


func set_owner(new_owner) -> void :
	owner_node = new_owner


func get_owner() -> Node :
	return owner_node 


