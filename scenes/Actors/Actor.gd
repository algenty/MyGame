extends KinematicBody2D
class_name Actor

### Exports
export(bool) var debug = false
export(Vector2) var init_direction : Vector2 = Vector2.DOWN
export(float) var init_max_speed : float = 146
export(bool) var init_enable_diagonals : bool = false
export(String, "Actors", "Heros", "Enemies") var group_name = CONSTANTS.GROUP_ACTORS
export(bool) var is_bot : bool = false
export(bool) var is_local : bool = true

export (bool) var is_dying : bool = false
export (bool) var is_dead : bool = false


### Variables
var move_direction : Vector2 = init_direction setget set_direction, get_direction
var _move_previous_direction : Vector2 = Vector2.ZERO
var move_velocity : Vector2 = Vector2.ZERO setget set_velocity, get_velocity
var move_max_speep : float = init_max_speed
var move_enable_diagonals : bool = init_enable_diagonals
onready var state_handler : StateHandlerCapacity = $StateHandlerCapacity



### SIGNALS ###
signal position_changed(new_position)
signal velocity_changed(new_velocity)
signal direction_changed(new_direction)


### INIT  & EXIT ###
func init_actor() -> void :
	### GROUPS
	add_to_group(CONSTANTS.GROUP_ACTORS)
	state_handler = $StateHandlerCapacity
	
	### MOVE VALUES
	move_max_speep = init_max_speed
	move_enable_diagonals = init_enable_diagonals
	move_direction = Vector2.ZERO
	set_direction(init_direction)
	
	### SIGNALS
	var __ = connect("position_changed", self, "_on_actor_position_changed")
	__ = connect("direction_changed", self, "_on_actor_direction_changed")
	__ = connect("velocity_changed", self, "_on_actor_velocity_changed")
	__ = state_handler.connect("state_changed", self, "_on_actor_state_changed")
	
func free_actor() -> void : 
	get_tree().remove_from_group(CONSTANTS.GROUP_ACTORS)
	
func update_actor(_delta : float) -> void :
	pass

### ACCESSORS ##
func set_direction(direction : Vector2) -> void :
	if direction != move_direction :
		_move_previous_direction = move_direction
		move_direction = direction
		var new_velocity = compute_velocity(direction)
		set_velocity(new_velocity)
		if state_handler :
			state_handler.set_state("Move")
		emit_signal("direction_changed", move_direction)


func get_direction() -> Vector2 :
	return move_direction


func set_velocity(velocity : Vector2) -> void :
	if velocity != move_velocity :
		move_velocity = velocity
		emit_signal("velocity_changed", move_velocity)


func get_velocity() -> Vector2 :
	return move_velocity


func compute_velocity(direction := move_direction, speed := move_max_speep) -> Vector2 :
	return direction * speed

### EVENTS ###
func _on_actor_direction_changed(direction) -> void :
	update_animation()
	if debug :
		ONSCREEN.put(self, "Direction", direction)


func _on_actor_velocity_changed(velocity) -> void :
	if debug :
		ONSCREEN.put(self, "Velocity", velocity)


func _on_actor_state_changed(new_state) -> void :
	update_animation()
	if debug :
		ONSCREEN.put(self, "State", new_state)


func _on_actor_position_changed(new_postion) -> void :
	if debug :
		ONSCREEN.put(self, "Loc. pos.", new_postion.round())

### BUILD-IT ###
func _ready():
	init_actor()


func _exit_tree():
	free_actor()


func _physics_process(delta) :
	update_actor(delta)


### COMETICS ###
func get_animation_name(direction := move_direction) -> String :
	return state_handler.get_state_name() + Utils.get_direction_name(direction.round())


func set_animation(animation_name = get_animation_name(), _reload = false) -> void :
	if not $AnimationPlayer :
		DEBUG.warning("[%s] has no AnimationPlayer [AnimationPlayer]" % self.name)
		return
	var animation := $AnimationPlayer
	if animation.has_animation(animation_name) : 
		if animation.current_animation != animation_name :
			animation.play(animation_name)
	else :
		DEBUG.warning("[%s] has no animation name [%s]" % [self.name, animation_name])


func stop_animation() -> void :
	if not $AnimationPlayer :
		DEBUG.waring("[%s] has no AnimationPlayer [AnimationPlayer]" % self.name)
		return
	$AnimationPlayer.stop()


func update_animation() -> void :
	match(state_handler.get_state_name()) :
		"Move" :
			set_animation()
		"Idle" :
			stop_animation()


### STATES/ACTIONS ###
func move(_delta :float = get_process_delta_time(), velocity := move_velocity) -> bool :
	var _old_pos : Vector2 = position
	var _velocity = move_and_slide(velocity)
	if _velocity.length() == 0 :
		set_velocity(_velocity)
	if _old_pos != position : emit_signal("position_changed", position)
	if _velocity.length() == 0 : 
		return false
	return true

func idle(_delta :float = get_process_delta_time()) -> bool :
	return true
