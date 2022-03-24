extends Character
class_name Enemy

var target : KinematicBody2D

#onready var state_machine = $StateMachine
#onready var player : Character

func _ready():
	yield(get_tree(), "idle_frame")
	add_to_group("Enemies")
	var _targets : Array = get_tree().get_nodes_in_group("Heroes")
	state_machine.set_state("Move")
#	if _targets.size() != 0 :
#		target = _targets[0]
#	else : 
#		target = null

func _physics_process(_delta):
	if state_move_properties.path.size() !=0 && state_machine.get_current_state_name() == "Idle" :
		state_machine.set_state("move")

func _exit_tree():
	remove_from_group("Enemies")
 
		
