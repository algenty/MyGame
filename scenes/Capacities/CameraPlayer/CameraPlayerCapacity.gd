extends Capacity
class_name CameraPlayerCapacity, "./CameraPlayerCapacity.svg"

export(Vector2) var zoom_min = Vector2(.20001, .20001)
export(Vector2) var zoom_max = Vector2(2.0, 2.0)
export(Vector2) var zoom_speed = Vector2(0.2, 0.2)
export(Vector2) var zoom_current = Vector2(0.2, 0.2)
export(bool) var enable_input_mouse = true
onready var inital_zoom = $Camera2D.zoom


### SIGNALS ###
signal zoom_changed(zoom)

### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	.init_capacity()
	if $Camera2D :
		$Camera2D.visible = false
	
func free_capacity() -> void :
	.free_capacity()
	
func update_capacity(delta : float = 0.0) -> void :
	.update_capacity()

func input_capacity(event : InputEvent) -> void :
	if not is_enable() : return
	if Utils.is_input_camera(event) && enable_input_mouse : 
		if event.button_index == BUTTON_WHEEL_UP :
			zoom()
		if event.button_index == BUTTON_WHEEL_DOWN :
			unzoom()
	.input_capacity(event)
	
### BUIT-IT ###


### LOGIC ###
func unzoom(value : Vector2 = zoom_speed) -> void :
	if $Camera2D.zoom < zoom_max :
		$Camera2D.zoom += value
		zoom_current = $Camera2D.zoom
		emit_signal("zoom_changed", zoom_current)

func zoom(value : Vector2 = zoom_speed) -> void :
	if $Camera2D.zoom > zoom_min :
		$Camera2D.zoom -= value
		zoom_current = $Camera2D.zoom
		emit_signal("zoom_changed", zoom_current)

func reset() -> void :
	var _old_value = $Camera2D.zoom
	$Camera2D.zoom = inital_zoom
	zoom_current = $Camera2D.zoom
	if _old_value != zoom_current :
		emit_signal("zoom_changed", zoom_current)
	
func limit_border(top_left : Vector2, bottom_right: Vector2) -> void :
	$Camera2D.limit_left = top_left.x
	$Camera2D.limit_top = top_left.y
	$Camera2D.limit_right = bottom_right.x
	$Camera2D.limit_bottom = bottom_right.y

### Events ###
