# Blackboard object for a behavior tree.  Allows data to be shared amoung
# behavior tree nodes.
class_name BlackBoard, "res://libraries/behavior_tree/blackboard.svg"
extends Node

export var data := {}

var agent: Node

