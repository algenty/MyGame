extends State_old
class_name MoveState

### VARIABLES ###
var _previous_direction : Vector2 = Vector2.ZERO
var _previous_velocity : Vector2 = Vector2.ZERO
var _is_fix_y = false
var _y_value = 0.0
var _is_fix_x = false
var _x_value = 0.0

### EXPORTABLES ###
export(int) var init_acceleration : float = 146
export(float) var init_max_speed : float = 146
export(bool) var init_diagonal_enable : bool = false
export(Vector2) var init_direction : Vector2 = Vector2.ZERO

signal DIRECTION_CHANGED
signal VELOCITY_CHANGED
signal PATH_CHANGED

### ACCESSORS ###
func set_move_direction(my_dir : Vector2) -> void :
	if ! state_properties.enable_diagonal :
		my_dir = Vector2(stepify(my_dir.x, 1.0), stepify(my_dir.y, 1.0)) 
	if my_dir != get_move_direction() :
		_previous_direction = get_move_direction()
		state_properties.direction = my_dir
		var _owner = get_state_owner()
		ONSCREEN.put(_owner, "Dir Vector", state_properties.direction)
		ONSCREEN.put(_owner, "Dir Name ", Utils.get_direction_name(state_properties.direction))
		process_velocity()
		emit_signal("DIRECTION_CHANGED", get_move_direction())

func fix_move_position(my_dir : Vector2 = get_move_direction()):
	var _weight = 0.30
	var _owner = get_state_owner()
	if abs(my_dir.x) == 1 :
		if ! _is_fix_y :
			_y_value = float(round(_owner.position.y))
			_is_fix_y = true
			_is_fix_x = false
		if _owner.position.y != _y_value :
			ONSCREEN.put(_owner,"Y Goal",_y_value)
#			_owner.position.y = lerp(_owner.position.y, _y_value, 0.30)
			_owner.position.y = _y_value
		else :
			ONSCREEN.put(_owner,"Y Goal","Complete")
	elif abs(my_dir.y) == 1 :
		if ! _is_fix_x :
			_x_value = float(round(_owner.position.x))
			_is_fix_y = false
			_is_fix_x = true
		if _owner.position.x != _x_value :
			ONSCREEN.put(_owner,"X Goal",_x_value)
#			_owner.position.x = lerp(_owner.position.x, _y_value, 0.30)
			_owner.position.x = _x_value
		else :
			ONSCREEN.put(_owner,"X Goal","Complete")
		

func get_move_direction() -> Vector2 :
	return state_properties.direction

func set_move_velocity(my_vel : Vector2) -> void :
	if my_vel != get_move_velocity() :
		_previous_velocity = get_move_velocity()
		state_properties.velocity = my_vel
		var _owner = get_state_owner()
		ONSCREEN.put(_owner, "Vel", state_properties.velocity)
		emit_signal("VELOCITY_CHANGED", get_move_velocity())

func get_move_velocity() -> Vector2 :
	return state_properties.velocity
	
func set_move_path(my_path : Array) -> void :
	print("my_path ", my_path.size())
	if my_path.hash() != state_properties.path.hash() :
		state_properties.path = my_path
		var _owner = get_state_owner()
		ONSCREEN.put(_owner, "Path #", state_properties.path.size())
		emit_signal("PATH_CHANGED", state_properties.path)

func pop_move_path() -> Vector2 :
	var value = null
	if state_properties.size() > 0 :
		var _owner = get_state_owner()
		ONSCREEN.put(_owner, "Path #", state_properties.path.size())
		emit_signal("PATH_CHANGED", get_move_path())
		value = state_properties.path.remove(0)
	return value
	
func get_move_path() -> Array :
	return state_properties.path


### BUILT_IN ###
func _ready():
	init_state_properties();
	var __ = self.connect("DIRECTION_CHANGED", self, "_on_move_DIRECTION_CHANGED")
	__ = connect("PATH_CHANGED", self, "on_self_PATH_CHANGED")

### IMPLEMENATION ##
func init_state_properties() -> void :
		state_properties = {
		acceleration = init_acceleration,
		max_speed = init_max_speed,
		stop_on_vel_zero = true,
		enable_diagonal = init_diagonal_enable,
		velocity = Vector2(0.0, 0.0),
		direction = init_direction,
		path = []
	}

func enter_state() -> void:
	.enter_state()
	
func exit_state() -> void:
	set_move_velocity(Vector2.ZERO)
	.exit_state()
	
func finish_state() -> void:
	.finish_state()

func update_state(my_delta : float) -> void:
	process_move(my_delta)
	.update_state(my_delta)

### EVENTS ###
func _on_move_DIRECTION_CHANGED(var my_dir = get_move_direction()) :
	var __ = my_dir
	pass

func on_self_PATH_CHANGED(my_path):
	var _line2d = get_node_or_null("Line2D")
	if _line2d != null :
		_line2d.points = []
		_line2d.global_position = Vector2.ZERO
		_line2d.points = my_path

### LOGIC ###
func process_velocity() -> void :
	var _dir = get_move_direction()
	set_move_velocity(compute_velocity(_dir))	

func process_move(my_delta : float) -> void :
	var _owner  = get_state_owner()
	if _owner.has_method("move") :
		var stopped : bool = ! _owner.move(my_delta, get_move_velocity())
		if stopped  && state_properties.stop_on_vel_zero :
			finish_state()
	else :
		DEBUG.error("[%s] has no method [%s]" % [_owner.name, "move"])

func compute_velocity(_dir = get_move_direction(), _vel = get_move_velocity()) -> Vector2 :
	var _new_vel = Vector2(_vel)
#	if get_state_owner() is Enemy : breakpoint
	if ! state_properties.enable_diagonal :
		if _dir == Vector2.UP or _dir == Vector2.DOWN :
			_new_vel.x = .0
		elif _dir == Vector2.LEFT or _dir == Vector2.RIGHT :
			_new_vel.y = .0
	_new_vel = _dir * state_properties.acceleration
	return _new_vel
