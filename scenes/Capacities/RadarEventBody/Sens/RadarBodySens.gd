extends Capacity
class_name RadarBodySens

var _is_body_detected := false setget ,has_detected
var detected_body = null setget set_body, get_body
onready var detected_group_name = get_parent().detected_group_name

### SIGNAL ###
signal body_detected(body)
signal no_body_detected()

### INIT  & UPDATE & EXIT ###
func init() -> void :
	var __ = connect("body_detected", self, "_on_RadarBodySens_body_detected")
	__ = connect("no_body_detected", self, "_on_RadarBodySens_no_body_detected")
	$Sprite.visible = false
	.init()
	
func free() -> void :
	.free()
	
func update(delta : float = get_physics_process_delta_time()) -> void :
	var __ = has_detected()
	.update(delta)


### ACCESSORS ###
func has_detected() -> bool :
	for _child in get_children() :
		if _child is RayCast2D :
			if _child.is_colliding() :
				var collider = _child.get_collider()
				if collider.is_in_group(detected_group_name) :
					set_body(collider)
					return true
	set_body(null)
	return false


func set_body(my_body) -> void :
	if my_body != detected_body : 
		detected_body = my_body
		if detected_body != null :
			_is_body_detected = true
			emit_signal("body_detected", detected_body)
		else :
			emit_signal("no_body_detected")
			
func get_body() -> KinematicBody2D :
	return detected_body


func set_size( my_size : float ) -> void :
	for _child in get_children() :
		if _child is RayCast2D :
			_child.set_cast_to(Vector2(0,my_size))

### BUILT-IN ###

func _physics_process(_delta):
	var __ = has_detected()

### LOGIC ###
			
	
### EVENTS ###
func _on_RadarBodySens_BODY_DETECTED(_my_body : KinematicBody2D) -> void :
	$Sprite.visible = true
	
func _on_RadarBodySens_NO_BODY_DETECTED() -> void :
	$Sprite.visible = false



