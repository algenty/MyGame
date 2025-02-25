# Calls a "simple" function on a given node.  
# Here, a "simple" function takes no parameters.
# Also any return value is ignored.
class_name BTCallSimpleNodeFunction, "res://libraries/behavior_tree/leaves/bt_call_simple_func.svg"
extends BehaviorTreeBaseNode

export var node: NodePath
export var node_function_name: String

var _invalid := true
var _node: Node

func _ready():
	if node:
		_node = get_node(node)
	if !_node:
		DEBUG.error("BTSetBlackBoardFromProp: must set node")
		return
	if node_function_name == null or node_function_name == "":
		DEBUG.error("must set node function name")
		return

	_invalid = false

func tick(delta:float, blackboard: BlackBoard, result:BehaviorTreeResult) -> void:
	if _invalid:
		result.set_failure()
		return
	
	_node.call(node_function_name)
	
	result.set_success()
