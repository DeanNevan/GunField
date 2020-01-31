extends Node

enum AI_action{
	wander#漫游
	collect#收集
	guard#警戒
	attack#攻击
	catch#追赶
	dodge#躲避
}

var AI_state = AI_action.wander

var AI_priorities := {AI_action.wander : 0, AI_action.collect : 0, AI_action.guard : 0, AI_action.attack : 0, AI_action.catch : 0, AI_action.dodge : 0}
var AI_action_wander_max_priority := 4
var AI_action_collect_max_priority := 4
var AI_action_guard_max_priority := 4
var AI_action_attack_max_priority := 4
var AI_action_catch_max_priority := 4
var AI_action_dodge_max_priority := 4

var AI_priorities_array := []

var enemies_in_MonitorArea := []

var enemy_bullets_in_MonitorArea := []

var teammates_in_MonitorArea := []

var little_balls_in_MonitorArea := []

var attack_priorities := {}
var attack_priorities_array := []

var lb_priorities := {}
var lb_priorities_array := []

var guard_priorities := {}
var guard_priorities_array := []

var catch_priorities := {}
var catch_priotities_array := []

var dodge_priorities := {}
var dodge_priorities_array := []

onready var MonitorArea = $MonitorArea
var monitor_sensitivity := 1.2
onready var MonitorTimer = Timer.new()

var team
# Called when the node enters the scene tree for the first time.
func _ready():
	team = get_parent().team
	update_MonitorAreaShape()
	add_child(MonitorTimer)
	MonitorTimer.connect("timeout", self, "_on_MonitorTimer_timeout")
	MonitorTimer.one_shot = true
	MonitorTimer.start(2)
	
	_clamp_AI_priority()
	AI_priorities_array = list_sort_to_array(AI_priorities)

func update_MonitorAreaShape():
	if get_parent().weapon != null:
		MonitorArea.get_node("CollisionShape2D").shape.radius = 15 * $Sprite.scale.x + monitor_sensitivity * get_parent().weapon.fire_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func count_monitor():
	"""if is_player_unit:
		MonitorArea.get_node("CollisionShape2D").visible = true
		print("-----本次监测开始-----")
		print("有 " + str(enemies_in_MonitorArea.size()) + " 个敌人在警戒范围里")
		print("有 " + str(teammates_in_MonitorArea.size()) + " 个队友在警戒范围里")
		print("有 " + str(little_balls_in_MonitorArea.size()) + " 个小球在警戒范围里")
		print("-----本次监测结束-----")"""
	
	
	_clamp_AI_priority()
	AI_priorities_array = list_sort_to_array(AI_priorities)
	pass

func _clamp_AI_priority():
	AI_priorities[AI_action.wander] = clamp(AI_priorities[AI_action.wander], 0, AI_action_wander_max_priority)
	AI_priorities[AI_action.collect] = clamp(AI_priorities[AI_action.collect], 0, AI_action_collect_max_priority)
	AI_priorities[AI_action.guard] = clamp(AI_priorities[AI_action.guard], 0, AI_action_guard_max_priority)
	AI_priorities[AI_action.attack] = clamp(AI_priorities[AI_action.attack], 0, AI_action_attack_max_priority)
	AI_priorities[AI_action.catch] = clamp(AI_priorities[AI_action.catch], 0, AI_action_catch_max_priority)
	AI_priorities[AI_action.dodge] = clamp(AI_priorities[AI_action.dodge], 0, AI_action_dodge_max_priority)

func list_sort_to_array(list : Dictionary, list_size := 0):
	var _array = []
	var _values = list.values()
	_values.sort()
	_values.invert()
	if list_size > 0:
		_values.resize(list_size)
	for value in _values:
		for i in list:
			if list.get(i) == value and !_array.has(i):
				_array.append(i)
	return _array

func update_lb_priorities(list_size = 3):
	#首先是排除掉不在警戒范围内的小球
	for i in lb_priorities:
		if !little_balls_in_MonitorArea.has(i):
			lb_priorities.erase(i)
	lb_priorities_array = list_sort_to_array(lb_priorities, list_size)

func update_attack_priorities(list_size = 3):
	for i in attack_priorities:
		if !enemies_in_MonitorArea.has(i):
			attack_priorities.erase(i)
		
		#如果目标超出攻击范围
		elif (enemies_in_MonitorArea[i].global_position - get_parent().global_position).length() > 15 * $Sprite.scale.x + get_parent().weapon.fire_range:
			attack_priorities.erase(i)
	attack_priorities_array = list_sort_to_array(attack_priorities, list_size)

func update_catch_priorities(list_size = 3):
	for i in catch_priorities:
		if !enemies_in_MonitorArea.has(i):
			catch_priorities.erase(i)
	catch_priotities_array = list_sort_to_array(catch_priorities, list_size)

func update_guard_priorities(list_size = 3):
	for i in guard_priorities:
		if !enemies_in_MonitorArea.has(i):
			guard_priorities.erase(i)
	guard_priorities_array = list_sort_to_array(guard_priorities, list_size)

func update_dodge_priorities(list_size = 3):
	for i in dodge_priorities:
		if !enemies_in_MonitorArea.has(i):
			dodge_priorities.erase(i)
	dodge_priorities_array = list_sort_to_array(dodge_priorities, list_size)

func _on_MonitorTimer_timeout():
	update_MonitorAreaShape()
	count_monitor()
	MonitorTimer.start(2)

func _on_MonitorArea_body_entered(body):
	if body.has_method("get_damage"):
		if body.team == team and body != self:
			teammates_in_MonitorArea.append(body)
		else:
			enemies_in_MonitorArea.append(body)
	pass # Replace with function body.

func _on_MonitorArea_area_entered(area):
	if area.has_method("_on_LittleBall_body_entered"):
		little_balls_in_MonitorArea.append(area)
	if area.has_method("fly"):
		if area.team != team:
			enemy_bullets_in_MonitorArea.append(area)
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
	if area.has_method("fly"):
		if area.team != team:
			enemy_bullets_in_MonitorArea.erase(area)
	pass # Replace with function body.
