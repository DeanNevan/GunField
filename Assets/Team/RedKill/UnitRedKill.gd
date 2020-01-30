extends "res://Assets/Unit/Unit.gd"

enum AI_action{
	wander#漫游
	collect#收集
	guard#警戒
	attack#攻击
	catch#追赶
	dodge#躲避
}

var AI_state = AI_action.wander

var AI_priorities = {AI_action.wander : 0, AI_action.collect : 0, AI_action.guard : 0, AI_action.attack : 0, AI_action.catch : 0, AI_action.dodge : 0}

var enemies_in_MonitorArea := []

var teammates_in_MonitorArea := []

var little_balls_in_MonitorArea := []

onready var MonitorArea = $MonitorArea

onready var MonitorTimer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	team = 1
	update_collision_bit()
	
	update_MonitorAreaShape()
	add_child(MonitorTimer)
	MonitorTimer.connect("timeout", self, "_on_MonitorTimer_timeout")
	MonitorTimer.one_shot = true
	MonitorTimer.start(2)

func update_MonitorAreaShape():
	if weapon != null:
		MonitorArea.get_node("CollisionShape2D").shape.radius = 15 * $Sprite.scale.x + 2 * weapon.fire_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_rotation = 0

func monitor():
	if is_player_unit:
		MonitorArea.get_node("CollisionShape2D").visible = true
		print("-----本次监测开始-----")
		print("有 " + str(enemies_in_MonitorArea.size()) + " 个敌人在警戒范围里")
		print("有 " + str(teammates_in_MonitorArea.size()) + " 个队友在警戒范围里")
		print("有 " + str(little_balls_in_MonitorArea.size()) + " 个小球在警戒范围里")
		print("-----本次监测结束-----")
		
	pass

func _clamp_priority():
	AI_priorities[AI_action.wander] = clamp(AI_priorities[AI_action.wander], 0, 4)
	AI_priorities[AI_action.collect] = clamp(AI_priorities[AI_action.collect], 0, 4)
	AI_priorities[AI_action.guard] = clamp(AI_priorities[AI_action.guard], 0, 4)
	AI_priorities[AI_action.attack] = clamp(AI_priorities[AI_action.attack], 0, 4)
	AI_priorities[AI_action.catch] = clamp(AI_priorities[AI_action.catch], 0, 4)
	AI_priorities[AI_action.dodge] = clamp(AI_priorities[AI_action.dodge], 0, 4)
	

func _on_MonitorTimer_timeout():
	update_MonitorAreaShape()
	monitor()
	MonitorTimer.start(2)

func _on_MonitorArea_body_entered(body):
	if body.has_method("get_damage"):
		if body.team == team:
			teammates_in_MonitorArea.append(body)
		else:
			enemies_in_MonitorArea.append(body)
	pass # Replace with function body.

func _on_MonitorArea_area_entered(area):
	if area.has_method("_on_LittleBall_body_entered"):
		little_balls_in_MonitorArea.append(area)
	pass # Replace with function body.

func _on_MonitorArea_body_exited(body):
	if body.has_method("get_damage"):
		if body.team == team:
			teammates_in_MonitorArea.erase(body)
		else:
			enemies_in_MonitorArea.erase(body)
	pass # Replace with function body.

func _on_MonitorArea_area_exited(area):
	if area.has_method("_on_LittleBall_body_entered"):
		little_balls_in_MonitorArea.erase(area)
	pass # Replace with function body.