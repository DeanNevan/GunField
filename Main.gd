extends Node2D

var player_unit
var player_team

var selected_unit
var on_mouse_unit

var team_count = 2

var color_array = [Color.black, Color.blue, Color.red, 
				   Color.green, Color.white, Color.yellow, 
				   Color.gray, Color.purple, Color.orange, Color.pink, 
				   Color.blueviolet, Color.aliceblue, Color.darkviolet
				  ]

var little_ball = preload("res://Assets/LittleBall/LittleBall.tscn")

var map_size = Vector2(3000, 3000)

onready var DebugLabel = $CanvasLayer/Debug
onready var TweenCameraZoom = Tween.new()
onready var add_LittleBall_timer = Timer.new()
onready var LB_monitor_timer = Timer.new()
func _draw():
	draw_circle(Vector2(), 10, Color.black)
	draw_rect(Rect2(Vector2(), map_size), Color.black, false)
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(TweenCameraZoom)
	
	add_child(add_LittleBall_timer)
	add_LittleBall_timer.one_shot = false
	add_LittleBall_timer.start(4)
	add_LittleBall_timer.connect("timeout", self, "_on_add_little_ball_timer_timeout")
	
	add_child(LB_monitor_timer)
	LB_monitor_timer.one_shot = false
	LB_monitor_timer.start(5)
	LB_monitor_timer.connect("timeout", self, "_on_LB_monitor_timer_timeout")
	randomize()
	game_start(1)
	#print("i am here")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if selected_unit != null:
		DebugLabel.text = ("该单位信息" + "\n"
						+ "体积：" + str(selected_unit.size) + "\n"
						+ "速度：" + str(selected_unit.speed) + "\n"
						+ "【漫游】优先级：" + str(selected_unit.get_node("AI").AI_priorities[selected_unit.get_node("AI").AI_action.wander]) + "\n"
						+ "【收集】优先级：" + str(selected_unit.get_node("AI").AI_priorities[selected_unit.get_node("AI").AI_action.collect]) + "\n"
						+ "【守护】优先级：" + str(selected_unit.get_node("AI").AI_priorities[selected_unit.get_node("AI").AI_action.guard]) + "\n"
						+ "【攻击】优先级：" + str(selected_unit.get_node("AI").AI_priorities[selected_unit.get_node("AI").AI_action.attack]) + "\n"
						+ "【躲避】优先级：" + str(selected_unit.get_node("AI").AI_priorities[selected_unit.get_node("AI").AI_action.dodge]) + "\n"
						) 
	
	if player_unit != null:
		$Camera2D.position = player_unit.position
		update_camera_zoom(0.3 * player_unit.size_para)

func _on_add_little_ball_timer_timeout():
	add_little_ball(100)

func _on_LB_monitor_timer_timeout():
	if get_tree().get_nodes_in_group("LB").size() >= 3000:
		add_LittleBall_timer.paused = true
	else:
		add_LittleBall_timer.paused = false

func add_little_ball(count = 100):
	for i in count:
		var new_little_ball = little_ball.instance()
		new_little_ball.modulate = color_array[randi() % color_array.size()]
		new_little_ball.global_position = Vector2(rand_range(0, map_size.x), rand_range(0, map_size.y))
		new_little_ball.size = 5
		new_little_ball.get_node("Sprite").visible = false
		add_child(new_little_ball)
		new_little_ball.add_to_group("LB")
	pass

func game_start(player_team_number):
	for i in team_count:
		if i == player_team_number:
			match player_team_number:
				0:
					player_team = $TeamWhiteWing
					player_team.game_init(Vector2(100, 100), true, 5)
				1:
					player_team = $TeamRedKill
					player_team.game_init(Vector2(200, 200), true, 5)
		else:
			match i:
				0:
					$TeamWhiteWing.game_init(Vector2(100, 100), false, 5)
				1:
					$TeamRedKill.game_init(Vector2(200, 200), false, 5)

func update_camera_zoom(target_number):
	TweenCameraZoom.interpolate_property($Camera2D, "zoom", $Camera2D.zoom, Vector2(target_number, target_number), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	TweenCameraZoom.start()
