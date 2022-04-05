# base class for all behavior tree nodes
class_name BehaviorTreeNode
extends Node

export var debug := false
export var _print := false

func has_bad_children():
	return true


func tick(delta:float, blackboard: BlackBoard, result:BehaviorTreeResult) -> void:
	result.success()


func break_on_debug() -> void:
	if debug:
		# to get to the code you want to debug, hit F10 till you see
		# a behavior tree node's tick function call.  Then F11 into it.
		breakpoint

func print_behavior() -> void :
	if _print :
		print("BT : " + DEBUG.get_current_tree(self))
