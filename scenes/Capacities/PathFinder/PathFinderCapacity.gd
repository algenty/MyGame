extends Capacity
class_name PathFinderCapacity, "./PathFinderCapacity.svg"

### CONSTANTS
#const BASE_LINE_WIDTH = 3.0
#const DRAW_COLOR = Color('#fff')
const TEXTURE_EXCLUDE = "res://scenes/Capacities/PathFinder/exclude.svg"
const MARGIN_DISTANCE = 3
const NUMBER_OF_TRY_RANDOM_POINT = 4


### Exports
export(String) var tilemaps_group = CONSTANTS.GROUP_LEVELMAP
export(bool) var enable_diagonals = false
export(bool) var add_disable_point_with_mouse : bool = true
export(bool) var change_path_with_mouse : bool = true

### Variables
var _astart : AStar2D = AStar2D.new()
var _room_size : int = 1000
var _navigable_cells : Array = []
var _navigable_points : Array = []
var _levelmap : LevelMap
var _global_origin : Vector2 setget set_origin, get_origin
var _global_position : Vector2 setget set_origin, get_origin
var _global_target : Vector2 setget set_target, get_target
var _path : Array = [] setget  , get_finded_path
var _on_target : bool = false
#var _marked_points : Array = []
var _disabled_uid : Array = []
var _disabled_points : Array = []
var _disabled_pic_points : Array = []
var _disabled_pic_object : Array = []
var _exclude_texture = preload(TEXTURE_EXCLUDE) if .is_display() else null
onready var _line2D = $Line2D

### Signals
signal path_generated(reversed_path)
signal no_path_finded()
signal point_excluded(world_point)
signal point_included(world_point)

### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	.init_capacity()
	if tilemaps_group == null || tilemaps_group.empty() :
		DEBUG.critical("No group defined for tilemap")
	var __levelmaps : Array = get_tree().get_nodes_in_group(tilemaps_group)
	if __levelmaps.empty() :
		DEBUG.critical("No tilemap/levelmap in group [%s]" % tilemaps_group)
		return
	if __levelmaps.size() != 1 :
		DEBUG.critical("Only 1 levelMap is supported")
	_levelmap = __levelmaps[0]
	# Inits childs
	$Line2D.set_as_toplevel(true)
	# Connects
	var __ = connect("path_generated", self, "_on_self_path_generated")
	__ = connect("point_excluded", self, "_on_self_point_excluded")
	__ = connect("point_included", self, "_on_self_point_included")
	# Astar
	_astart_init()
	
	# origin is owner
	var __agent = get_owner_node()
	if __agent : set_origin(__agent.global_position)


func free_capacity() -> void :
	.free_capacity()


func update_capacity(_delta : float = 0.0) -> void :
	DEBUG.warning("Process Mode is nt necessary for this capacity")


func input_capacity(event):
	if event is InputEventMouseButton :
		if change_path_with_mouse && event.button_index == BUTTON_LEFT and event.pressed and is_debug() :
			set_target(get_global_mouse_position())
		if add_disable_point_with_mouse && event.button_index == BUTTON_RIGHT and event.pressed and is_debug() :
			var __point = get_global_mouse_position()
			switch_point(__point)


### ACCESSORS ###
func process_path() -> void :
	if _global_origin && _global_target :
		_path = find_path()
		_on_target = false
		emit_signal("path_generated", _path)

func set_target(value : Vector2, force = false) -> void :
	var _new_target := value
	if _new_target != _global_target || force:
		_global_target = _new_target
		process_path()


func get_target() -> Vector2 :
	return _global_target


func set_origin(value : Vector2) -> void :
	var _new_orgin := value
	if _new_orgin!= _global_origin :
		_global_origin = _new_orgin
#		process_path()


func get_origin() -> Vector2 :
	return _global_origin


func get_finded_path() -> Array :
	return _path


func on_capacity_enable_changed(value : bool = is_enable()) -> void :
	.on_capacity_enable_changed(value)
	if is_enable() && is_display() :
		_exclude_texture = preload(TEXTURE_EXCLUDE)
	$Line2D.visible = is_enable() && is_display()

### Logic


func get_next_point(current_world_position : Vector2) -> Vector2 :
	var __curr_point : Vector2 = get_current_point(current_world_position)
	var __index : int = _path.find(__curr_point)
	var __next_point : Vector2 = current_world_position
	# On the path but not the last
	if (__index !=  -1) && (__index != _path.size() -1)  :
