extends Navigation2D
class_name NavGridMap2D

const DIR_X = [Vector2.DOWN, Vector2.UP]
const DIR_Y = [Vector2.LEFT, Vector2.RIGHT]

func get_advanced_simple_path(start: Vector2, end: Vector2, optimize: bool = false, diagonals : bool = false) -> PoolVector2Array :
	var _path : Array = get_simple_path(start, end, optimize)
	_path.remove(0)
#	_path.remove(1)
#	if diagonals : return PoolVector2Array(_path)
	if _path.size() <= 1 : return PoolVector2Array(_path) 
	var _newpath : Array = []
	var _prev_point : Vector2 = _path[0]
#	_path.remove(0)
	_newpath.append(_prev_point)
	var _curr_point : Vector2
	var _dir = _prev_point.direction_to(_path[1])
	for i in range(1, _path.size() -1) :
		_curr_point = _path[i]
#		print("previous point : ",  _prev_point)
#		print("current point : ",  _curr_point)
		if ! diagonals :
			if _curr_point.x != _prev_point.x && _curr_point.y != _prev_point.y :
				var _new_point : Vector2 = Vector2(_prev_point.x, _curr_point.y) if _dir in DIR_X else Vector2(_curr_point.x, _prev_point.y) 
	#			print("Fixed ", _curr_point," to ", _new_point)
				_newpath.append(_new_point)
		_newpath.append(_curr_point )
		_dir = _prev_point.direction_to(_curr_point)
		_prev_point = _curr_point
#	print("OLD : ", _path)
#	print("NEW : ", _newpath)
	return PoolVector2Array(_newpath)
#	return PoolVector2Array(_path)

func is_navigable(_position : Vector2) -> bool :
	return true
