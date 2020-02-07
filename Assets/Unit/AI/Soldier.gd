extends Node

var name_CN = "士兵"

onready var unit = get_parent().get_parent()
onready var weapon = get_parent().get_parent().weapon

onready var MonitorTimer = Timer.new()
var monitor_time = 2

onready var ai = get_parent()

var has_updated_property = false

var is_debug = false

var temp_teammate = []

onready var DamageMonitorTimer = Timer.new()
var can_monitor_damage = true
onready var TeammateDamageMonitorTimer = Timer.new()
var can_monitor_teammate_damage = true
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(MonitorTimer)
	MonitorTimer.one_shot = false
	MonitorTimer.connect("timeout", self, "_on_MonitorTimer_timeout")
	unit.connect("get_damage", self, "_on_get_damage")
	
	add_child(DamageMonitorTimer)
	add_child(TeammateDamageMonitorTimer)
	DamageMonitorTimer.one_shot = false
	TeammateDamageMonitorTimer.one_shot = false
	DamageMonitorTimer.connect("timeout", self, "_on_DamageMonitorTimer_timeout")
	TeammateDamageMonitorTimer.connect("timeout", self, "_on_TeammateDamageMonitorTimer_timeout")
	DamageMonitorTimer.start(monitor_time)
	TeammateDamageMonitorTimer.start(monitor_time)
	
	init_start_monitor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_property():
	if has_updated_property:
		return false
	has_updated_property = true
	
	if unit.is_player_unit:
		#is_debug = true
		pass
	
	#弹容量增加15%
	weapon.capacity *= 0.85
	ceil(weapon.capacity)
	#装填时间降低15%
	weapon.reload_time *= 1.15
	#准确度提高5%
	weapon.accuracy *= 1.05
	#武器基础伤害提高5%
	weapon.basic_damage *= 1.05
	#单位的初始体积提高5%
	unit.init_size *= 1.05
	#单位的初始速度提高5%
	unit.init_speed *= 1.05
	#警戒范围提高15%
	get_parent().monitor_sensitivity *= 1.15
	#调整行为最大优先级
	get_parent().AI_action_wander_max_priority -= 1
	get_parent().AI_action_collect_max_priority += 1
	get_parent().AI_action_guard_max_priority += 2
	get_parent().AI_action_attack_max_priority += 2
	get_parent().AI_action_dodge_max_priority += 1

func init_start_monitor(time = monitor_time):
	MonitorTimer.start(monitor_time)

func _on_MonitorTimer_timeout():
	if ai.teammates_in_MonitorArea.has(unit):
		ai.teammates_in_MonitorArea.erase(unit)
	#print(ai.enemies_in_MonitorArea)
	#if unit.is_player_unit: print(ai.little_balls_in_MonitorArea)
	monitor()

func _on_DamageMonitorTimer_timeout():
	can_monitor_damage = true

func _on_TeammateDamageMonitorTimer_timeout():
	can_monitor_teammate_damage = true

func monitor():
	for teammate in ai.teammates_in_MonitorArea:
		if !temp_teammate.has(teammate):
			temp_teammate.append(teammate)
		if is_instance_valid(teammate):
			if !teammate.is_connected("get_damage", self, "_on_teammate_get_damage"):
				teammate.connect("get_damage", self, "_on_teammate_get_damage", [teammate])
			temp_teammate.erase(teammate)
	for teammate in temp_teammate:
		if !ai.teammates_in_MonitorArea.has(teammate):
			if is_instance_valid(teammate):
				if teammate.is_connected("get_damage", self, "_on_teammate_get_damage"):
					teammate.disconnect("get_damage", self, "_on_teammate_get_damage")
			temp_teammate.erase(teammate)
	
	_discipline()
	_protect()
	_friend()
	_brave()
	pass

#特性：纪律
#描述：不喜欢漫游
func _discipline():
	ai.AI_priorities[ai.AI_action.wander] -= 0.5
	#ai.AI_priorities[ai.AI_action.collect] -= 0.5

#特性：同伴与守护
#描述：警戒范围内有友军时，提高守护优先级，且优先守护大体积的友军。
func _protect():
	if ai.teammates_in_MonitorArea.size() > 1:
		ai.AI_priorities[ai.AI_action.guard] += 0.5
	var _target_list := {}
	var _target := []
	for i in ai.teammates_in_MonitorArea:
		if i.size > unit.size:
			ai.AI_priorities[ai.AI_action.guard] += 0.5
			_target_list[i] = i.size
	_target = ai.list_sort_to_array(_target_list, 3)
	if _target.size() > 0:
		ai.AI_priorities[ai.AI_action.guard] += 0.5
		_target.invert()
		for i in _target.size():
			ai.update_action_target(ai.guard_priorities, _target[i], (i + 1) / 2)
	

