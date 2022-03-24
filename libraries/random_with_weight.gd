extends Node
class_name RandomWeighted

var _objects : Array = []
var _weights : Array = []
var _random = RandomNumberGenerator.new()

func _init():
	_random.randomize()

 
func add(obj, weight : int) -> void :
	if not _objects.has(obj) :
		var __total_weight : int = _weights.back() if _weights.size() != 0 else 0
		_objects.append(obj)
		_weights.append(__total_weight + weight)


func remove(obj) -> void :
	var __index = _objects.find(obj)
	if __index != -1 :
		var _curr_weight = _weights[__index]
		if __index < _weights.size() -1 :
			for __i in range(__index +1, _weights.size()) :
				_weights[__i] -= _curr_weight
		_objects.remove(__index)
		_weights.remove(__index)


func clear() -> void :
	_objects.clear()
	_weights.clear()


func size() -> int :
	return _objects.size()


func rando() -> Object :
	var __randi = _random.randi() %  (_weights.back())
	for __i in range(_weights.size()) :
		if __randi < _weights[__i] :
			return _objects[__i]
	DEBUG.error("Error not possible")
	return null
