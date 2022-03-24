extends Actor
class_name Character

### VARIABLES ###

func _ready():
	add_to_group("Characters")

func _exit_tree():
	remove_from_group("Characters")
### LOGIC ###

# Return true : if collected, otherwise false
func collect(_my_collectable : Collectable) -> bool :
	return false

func can_move_toward(_my_direction : Vector2) -> bool :
	return true