#特性：战友
#描述：会收集队友掉落的小球。
func _friend():
	var _target_list := {}
	var _target := []
	for i in ai.little_balls_in_MonitorArea:
		if i.unit != null:
			if !is_instance_valid(i.unit) and !is_instance_valid(i):
				if i.unit.team == unit.team:
					_target_list[i] = i.size
	_target = ai.list_sort_to_array(_target_list, 3)
	if _target.size() > 0:
		ai.AI_priorities[ai.AI_action.collect] += 1
		_target.invert()
		for i in _target.size():
			ai.update_action_target(ai.collect_priorities, _target[i], (i + 1) / 2)
	

#特性：勇敢与热血
#描述：警戒范围内存在敌人，提高攻击优先级，敌人越多，攻击越优先；敌人最大体积者过大，提高躲避优先级。
func _brave():
	var _target_list := {}
	var _target := []
	for i in ai.enemies_in_MonitorArea:
		_target_list[i] = i.size
	_target = ai.list_sort_to_array(_target_list, 3)
	if ai.enemies_in_MonitorArea.size() > 0:
		ai.AI_priorities[ai.AI_action.attack] += 0.5
		if ai.enemies_in_MonitorArea.size() >= 5:
			ai.AI_priorities[ai.AI_action.guard] -= 0.5
			ai.AI_priorities[ai.AI_action.attack] += 1
		if _target[0].size > unit.size * 4:
			ai.AI_priorities[ai.AI_action.dodge] += 1
			ai.AI_priorities[ai.AI_action.attack] -= 0.5
			_target.invert()
			for i in _target.size():
				if _target[i].size > unit.size * 4:
					ai.update_action_target(ai.dodge_priorities, _target, (i + 1) / 2)
	else:
		ai.AI_priorities[ai.AI_action.attack] -= 0.5

func _on_teammate_get_damage(damage, attacker, just_size, teammate):
	if !can_monitor_teammate_damage:
		return false
	can_monitor_teammate_damage = false
	
	if is_debug: print("---AI：Soldier，队友受到伤害，判定开始---")
	if is_debug: print("守护优先级提高0.5")
	ai.AI_priorities[ai.AI_action.guard] += 0.5
	if attacker.size > unit.size * 1.8:
		if is_debug: print("攻击者体积大于自身1.8倍，躲避优先级提高0.5")
		ai.AI_priorities[ai.AI_action.dodge] += 0.5
		ai.update_action_target(ai.dodge_priorities, attacker, 1)
	if damage <= just_size * 0.35 and attacker.size <= unit.size * 1.8:
		if is_debug: print("伤害小于自身体积35%且攻击者体积小于自身1.8倍，守护优先级提高1，攻击优先级提高1")
		ai.AI_priorities[ai.AI_action.guard] += 1
		ai.update_action_target(ai.guard_priorities, teammate, 1.5)
		ai.AI_priorities[ai.AI_action.attack] += 1
		ai.update_action_target(ai.attack_priorities, attacker, 1)
	if is_debug: print("---AI：Soldier，队友受到伤害，判定结束---")
	pass

func _on_get_damage(damage, attacker, just_size):
	if !can_monitor_damage:
		return false
	can_monitor_damage = false
	
	if is_debug: print("---AI：Soldier，受到伤害，判定开始---")
	if damage > just_size * 0.35:
		if is_debug: print("伤害大于自身体积35%，躲避优先级提高0.5")
		ai.AI_priorities[ai.AI_action.dodge] += 0.5
		ai.update_action_target(ai.dodge_priorities, attacker, 1)
	if attacker.size > unit.size * 1.8:
		if is_debug: print("攻击者体积大于自身1.8倍，躲避优先级提高0.5")
		ai.AI_priorities[ai.AI_action.dodge] += 0.5
		ai.update_action_target(ai.dodge_priorities, attacker, 1)
	if damage <= just_size * 0.35 and attacker.size <= unit.size * 1.8:
		if is_debug: print("伤害小于自身体积35%且攻击者体积小于自身1.8倍，攻击优先级提高1")
		ai.AI_priorities[ai.AI_action.attack] += 1.5
		ai.update_action_target(ai.attack_priorities, attacker, 1.5)
	if is_debug: print("---AI：Soldier，受到伤害，判定结束---")
