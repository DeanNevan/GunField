extends "res://Assets/Scripts/TeamTemplate.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	#team_weapon = preload("res://Assets/Guns/Arc-001/Arc-001.tscn")
	team_weapon = preload("res://Assets/Guns/MP5/MP5.tscn")
	team_color = Color.red
	unit = preload("res://Assets/Team/RedKill/UnitRedKill.tscn")
	team_number = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
