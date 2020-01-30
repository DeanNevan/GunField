extends "res://Assets/Unit/Unit.gd"

var AI_dodge
var AI_collect

func _ready():
	team = 0
	
	update_collision_bit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_rotation = 0
	if !is_player_unit:
		pass#AI



