extends Node2D

export(bool) var label_position_enable:bool = true
export(bool) var label_velocity_enable:bool = true
export(bool) var label_direction_enable:bool = true

#onready var enemy_scene = preload("res://scenes/Actors/Characters/Enemy/Enemy.tscn")
var timer : Timer



func _draw() -> void:
#	Utils.draw_grid(self, 16)
	pass


func _ready():
	pass
#	timer = Timer.new()
#	add_child(timer)
#	timer.connect("timeout", self, "new_enemy")
#	timer.start(5.0)
#	if ! label_position_enable : 
#		label_position.visible = false
#		return

func _physics_process(_delta):
	pass


func new_enemy() :
	pass
#	for child in get_children() :
#		if child is Position2D :
#			var enemy = enemy_scene.instance()
#			child.add_child(enemy)
#	timer.start(5.0)
