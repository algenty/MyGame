extends Node2D

export(bool) var enable = true
export(bool) var mouse_position = true
var display: Dictionary = {}
onready var label = $CanvasLayer/Label

func _ready(): 
	if ! enable : 
		label.visible = false
		$CanvasLayer.queue_free()
	pass

func _unhandled_key_input(event):
	if ! enable : return
	if Input.is_key_pressed(KEY_R) :
		ONSCREEN.clear()
		var __ = get_tree().reload_current_scene()
	if Input.is_key_pressed(KEY_C) :
		ONSCREEN.clear()
	if Input.is_key_pressed(KEY_P) :
		get_tree().paused = ! get_tree().paused
	if event is InputEventMouseButton:
	   print("Mouse Click/Unclick at: ", event.position)


func _input(event):
	if ! enable : return
	if event is InputEventMouseButton:
		ONSCREEN.put("Mouse","Click pos", get_local_mouse_position())
	

func put(my_name, my_key, my_value = null) :
	if ! enable : return
	if my_value == null : my_value = "Null"
	if not my_name is String :
		my_name = DEBUG.get_uniq_name(my_name) 
	if display.has(my_name) :
		var _sub_dis : Dictionary = display[my_name]
		if _sub_dis.has(my_key) :
			if my_value != null :
				_sub_dis[my_key] = str(my_value)
			else :
				var __ = _sub_dis.erase(my_key)
				if _sub_dis.empty() :
					__ = display.erase(my_name)
		else :
			_sub_dis[my_key] = str(my_value)
		update_screen()
	else :
		display[my_name] = {}
		put(my_name, my_key, my_value)

func update_screen() :
	if ! enable : return
	var _txt : String = ""
	for _name in display.keys() :
		_txt += str(_name) + " :\n"
		var _sub = display[_name]  
		for key in _sub.keys() :
			_txt += "   " + str(key) + " : " + str(_sub[key]) + "\n"
	label.set_text(_txt)

func clear() :
	if ! enable : return
	display.clear()
	update_screen()
