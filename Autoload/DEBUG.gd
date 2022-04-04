extends Node

enum LVL {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

const SCRIPT_NAME = "DEBUG.gd"
const LVL_NIV := LVL.INFO
const STACK_ENABLE := false
const WHO_ENABLE := true
const ON_SCREEN := true


func log_level(my_lvl, my_message : String ) -> void :
	if my_lvl < LVL_NIV : return
	my_message = " " + my_message
	if WHO_ENABLE :
		my_message = _get_format_stack() + my_message
	my_message = _get_format_time() + my_message
	var _screen_message = my_message
	my_message = _get_format_level(my_lvl) + my_message
	var key =""
	match(my_lvl) :
		LVL.DEBUG :
			# assert
#			print_debug(my_message)
			key = "DEBUG"
			print(my_message)
		LVL.INFO :
			key = "INFO"
			print(my_message)
		LVL.WARNING : 
			key = "WARNING"
			push_warning(my_message)
		LVL.ERROR :
			key = "ERROR"
			push_error(my_message)
		LVL.CRITICAL :
			key = "CRITICAL"
			print_stack()
			assert(false, my_message)
	if STACK_ENABLE : print_stack()
	if ON_SCREEN : ONSCREEN.put(key, "message", _screen_message)


func debug(message : String):
	if message == null :
		message = "Null"
	log_level(LVL.DEBUG, message)


func info(message : String):
	if message == null :
		message = "Null"
	log_level(LVL.INFO, message)


func warning(message : String):
	if message == null :
		message = "Null"
	log_level(LVL.WARNING, message)


func error(message : String):
	if message == null :
		message = "Null"
	log_level(LVL.ERROR, message)


func critical(message : String):
	if message == null :
		message = "Null"
	log_level(LVL.CRITICAL, message)


func inspect(obj : Object, depth : int = 0, prefix : String = "", object_inspected : Array = []) -> void :
	var obj_properties : = obj.get_property_list()
	var obj_id = obj.get_instance_id()
	object_inspected.append(obj_id)
	var str_obj = str(obj)
	for i in range(obj_properties.size()):
		var str_name = obj_properties[i].name
		var obj_type = obj_properties[i].type
		var str_type = str(obj_type)
		var obj_value = obj.get(str_name)
		var str_value = str(obj_value)
		var __result = prefix + str_obj + "." + str_name + "(" + str_type + ") = " + str_value
		print(__result)
		if ON_SCREEN : 
			ONSCREEN.put(str_obj , "inspect", __result)
		if depth == 0 : continue
		if obj_type != TYPE_OBJECT : continue
		if obj_value == null : continue
		if obj_value.get_instance_id() in object_inspected : continue
		if str_name == "owner" : continue
		inspect(obj.get(str_name), depth - 1, prefix + "\t", object_inspected)


func _get_first_non_debug_stack() -> Dictionary :
	var _stack = get_stack()
	for s in _stack :
		var _source : String = s.source
		if ! "DEBUG.gd".is_subsequence_of(_source) :
			return s
	return {}


func _get_format_time(my_time: Dictionary = OS.get_time()) -> String :
	var _ftime := "[" + str(my_time.hour) + ":" + str(my_time.minute) + ":" + str(my_time.second) + "]"
	return _ftime


func _get_format_stack(my_stack : Dictionary = _get_first_non_debug_stack()) -> String :
	if my_stack != {} :
		return "[" + str(my_stack.source) + "][" + str(my_stack.function) + "][" + str(my_stack.line) + "]"
	return ""


func _get_format_level(my_lvl : int = LVL_NIV) -> String :
	match(my_lvl) :
		LVL.DEBUG :
			return "[DEBUG]"
		LVL.INFO :
			return "[INFO]"
		LVL.WARNING :
			return "[WARNING]"
		LVL.ERROR :
			return "[ERROR]"
		LVL.CRITICAL :
			return "[CRITICAL]"
	return ""


func get_uniq_name(my_obj : Object) -> String :
	if my_obj != null && name in my_obj:
		return my_obj.name + "." + str(my_obj.get_instance_id())
	else :
		return str(my_obj)


func get_current_tree(current : Node) -> String :
	var result : String = ""
	if current != null :
		var __name = current.get("name")
		if __name != null :
			result = str(__name)
		else :
			result = "Unknow"
		var __parent = current.get_parent()
		if __parent != null :
			result = get_current_tree(__parent) + " -> " + result
	return result
		
