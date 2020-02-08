extends Node

enum AI_action{
	wander#漫游
	collect#收集
	guard#守护
	attack#攻击
	dodge#躲避
}

var AI_state = AI_action.wander

var AI_priorities := {AI_action.wander : 0, AI_action.collect : 0, AI_action.guard : 0, AI_action.attack : 0, AI_action.dodge : 0}

#
var AI_action_wander_max_priority := 4
var AI_action_collect_max_priority := 4
var AI_action_guard_max_priority := 4
var AI_action_attack_max_priority := 4
var AI_action_dodge_max_priority := 4

var AI_priorities_array := []

var enemies_in_MonitorArea := []

var enemy_bullets_in_MonitorArea := []

var teammates_in_MonitorArea := []

var little_balls_in_MonitorArea := []

var attack_priorities := {}
var attack_priorities_array := []

var collect_priorities := {}
var collect_priorities_array := []

var guard_priorities := {}
var guard_priorities_array := []

var dodge_priorities := {}
var dodge_priorities_array := []

var action_with_array := {AI_action.wander : [],
						  AI_action.collect : collect_priorities_array,
						  AI_action.guard : guard_priorities_array,
						  AI_action.attack : attack_priorities_array,
						  AI_action.dodge : dodge_priorities_array}

onready var MonitorArea = Area2D.new()
onready var MonitorAreaShape = CollisionShape2D.new()
var monitor_sensitivity := 1
onready var action_updaterTimer = Timer.new()
var action_updater_time = 2

var team
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(MonitorArea)
	MonitorArea.add_child(MonitorAreaShape)
	MonitorAreaShape.shape = CircleShape2D.new()
	#MonitorAreaShape.visible = false
	
	MonitorArea.connect("body_entered", self, "_on_MonitorArea_body_entered")
	MonitorArea.connect("area_entered", self, "_on_MonitorArea_area_entered")
	MonitorArea.connect("body_exited", self, "_on_MonitorArea_body_exited")
	MonitorArea.connect("area_exited", self, "_on_MonitorArea_area_exited")
	
	team = get_parent().team
	
	add_child(action_updaterTimer)
	action_updaterTimer.connect("timeout", self, "_on_action_updaterTimer_timeout")
	action_updaterTimer.one_shot = true
	action_updaterTimer.start(2)
	
	_clamp_AI_priority()
	AI_priorities_array = list_sort_to_array(AI_priorities)
	
	update_MonitorAreaShape()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().is_player_unit:
		#print(AI_state)
		#print(attack_priorities_array)
		pass
	update_collect_priorities()
	update_attack_priorities()
	update_guard_priorities()
	update_dodge_priorities()
	MonitorArea.global_position = get_parent().global_position
	pass

func init_start_AI():
	for i in get_child_count():
		if get_child(i).has_method("update_property"):
			get_child(i).unit = get_parent()
			get_child(i).weapon = get_parent().weapon
			get_child(i).update_property()
			get_child(i).init_start_monitor()

func update_MonitorAreaShape():
	if get_parent().weapon != null:
		MonitorAreaShape.shape.radius = 15 * get_parent().get_node("Sprite").scale.x + monitor_sensitivity * get_parent().weapon.fire_range

func action_updater():
	#teammates_in_MonitorArea.erase(self)
	_clamp_AI_priority()
	AI_priorities_array = list_sort_to_array(AI_priorities, 5)
	
	action_with_array = {AI_action.wander : [],
						 AI_action.collect : collect_priorities_array,
						 AI_action.guard : guard_priorities_array,
						 AI_action.attack : attack_priorities_array,
						 AI_action.dodge : dodge_priorities_array
						}

	var _temp = false
	for i in AI_priorities_array:
		if action_with_array[i].size() > 0:
			AI_state = i
			_temp = true
			break
	if !_temp:
		AI_state = AI_action.wander
		pass
	"""match AI_state:
		AI_action.collect:
			update_collect_priorities()
		AI_action.attack:
			update_attack_priorities()
		AI_action.guard:
			update_guard_priorities()
		AI_action.dodge:
			update_dodge_priorities()"""
	pass

