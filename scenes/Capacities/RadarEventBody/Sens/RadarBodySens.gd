extends Capacity
class_name RadarBodySens

const LASER_COLOR = Color(1.0, .329, .298)

var _is_body_detected := false setget ,has_detected
var detected_body = null setget set_body, get_body
var detected_group_name = Hero.GROUP_NAME
	
### SIGNAL ###
signal body_entered(body)
signal body_exited()

### INIT  & UPDATE & EXIT ###
func init_capacity() -> void :
	.init_capacity()
	var __ : int
	__ = connect("body_entered", self, "_on_RadarBodySens_body_entered")
	__ = connect("body_exited", self, "_on_RadarBodySens_body_exited")
	$Sprite.visible = false


func free_capacity() -> void :
	.free_capacity()


func update_capacity(delta : float = get_physics_process_delta_time()) -> void :
	var __ = has_detected()
	.update_capacity(delta)
	
#func _draw_capacity() -> void :
func _draw() -> void :
	.draw_capacity()
	if is_display() && is_debug() :
#		print("Draw detected body ", detected_body)
		if detected_body != null :
			var __from : Vector2 = Vector2()
			var __to : Vector2 = to_local(detected_body.global_position)
			draw_circle(__to , 2, LASER_COLOR)
			draw_line(__from, __to, LASER_COLOR)


### ACCESSORS ###
func has_detected() -> bool :
	for __child in get_children() :
		if __child is RayCast2D :
			if __child.is_colliding() :
				var collider = __child.get_collider()
#				print(name, " has detected ", str(collider))
				if collider.is_in_group(detected_group_name) :
					var space_state := get_world_2d().direct_space_state
					var collision_mask = get_owner_node().collision_mask
					var result = space_state.intersect_ray(global_position, collider.global_position, [self], collision_mask)
#					print(str(collider))
#					print(str(result))
					if result && result.collider == collider :
						set_body(collider)
						return true
	set_body(null)
	return false


func set_body(my_body) -> void :
	if my_body != detected_body : 
		detected_body = my_body
		if detected_body != null :
			_is_body_detected = true
			emit_signal("body_entered", detected_body)
		else :
			detected_body = null
			emit_signal("body_exited")


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
func _on_RadarBodySens_body_entered(_my_body : KinematicBody2D) -> void :
	if is_display() :
		$Sprite.visible = true
	
func _on_RadarBodySens_body_exited() -> void :
	$Sprite.visible = false

func on_capacity_enable_changed(enabled : bool = is_enable()) -> void :
		$RayCast2D.enabled = enabled
		if not is_enable() :
			$Sprite.visible = false
