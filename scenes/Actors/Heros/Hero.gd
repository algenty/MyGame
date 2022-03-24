extends Actor
class_name Hero

var _last_input_direction : Vector2 = Vector2.ZERO

### INIT/UPDATE/FREE ###
func init_hero() -> void :
#	var __ = $InputMoveCapacity.connect("input_direction_changed", self, "_on_InputMoveCapacity_input_direction_changed")
#	__ = $AvailableDirectionsCapacity.connect("available_directions_changed", self, "_on_AvailableDirectionsCapacity_available_directions_changed")
	var __ = connect("direction_changed", self, "_on_Hero_direction_changed")


func free_hero() -> void :
	pass


func update_hero(_delta : float = 0.0) -> void :
	pass
#	if _current_state == STATES.MOVE :
#		var __ = move()


### BUILT_IT ###
func _ready():
	init_hero()


func _exit_tree():
	free_hero()

func _physics_process(delta) :
	update_hero(delta)


### EVENTS ###
#func _on_InputMoveCapacity_input_direction_changed(new_direction) -> void :
#	_last_input_direction = new_direction
#	state_handler.set_state("Move")
#	if $AvailableDirectionsCapacity.is_available_direction(_last_input_direction) :
#		set_direction(_last_input_direction)

#func _on_AvailableDirectionsCapacity_available_directions_changed(available_dirs : Array) -> void :
#	if _last_input_direction in available_dirs :
#		set_direction(_last_input_direction)

func _on_Hero_direction_changed(_direction) -> void :
	pass

### LOGIC ###
func collect(my_collectable : Collectable) -> bool :
	print( name + " is Collecting " + my_collectable.name)
	return true

func idle(_delta :float = 0.0) -> bool :
#	set_direction(get_direction() * -1)
	return true
