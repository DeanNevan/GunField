extends Node

var init_speed = 300
var main_unit_speed = 300
var init_size = 100
var unit

var team_number
var is_player_team
var main_unit

var team_weapon
var team_color

var basic_conversion_rate = 1#基础转化率

onready var main = get_node("/root/Main")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func update_main_unit():
	var _max_size = 0
	var _main_unit
	if get_child_count() != 0:
		_main_unit = get_child(0)
		for i in get_child_count():
			get_child(i).is_main_unit = false
			get_child(i).is_player_unit = false
			if get_child(i).size > _max_size:
				_main_unit = get_child(i)
				_max_size = _main_unit.size
	main_unit = _main_unit
	main_unit.is_main_unit = true
	#main_unit.main = main
	if is_player_team:
		main.player_unit = main_unit
		main_unit.is_player_unit = true

func game_init(init_position = Vector2(), is_player_team1 = false, init_unit_count = 1):
	is_player_team = is_player_team1
	
	for i in init_unit_count:
		var new_unit = unit.instance()
		new_unit.team = team_number
		new_unit.global_position = init_position + Vector2(rand_range(-100, 100), rand_range(-100, 100))
		new_unit.size = init_size
		new_unit.speed = init_speed
		add_child(new_unit)
		#var weapon = load("res://Assets/Guns/MP5/MP5.tscn").instance()
		#var weapon = load("res://Assets/Guns/Arc-001/Arc-001.tscn").instance()
		#var weapon = load("res://Assets/Guns/Ju-001/Ju-001.tscn").instance()
		var weapon = team_weapon.instance()
		weapon.unit = new_unit
		new_unit.weapon = weapon
		new_unit.main = main
		new_unit.add_child(weapon)
	
	if is_player_team:
		get_child(randi() % get_child_count()).is_player_unit = true
	
	update_main_unit()