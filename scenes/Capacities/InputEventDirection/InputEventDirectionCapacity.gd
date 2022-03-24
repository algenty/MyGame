extends Capacity
class_name InputEventDirectionCapacity, "./InputEventDirectionCapacity.svg"

### Exports
export(bool) var enable_diagonals : bool = false
export(String) var key_up : String = "ui_up"
export(String) var key_down : String = "ui_down"
export(String) var key_left : String = "ui_left"
export(String) var key_right : String = "ui_right"

### Constants
const _PRESSED : bool = true
const _RELEASED : bool = false
const _COLOR_PRESSED = Color(1.0, 1.0, 0.0)
const _COLOR_RELEASED = Color(1.0, 1.0, 1.0)

### Properties
var direction : Vector2 = Vector2.ZERO setget set_direction, get_direction
var _keys_state : Dictionary = {}
var keys : Array = [key_up, key_down, key_left, key_right]

### SIGNALS
signal input_direction_changed(direction)
signal input_key_state_changed(key, value)

### INIT  & UPDATE & EXIT ###
func init() -> void :
	var __ = connect("input_key_state_changed", self, "_on_self_input_key_state_changed")
	__ = connect("input_direction_changed", self, "_on_self_input_direction_changed")

	### Init states
	for key in keys :
		_keys_state[key] = _RELEASED
	### Init Sprites
	if not display  or not is_enable() :
		for _child in get_children() :
			if _child is Sprite and "Key".is_subsequence_of(_child.name) :
				_child.visible = false
	.init()

func free() -> void :
	.free()


func update(_delta : float = 0.0) -> void :
	for key in keys :
		set_key_state(key, Input.is_action_pressed(key))
	.update()


func input(event : InputEvent) -> void :
	if not is_enable() : return
	var _hash = _keys_state.hash()
	if not process_mode : update()
	var _new_direction : Vector2 = Vector2.ZERO
	if event is InputEventKey :
		update()
		set_direction(compute_direction())
	.input(event)

### ACCESSORS ###
func set_direction(value : Vector2) -> void :
	if value != direction :
		direction = value
		emit_signal("input_direction_changed", direction)

func get_direction() -> Vector2 :
	return direction


func set_key_state(key : String, value : bool) -> void :
	if _keys_state.has(key) :
		var _old = _keys_state[key]
		if _old != value :
			_keys_state[key] = value
			emit_signal("input_key_state_changed", key, value)
	else :
		DEBUG.error("keys [%s] is not defined" % key)


func get_key_state(key) -> bool :
	if _keys_state.has(key) :
		return _keys_state[key]
	else :
		DEBUG.error("keys [%s] is not defined" % key)
	return false

### BUIT-IT ###
#func _input(event):
#	input(event)

#IN MOTHER CLASS CAPACITY

### EVENTS ###
func _on_self_input_direction_changed(new_direction : Vector2) -> void :
	if debug :
		ONSCREEN.put(get_owner(),"Input direction", new_direction)

func _on_self_input_key_state_changed(key, value) -> void :
	if debug :
		ONSCREEN.put(get_owner() ,"keys", _keys_state)
	if not display : return
	else :
		var _key_name = get_key_name(key)
		var _sprite_name = "Key" + _key_name
		var _sprite = get_node_or_null(_sprite_name)
		if _sprite == null : 
			DEBUG.error("Unknow sprite [%s]" % str(_sprite_name))
			return
		if _sprite is Sprite :
			if value  : 
				_sprite.modulate = _COLOR_PRESSED
			else : 
				_sprite.modulate = _COLOR_RELEASED

### LOCIC ###
func get_key_name(key : String) -> String :
	match(key) :
		key_up : return "Up"
		key_down : return "Down"
		key_left : return "Left"
		key_right : return "Right"
	return ""

func compute_direction() -> Vector2 :
	var _new_direction : Vector2 = Vector2.ZERO
	_new_direction.x = float(int(get_key_state(key_right)) - int(get_key_state(key_left)))
	_new_direction.y = float(int(get_key_state(key_down)) - int(get_key_state(key_up)))
	if (enable_diagonals) :
		_new_direction = _new_direction.normalized()
	else :
		if _new_direction.x :
			_new_direction.y = 0
		else :
			_new_direction.x = 0
	return _new_direction
	
