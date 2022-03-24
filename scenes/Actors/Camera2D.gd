extends Camera2D

export(bool) var enable :bool = true

var zoom_min = Vector2(0.2 , 0.2)
var zoom_max = Vector2(2.0 , 2.0)
var zoom_speed = Vector2(0.2 , 0.2)
var des_zoom = zoom


func _physics_process(my_delta):
	var __ = my_delta
	if enable :
		zoom = lerp(zoom, des_zoom, 0.2)

func _input(event):
	if enable && event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				if des_zoom > zoom_min:
					des_zoom -= zoom_speed
			if event.button_index == BUTTON_WHEEL_DOWN:
				if des_zoom < zoom_max:
					des_zoom += zoom_speed
				print(zoom)	
					
			
