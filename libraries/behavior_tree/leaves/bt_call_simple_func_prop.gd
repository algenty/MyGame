# Calls a "simple" function on a given node.  
# Here, a "simple" function takes no parameters.
# Also any return value is ignored.
class_name BTCallSimpleNodeFunctionWithProp, "./bt_call_simple_func_prop.svg"
extends BehaviorTreeBaseNode

export var node: NodePath
export var node_function_name: String
export var blackboard_property_name : String
export var invert_property_value : bool = false

var _invalid := true
var _node: Node

func _ready():
	if node:
		_node = get_node(node)
	if !_node:
		printerr("BTSetBlackBoardFromProp: must set node")
		return
	if node_function_name == null or node_function_name == "":
		printerr("must set node function name")
		return

	_invalid = false

func tick(delta:float, blackboard: BlackBoard, result:BehaviorTreeResult) -> void:
	if _invalid:
		result.set_failure()
		return
	var property = blackboard.data.get(blackboard_property_name)
	if !property:
		result.set_failure()
		return
	if invert_property_value :
		property =  ! property
	_node.call(node_function_name, property)
	
	result.set_success()
