extends TileMap
class_name LevelMap

### Variables ###
#onready var tile_size : Vector2= cell_size
#onready var half_size : Vector2 = tile_size/2
export(int) var tile_wall_id : int = 2
#var obstacles : Array = []

var map_size : Vector2 = get_used_rect().size
onready var half_cell_size = cell_size / 2

### INIT/UPDATE/FREE ###
func init() -> void :
	add_to_group(CONSTANTS.GROUP_LEVELMAP)
	map_size = get_used_rect().size
	pass
	
func free() -> void :
	remove_from_group(CONSTANTS.GROUP_LEVELMAP)
	pass

func update(_delta : float = 0.0) -> void :
	pass

### BUILT-IN
func _ready():
	init()

func _physics_process(delta):
	update(delta)

func _exit_tree() -> void :
	free()
	

### LOGIC ###
#func get_position_top_left(my_tilemap = self) -> Vector2 :
#	if my_tilemap is String :
#		my_tilemap = get_levelMap(my_tilemap)
#	if my_tilemap == null :  return Vector2.ZERO
#	var _zone = my_tilemap.get_used_rect()
#	return Vector2(_zone.position.x, _zone.position.y)
#

#func get_position_bottom_right(my_tilemap = self) -> Vector2 :
#	if my_tilemap is String :
#		my_tilemap = get_levelMap(my_tilemap)
#	if my_tilemap == null :  return Vector2.ZERO
#	if my_tilemap is TileMap :
#		var _zone = my_tilemap.get_used_rect()
#		var _cell_size = my_tilemap.get_cell_size()
#		var _x = (_zone.size.x + _zone.position.x) * _cell_size.x
#		var _y = (_zone.size.y + _zone.position.y) * _cell_size.y
#		return Vector2(_x, _y)
#	return Vector2.ZERO


#func get_levelMap(my_level_name : String) -> LevelMap :
#	if my_level_name == null :  return self
#	if self.name == my_level_name : return self
#	for child in get_children() :
#		if child is TileMap :
#			var _levelMap = child.get_level(my_level_name)
#			if _levelMap != null : return _levelMap
#	return null


#func get_cell_grid_from_object(my_obj : Object) -> Vector2 :
#	var _cell_pos : Vector2
#	if my_obj != null :
#		_cell_pos = world_to_map(my_obj.global_position)
##		ONSCREEN.put(my_actor, "Cell Pos", _cell_pos)
#		return _cell_pos
#	else :
#		DEBUG.error("obj is null")
#	return _cell_pos


#func get_cell_grid_from_global(my_vector : Vector2) -> Vector2 :
#	var _cell_pos : Vector2
#	if my_vector != null :
##		var _pos_vector : Vector2 = get_fixed_global_position(my_vector, true)
##		var _pos_vector : Vector2 = get_fixed_global_position(my_vector, true)
#		_cell_pos = world_to_map(my_vector)
#		return _cell_pos
#	return _cell_pos


#func get_global_position_from_grid(my_vector : Vector2) -> Vector2 :
#	var _local_pos = map_to_world(my_vector)
#	var _global_pos = to_global(_local_pos)
#	return _global_pos


#func get_fixed_global_position(my_position : Vector2, center_to_title = false) -> Vector2 :
#	var _pos : Vector2 = Vector2(my_position)
#	_pos.x = float(round(_pos.x)) 
#	_pos.y = float(round(_pos.y)) 
#	if center_to_title : 
#		_pos += Vector2.ONE * half_size
#	return _pos

func get_room_size():
	pass

func get_obstable_tiles(_tile_wall_id = tile_wall_id) -> Array :
	return get_used_cells_by_id(_tile_wall_id)


func get_navigable_cells() -> Array :
	var __result : Array = []
	var __nav_ids = get_navigable_tileset_ids()
	for __ids in __nav_ids :
		var _used_cells = get_used_cells_by_id(__ids)
		for __cell in _used_cells :
			if ! __result.has(__cell) :
				__result.append(__cell)
	return __result


func get_navigable_tileset_ids() -> Array :
	var __all_ids : Array = tile_set.get_tiles_ids()
	var __result : Array = []
	for __id in __all_ids :
#		print("Id : ", __id, " Name : ", tile_set.tile_get_name(__id),"Nav2D : ",tile_set.tile_get_navigation_polygon(__id))
		if tile_set.tile_get_navigation_polygon(__id) != null :
			__result.append(__id)
	return __result


func point2cell(point_global_position : Vector2, rounded : bool = false) -> Vector2 :
	var __point = point_global_position
	if rounded :
		__point = __point.round()
	return world_to_map(__point)


func cell2point(cell : Vector2) -> Vector2 :
	return map_to_world(cell) + half_cell_size

func get_cell_uid(cell : Vector2) -> int :
	return int(cell.x + map_size.x * cell.y)


func point_to_cell_center(world_point : Vector2) -> Vector2 :
	return cell2point(point2cell(world_point))
	
func point_to_cell_corner(world_point : Vector2) -> Vector2 :
	return cell2point(point2cell(world_point)) - half_cell_size
#func get_neighbor_free_cell_grid(my_obj : Object) -> Array :
#	var result = []
#	var _cellPos = get_cell_grid_from_global(my_obj.global_position)
#	for _dir in [ Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN] :
#		var _cell : Vector2 = _cellPos + _dir
#		if ! ( _cell in obstacles) : result.append(_cell)
#	return result


#func get_neighbor_free_cell_global(my_obj : Object) -> Array :
#	var result : Array = []
#	for _c in get_neighbor_free_cell_grid(my_obj) :
#		result.append(get_global_position_from_grid(_c))
#	return result

#func get_direction_free_cell(my_actor : Actor) -> Array :
#	var result : Array = []
#	var _cells : Array = get_neighbor_free_cell_grid(my_actor)
#	var _cellgrid = get_cell_grid_from_global(my_actor.global_position)
#	for _c in _cells :
#		result.append(_c - _cellgrid)
##	ONSCREEN.put(my_actor, "Available Dir", result)
#	return result

#func get_percent_in_cell(my_obj : Actor, my_cellMap = null) -> float :
#	if my_cellMap == null :
#		my_cellMap = get_cell_grid_from_object(my_obj)
#	var _curr_cell = get_cell_grid_from_object(my_obj)
#	if _curr_cell != my_cellMap : return 0.0
#	var _cell_pos = get_global_position_from_grid(_curr_cell) + half_size
#	return  100 - ((my_obj.global_position.distance_to(_cell_pos)) / (half_size.x )) * 100

#func get_global_distance_between_gridcell_and_obj(from_grid_cell : Vector2, to_my_obj :Object, my_center_cell = true) -> float :
#	var _obj_global = to_my_obj.global_position
#	var _cell_global = get_global_position_from_grid(from_grid_cell)
#	if my_center_cell : _cell_global += half_size
#	return _cell_global.distance_to(_obj_global)
