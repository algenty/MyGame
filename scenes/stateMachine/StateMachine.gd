extends Node2D
class_name StateMachine

var _stateMachine_owner : Object = null setget set_state_owner, get_state_owner
var _is_enter : bool = false
var _is_finished : bool = true
onready var _name : String = self.name
var current_state_name : String = ""
var current_state : State_old = null
var previous_state : State_old = null
var state_properties : Dictionary = {}
var _default_child : State_old = null

### SIGNAL ###
signal STATE_CHANGED
signal STATE_FINISHED

### ACCESSORS ###
func set_state(my_state) -> void :
	if my_state is String :
		my_state = get_node_or_null(my_state)
	# Is the same state -> exit
	if current_state == my_state : 
		return
	elif my_state != null :
		previous_state = current_state
		if previous_state != null : 
			DEBUG.info("change state from [" + previous_state.get_state_name() + "] to [" + my_state.get_state_name() + "]")
			previous_state.exit_state()
		current_state = my_state
		current_state_name = current_state.get_state_name()
		var _owner = get_state_owner()
		current_state.enter_state()
		emit_signal("STATE_CHANGED", current_state)
	else :
		set_to_default_state()
		
func get_current_state() -> State_old :
#	if owner.name == "Collectable" : breakpoint
	return current_state
	
func get_current_state_name() -> String :
#	if owner.name == "Collectable" : breakpoint
	return current_state_name

func set_state_owner(my_owner : Object) -> void :
	_stateMachine_owner = my_owner

func get_state_owner() -> Object :
	return get_owner()

func get_state_node(my_state_name) -> State_old :
	for child in get_children() :
		if child is State_old :
			if child.get_state_name() == my_state_name :
				return child
	return null

func get_state_properties(my_state_name : String) :
	var child : State_old = get_state_node(my_state_name)
	if child != null : return child.get_state_properties()
	return null

### BUILT-IN ###
func _ready() -> void :
	_init_connect()
	set_to_default_state()
	
func _physics_process(delta):
	update_state(delta)
	_on_self_STATE_CHANGED(current_state)

### INTERFACE ###

func update_state(my_delta) -> void:
	if(current_state != null) :
		current_state.update_state(my_delta)

### EVENTS ###
func _on_child_STATE_FINISHED(my_state : State_old) -> void :
	emit_signal("STATE_FINISHED", my_state)
	pass

func _on_self_STATE_CHANGED(my_state : State_old = current_state) -> void :
	var _state_name : String
	if my_state != null : _state_name = my_state.get_state_name()
	ONSCREEN.put(get_state_owner(), "State", _state_name)

### LOGIC ###
func set_to_default_state() -> void :
#	if owner.name == "Collectable" : breakpoint
	if (get_child_count() == 0) : return
	for child in get_children() :
		if child is State_old :
			if _default_child == null :
				_default_child = child
				set_state(_default_child)

func _init_connect() -> void :
	var error = connect("STATE_CHANGED", self, "_on_self_STATE_CHANGED")
	if error != 0 : DEBUG.critical("Error on connect singal [STATE_CHANGED] with error [%s]" % error )
	for child in get_children() :
		if child is State_old :
			error = child.connect("STATE_FINISHED", self, "_on_child_STATE_FINISHED")
			if error != 0 : DEBUG.critical("Error on connect [STATE_FINISHED] for child [%s]" % child.name)
