extends Item
class_name Collectable

### VARIABLES ###
var target_in_collect_erea := false
var target : Node2D = null

onready var state_machine : StateMachine = $StateMachine
onready var sprite = $Sprite
onready var area = $Area2D



### SIGNALS ###
signal TARGET_CHANGED

### BUILD-IT ###
func _ready():
	init_connect()
	pass



### LOGIC ###

func init_connect()  -> void :
	var error = area.connect("body_entered", self, "_on_Collectable_body_entered")
	if error != 0 : printerr("Error on signal connect [%s] with error [%s] in node [%s] " % ["body_entered", error, name] )
	error = state_machine.connect("STATE_CHANGED", self, "_on_state_machine_STATE_CHANGED")
	if error != 0 : printerr("Error on signal connect [%s] with error [%s] in node [%s] " % ["STATE_CHANGED", error, name] )
	error = state_machine.connect("STATE_FINISHED", self, "_on_state_machine_STATE_FINISHED")
	if error != 0 : printerr("Error on signal connect [%s] with error [%s] in node [%s] " % ["STATE_FINISHED", error, name] )

### EVENTS ###
func _on_Collectable_body_entered(my_body : Node2D) :
	if my_body is Actor :
		target = my_body
		target_in_collect_erea = true
		state_machine.set_state("Collect")
		emit_signal("TARGET_CHANGED", self)

func _on_state_machine_STATE_CHANGED(_my_state : State_old) :
	pass

func _on_state_machine_STATE_FINISHED(my_state : State_old)  :
	if my_state == null :return
	var _state_name : String = my_state.get_state_name()
	match(_state_name) :
		"Collect" :
			state_machine.set_state("Collected")
		"Collected" :
			queue_free()
