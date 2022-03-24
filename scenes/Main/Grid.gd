extends Node2D

export var on = true
export(int) var grid_px : int = 16

func _draw():
	if on: 
		var size = get_viewport_rect().size  * get_parent().get_node("Camera2D").zoom / 2
		var cam = get_parent().get_node("Camera2D").position
		for i in range(int((cam.x - size.x) / grid_px) - 1, int((size.x + cam.x) / grid_px) + 1):
			draw_line(Vector2(i * grid_px, cam.y + size.y + 100), Vector2(i * grid_px, cam.y - size.y - 100), "000000")
		for i in range(int((cam.y - size.y) / grid_px) - 1, int((size.y + cam.y) / grid_px) + 1):
			draw_line(Vector2(cam.x + size.x + 100, i * grid_px), Vector2(cam.x - size.x - 100, i * grid_px), "000000")

func _process(delta):
	update()
