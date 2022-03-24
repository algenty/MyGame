extends Node2D
class_name Utils

static func draw_grid(_node : Node2D, _tile_size : int = 16) -> void:
	# Draw a border around each tile: we cannot draw a fine separator between
	# tiles with this zoomed-in viewport. It look as if the player position
	# is off when we only draw a line on the right and bottom edge of each tile
	var screen_size = _node.get_viewport_rect().size
	for x in range(0, screen_size.x / _tile_size):
		# Draw left line; add +0.5 because the lefthand side is cropped for some reason
		var pos = Vector2(x, 0) * _tile_size + Vector2(0.5, 0)
		_node.draw_line(pos, pos + Vector2(0, screen_size.y), Color(1, 1, 1, 0.2))
		# Draw right line
		pos += Vector2(_tile_size - 1, 0)
		_node.draw_line(pos, pos + Vector2(0, screen_size.y), Color(1, 1, 1, 0.2))
	for y in range(0, screen_size.y / _tile_size):
		# Draw top line
		var pos = Vector2(0, y) * _tile_size
		_node.draw_line(pos, pos + Vector2(screen_size.x, 0), Color(1, 1, 1, 0.2))
		# Draw bottom line
		pos += Vector2(0, _tile_size - 1)
		_node.draw_line(pos, pos + Vector2(screen_size.x, 0), Color(1, 1, 1, 0.2))

static func get_direction_name(_direction : Vector2) -> String :
	match(_direction) :
		Vector2.LEFT : return "Left"
		Vector2.RIGHT : return "Right"
		Vector2.UP : return "Up"
		Vector2.DOWN : return "Down"
		Vector2.ZERO : return ""
	return ""

static func is_input_move(my_event : InputEvent) -> bool :
	if my_event is InputEventKey :
		if Input.is_action_pressed("ui_right") : return true
		if Input.is_action_pressed("ui_left") : return true
		if Input.is_action_pressed("ui_up") : return true
		if Input.is_action_pressed("ui_down") : return true	
	return false


static func is_input_camera(my_event : InputEvent) -> bool :
	if my_event is InputEventMouseButton :
		if my_event.is_pressed() :
			if my_event.button_index == BUTTON_WHEEL_UP : return true
			if my_event.button_index == BUTTON_WHEEL_DOWN : return true
	return false