func _clamp_AI_priority():
	AI_priorities[AI_action.wander] = clamp(AI_priorities[AI_action.wander], 0, AI_action_wander_max_priority)
	AI_priorities[AI_action.collect] = clamp(AI_priorities[AI_action.collect], 0, AI_action_collect_max_priority)
	AI_priorities[AI_action.guard] = clamp(AI_priorities[AI_action.guard], 0, AI_action_guard_max_priority)
	AI_priorities[AI_action.attack] = clamp(AI_priorities[AI_action.attack], 0, AI_action_attack_max_priority)
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

func update_collect_priorities(list_size = 3):
	for i in collect_priorities:
		if !little_balls_in_MonitorArea.has(i):
			collect_priorities[i] -= 0.5
		if !is_instance_valid(i):
			collect_priorities.erase(i)
		elif collect_priorities.get(i) <= 0:
			collect_priorities.erase(i)
		else:
			collect_priorities[i] = clamp(collect_priorities[i], 0, 10)
	collect_priorities_array = list_sort_to_array(collect_priorities, clamp(list_size, 0, collect_priorities.size()))

func update_attack_priorities(list_size = 3):
	for i in attack_priorities:
		if !enemies_in_MonitorArea.has(i):
			attack_priorities[i] -= 0.5
		if !is_instance_valid(i):
			attack_priorities.erase(i)
		elif attack_priorities.get(i) <= 0:
			attack_priorities.erase(i)
			
		else:
			attack_priorities[i] = clamp(attack_priorities[i], 0, 10)
	attack_priorities_array = list_sort_to_array(attack_priorities, clamp(list_size, 0, attack_priorities.size()))

func update_guard_priorities(list_size = 3):
	for i in guard_priorities:
		if !teammates_in_MonitorArea.has(i):
			guard_priorities[i] -= 0.5
		if !is_instance_valid(i):
			guard_priorities.erase(i)
		elif guard_priorities.get(i) <= 0:
			guard_priorities.erase(i)
		else:
			guard_priorities[i] = clamp(guard_priorities[i], 0, 10)
	guard_priorities_array = list_sort_to_array(guard_priorities, clamp(list_size, 0, guard_priorities.size()))

func update_dodge_priorities(list_size = 3):
	for i in dodge_priorities:
		if !enemies_in_MonitorArea.has(i):
			dodge_priorities[i] -= 0.5
		if !is_instance_valid(i):
			dodge_priorities.erase(i)
		elif dodge_priorities.get(i) <= 0:
			dodge_priorities.erase(i)
		else:
			dodge_priorities[i] = clamp(dodge_priorities[i], 0, 10)
	dodge_priorities_array = list_sort_to_array(dodge_priorities, clamp(list_size, 0, dodge_priorities.size()))
	#if get_parent().is_selected:
	#print(dodge_priorities_array)

func update_action_target(action_list, target, para):
	#print(str(action_list) + str(target) + str(para))
	if !action_list.has(target):
		action_list[target] = para
		#print("222222")
	else:
		action_list[target] += para

func _on_action_updaterTimer_timeout():
	update_MonitorAreaShape()
	
	action_updater()
	action_updaterTimer.start(action_updater_time)

func _on_MonitorArea_body_entered(body):
	if body.has_method("get_damage"):
		if body.team == team and body != self:
			teammates_in_MonitorArea.append(body)
		else:
			enemies_in_MonitorArea.append(body)
	teammates_in_MonitorArea.erase(self)
	pass # Replace with function body.

func _on_MonitorArea_area_entered(area):
	if area.has_method("_on_LittleBall_body_entered"):
		if little_balls_in_MonitorArea.size() > 50:
			little_balls_in_MonitorArea[rand_range(0, little_balls_in_MonitorArea.size() - 1)] = area
		else:
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
	teammates_in_MonitorArea.erase(self)
	pass # Replace with function body.

func _on_MonitorArea_area_exited(area):
	if area.has_method("_on_LittleBall_body_entered"):
		little_balls_in_MonitorArea.erase(area)
	if area.has_method("fly"):
		if area.team != team:
			enemy_bullets_in_MonitorArea.erase(area)
	pass # Replace with function body.