#		print("get_next_point ", __index + 1,"/", _path.size())
		__next_point = _path[__index + 1]
	# On the path and last postion
	elif _on_target || (__index ==  _path.size() - 1 && __curr_point in _path) :
#		print("get_next_point ", __index + 1,"/", _path.size())
		_on_target = true
		__next_point = _path.back()
	# Not on the path and not targeted
	elif _path.size() > 0  && not __curr_point in _path :
			__next_point = _path[0]
	return __next_point


func get_direction(current_world_position : Vector2) -> Vector2 :
	if is_on_target(current_world_position) : return Vector2.ZERO
	var __curr_point = get_current_point(current_world_position)
	var __next_point : Vector2 = get_next_point(current_world_position)
#	print("Cur : ",__curr_point, " Next_point", __next_point)
	if __curr_point == __next_point : return Vector2.ZERO
	var __direction = current_world_position.direction_to(__next_point)
#	if ! enable_diagonals : 
#		__direction = __direction.round()
	return __direction


func get_current_point(current_world_position : Vector2) -> Vector2 :
	return _levelmap.point_to_cell_center(current_world_position)


func is_valid_target(current_world_position : Vector2) -> bool :
#	var __center_point = get_current_point(current_world_position)
	var __cell = _levelmap.point2cell(current_world_position)
	var __uid = _levelmap.get_cell_uid(__cell)
	return _astart.has_point(__uid)


func is_on_next_point(current_world_position : Vector2, margin : float = MARGIN_DISTANCE ) -> bool :
	var __current_point : Vector2 = get_current_point(current_world_position)
	var __next_point : Vector2 = get_next_point(current_world_position)
	return current_world_position.distance_to(__next_point) <= margin


func is_on_target(current_world_position : Vector2, margin : float = MARGIN_DISTANCE ) -> bool :
	var __distance = current_world_position.distance_to(_global_target)
	_on_target = __distance <= margin || _on_target
	return _on_target || __distance <= margin


func get_distance_to_next_point(current_world_position : Vector2) -> float :
	var __next_point : Vector2 = get_next_point(current_world_position)
	return current_world_position.distance_to(__next_point)


func _compute_path() -> void :
	if _global_target && _global_origin :
		_path = find_path()


func has_path() -> bool :
	return _path.size() > 0


func get_random_available_points() -> Vector2 :
	var __random = RandomNumberGenerator.new()
	__random.randomize()
	var __available : bool = false
	var __world_point : Vector2
	var __cell : Vector2
	var __uid : int
	var __index : int
#	var __try : int = NUMBER_OF_TRY_RANDOM_POINT
#	while (not __available || not __try) :
#		__try -= 1
	__index = __random.randi() % _navigable_points.size()
	__world_point = _navigable_points[__index]
	__cell = _levelmap.point2cell(__world_point)
	__uid = get_cell_uid(__cell)
	__available = ! _astart.is_point_disabled(__uid)
	if not __available :
		DEBUG.warning("Point [%s] is not available" % __world_point)
	return __world_point


func find_path(from : Vector2 = _global_origin, to: Vector2 = _global_target, exclude_points : Array = _disabled_points) -> Array :
	var __from_rounded = _levelmap.point_to_cell_center(from)
	var __from_cell = _levelmap.point2cell(__from_rounded)
	var __from_cell_uid = get_cell_uid(__from_cell)
	var __to_rounded = _levelmap.point_to_cell_center(to)
	var __to_cell = _levelmap.point2cell(__to_rounded)
	var __to_cell_uid = get_cell_uid(__to_cell)

	disable_points_array(exclude_points)
	var __path_cells : =  _astart.get_point_path(__from_cell_uid, __to_cell_uid)
	var __path_points : Array = []
	if __path_cells.size() == 0 :
		emit_signal("no_path_finded")
	else :
		# Convert all cells pos to global
		for __i  in range(1, __path_cells.size() - 1) :
			var __cell = __path_cells[__i]
			var __point : Vector2 = _levelmap.cell2point(__cell)
			__path_points.append(__point)
		# Last point is "to"
		__path_points.append(__to_rounded)
	return __path_points


func switch_point(world_point : Vector2) -> void :
	disable_point(world_point, ! is_disabled_point(world_point))


