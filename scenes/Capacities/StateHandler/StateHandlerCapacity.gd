extends Capacity
class_name StateHandlerCapacity, "./StateHandlerCapacity.svg"

### Constantes


### Variables
#var state : State setget set_state, get_state
#var _prev_state : State
var _state : State
var _state_name : String
var _stack_states : Array = []

### Exports
export(String) var default_state_name = "Idle"
export(bool) var previous_state_on_exit = true

### Signals
signal state_changed(new_state)
#signal state_finished(state, result)

### ACCESSORS ###
func set_state(value) -> void :
	if value is String :
		value = get_node_or_null(value)
	var __new_state : State = value
	var __cur_state : State = get_state()
	if __new_state == __cur_state : return
	if __new_state == null :
		DEBUG.warning("Unknow State [%s]" % value)
		return
	var __prev_state = __cur_state
	_exit_state(__prev_state)
	_enter_state(__new_state)
	emit_signal("state_changed", __new_state )

func finish_state(value : State = get_state()) -> void :
	if get_state() != value :
		DEBUG.warning("[%s] in not the current state to finish it" % value.name)
		return
	_exit_state(value)
#	emit_signal("state_finished", value, value.get_result())
	if _stack_states.size() > 0 :
		var __cur_state = _stack_states.pop_back()
		_enter_state(__cur_state)
		emit_signal("state_changed", __cur_state)
	else :
		set_state(default_state_name)


func get_state() -> State :
	if _stack_states.size() > 0 :
		return _stack_states.back()
	else : return null


func get_state_name() -> String :
	var __state = _stack_states.back()
	return __state.get_name() if _state != null else ""


func _exit_state(value : State = get_state()) -> void :
	if value == null : return
	if value.is_finished() :
		if _stack_states.size() > 0 :
			var _state_in_back : State = _stack_states.pop_back()
			if _state_in_back.get_name() != value.get_name() : 
				DEBUG.warning("State in stack must be the same : [%s] [%s]" % [_state_in_back.get_name(), value.get_name()])
	value.exit()


func _enter_state(value : State = get_state()) -> void :
	var __state_in_back : State = _stack_states.back() if _stack_states.size() else null
	if __state_in_back !=null and __state_in_back.get_name() == value.get_name() :
			DEBUG.warning("State [%s] is already on front stack")
	else : 
		_stack_states.append(value)
	_state = value
	_state_name = _state.name
	value.enter()


### INIT  & UPDATE & EXIT ###
func init() -> void :
	if is_enable() :
		var __agent = owner_node
		if !__agent : DEBUG.critical("Owner node not valid")
		var __ = self.connect("state_changed", self, "_on_self_state_changed")
		var __first : State
		for __child in get_children() :
			if __child is State :
				if __first == null :
					if default_state_name == null :
						__first = __child
						default_state_name = __first.get_name()
					elif default_state_name == __child.get_name() :
						__first = __child 
				__ = __child.connect("state_finished", self, "_on_State_state_finished")
				__child.set_owner(__agent)
			else :
				DEBUG.critical("Only Children State are available")
		if __first == null : 
			DEBUG.critical("No state defined or default state name not exits")
		set_state(__first)
	.init()

func free() -> void :
	pass

func update(delta : float = get_physics_process_delta_time()) -> void :
	var __state = get_state()
	if __state != null : _state.update(delta)


### BUILT-IN ###

### EVENTS ###
func _on_State_state_finished(old_state : State) -> void :
	if old_state != null :
		finish_state(old_state)
		if is_debug() :
			ONSCREEN.put(get_owner_node(),"state status", old_state.get_result())
			DEBUG.debug("State [%s] is finish with code [%s]" % [old_state.name, old_state.get_result()] )

func _on_self_state_changed(new_state : State) -> void :
	if new_state != null && is_debug() :
		ONSCREEN.put(get_owner_node(),"State", new_state.get_name())
		DEBUG.debug("Curent state is [%s]" % new_state.get_name() )
