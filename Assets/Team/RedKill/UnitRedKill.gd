extends "res://Assets/Unit/Unit.gd"

func _ready():
	team = 1
	update_collision_bit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_rotation = 0