func disable_point(world_point : Vector2, disable = true) -> void :
	var __rounded_point = _levelmap.point_to_cell_center(world_point)
	var __cell = _levelmap.point2cell(world_point)
	var __uid = get_cell_uid(__cell)
	if disable && not _disabled_uid.has(__rounded_point) :
		_disabled_uid.append(__uid)
		_disabled_points.append(__rounded_point)
		_astart.set_point_disabled(__uid, true)
		emit_signal("point_excluded", __rounded_point)
		return
	if  not disable && _disabled_uid.has(__uid) && _astart.has_point(__uid) :
		var __index = _disabled_uid.find(__uid)
		_astart.set_point_disabled(__uid, false)
		_disabled_uid.remove(__index)
		_disabled_points.remove(__index)
		emit_signal("point_included", __rounded_point)


func is_disabled_point(world_point : Vector2) -> bool :
	var __rounded_point = _levelmap.point_to_cell_center(world_point)
	var __cell = _levelmap.point2cell(__rounded_point)
	var __uid = _levelmap.get_cell_uid(__cell)
	var __is_disabled = _disabled_uid.has(__uid)
	return __is_disabled


func disable_points_array(world_point_array : Array, disable : bool = true) -> void :
	var __duplicate_array = world_point_array.duplicate()
	for __point in __duplicate_array :
		disable_point(__point, disable)


func reset_disabled_points() -> void :
	disable_points_array(_disabled_points, false)


func display_excluded_point(world_point : Vector2, disable = true) -> void :
	var __corner_point = _levelmap.point_to_cell_corner(world_point)
	# Si non présent et à désactiver
	if disable && not _disabled_pic_points.has(__corner_point) :
		var __exclude_pic = TextureRect.new()
		__exclude_pic.texture = _exclude_texture
		var __cell_corner = _levelmap.point_to_cell_corner(world_point)
		__exclude_pic.set_global_position(__cell_corner)
		_disabled_pic_object.append(__exclude_pic)
		_disabled_pic_points.append(__corner_point)
		add_child(__exclude_pic)
		__exclude_pic.set_as_toplevel(true)
		return
	# Si présent et à activer
	if not disable && _disabled_pic_points.has(__corner_point) :
		var __index = _disabled_pic_points.find(__corner_point)
		if __index != -1 :
			_disabled_pic_object[__index].queue_free()
			_disabled_pic_object.remove(__index)
			_disabled_pic_points.remove(__index)
		return


func _astart_init(levelmap : LevelMap = _levelmap, __enable_diagonals : bool = enable_diagonals) -> void :
	## Checks

	## Get navigables cells
	_navigable_cells = levelmap.get_navigable_cells()
	## Add this cells to astart
	for __cell in _navigable_cells :
		var __uid = get_cell_uid(__cell)
		var __world_point = levelmap.cell2point(__cell)
		_navigable_points.append(__world_point)
		_astart.add_point(__uid, __cell)
	## Connect points
	_astart_connect(_navigable_cells, __enable_diagonals)


func _astart_connect(point_array : Array = _navigable_cells, __enable_diagonals : bool = enable_diagonals) -> void :
	## https://www.youtube.com/watch?v=kjveugvr9cM&list=PLeeK5VJQ55mOsZpct-OtUB2TIgNnGjHZq&index=14
	for __point in point_array :
		var __point_uid = get_cell_uid(__point)
		if not _astart.has_point(__point_uid) :
			continue
		
		for __x_offset in range(3) :
			for __y_offset in range(3) :
				if ! __enable_diagonals && __x_offset in [0, 2] && __y_offset in [0, 2] :
					continue 
				var __point_relative : Vector2 =  Vector2(__point.x + __x_offset -1, __point.y + __y_offset -1 )
				var __point_relative_uid : int = get_cell_uid(__point_relative)
				## if itself or not have point
				if __point_relative == __point or ! _astart.has_point(__point_relative_uid) :
					continue
				## Else
				_astart.connect_points(__point_uid, __point_relative_uid, false)


func get_cell_uid(cell : Vector2) -> int :
	return _levelmap.get_cell_uid(cell)


### EVENTS ###
func _on_self_path_generated(new_path : Array) -> void :
	if is_display() :
		_line2D.points = new_path
	if is_debug() :
		ONSCREEN.put(get_owner_node(), "Path size : ", _path.size())


func _on_self_point_excluded(world_point) -> void :
	if is_display() :
		display_excluded_point(world_point, true)
	if is_debug() :
		DEBUG.debug("Add exclude point [%s]" % world_point)
		ONSCREEN.put(get_owner_node(),"Exclude points", _disabled_pic_points)


func _on_self_point_included(world_point) -> void :
	if is_display() :
		display_excluded_point(world_point, false)
	if is_debug() :
		DEBUG.debug("Remove exclude point [%s]" % world_point)
		ONSCREEN.put(get_owner_node(),"Exclude points", _disabled_pic_points)
