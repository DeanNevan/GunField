extends "res://Assets/Scripts/TeamTemplate.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	team_weapon = preload("res://Assets/Guns/Ju-001/Ju-001.tscn")
	team_color = Color.white
	basic_conversion_rate = 0.5
	init_size = 60
	init_speed = 180
	unit = preload("res://Assets/Team/WhiteWing/UnitWhiteWing.tscn")
	team_number = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

