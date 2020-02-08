extends Node

var name_CN = "流浪者"

onready var unit = get_parent().get_parent()
onready var weapon = get_parent().get_parent().weapon

onready var MonitorTimer = Timer.new()
var monitor_time = 2

onready var ai = get_parent()

var has_updated_property = false

var is_debug = false

var temp_teammate = []
var test_para = 0

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
	pass
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
	
	#弹容量减少10%
	weapon.capacity *= 0.9
	ceil(weapon.capacity)
	#射速降低10%
	weapon.fire_rate *= 1.1
	#装填时间增加10%
	weapon.reload_time *= 1.1
	#准确度降低10%
	weapon.accuracy *= 0.9
	#后坐力增加10%
	weapon.shoot_force *= 1.1
	#冲击力减少10%
	weapon.impact_force *= 0.9
	#射程减少10%
	weapon.fire_range *= 0.9
	ceil(weapon.fire_range)
	#单位的初始体积降低20%
	unit.init_size *= 0.8
	unit.size *= 0.8
	
	#单位的初始速度提高15%
	unit.init_speed *= 1.15
	unit.update_scale()
	#单位的基础转化率提高20%
	unit.basic_conversion_rate *= 1.2
	#警戒范围提高25%
	get_parent().monitor_sensitivity *= 1.25
	#调整行为最大优先级
	get_parent().AI_action_wander_max_priority += 2
	get_parent().AI_action_collect_max_priority += 2
	get_parent().AI_action_guard_max_priority -= 1
	get_parent().AI_action_attack_max_priority += 0
	get_parent().AI_action_dodge_max_priority += 2


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
	
	_wander()
	_collector()
	_timid()
	_hateful_tragedy()
	pass

#特性：流浪。
func _wander():
	if is_debug: print("---特性：流浪，监测开始---")
	
	if ai.enemies_in_MonitorArea.size() == 0:
		if is_debug: print("警戒范围内无敌方单位，漫游优先级提高1")
		ai.AI_priorities[ai.AI_action.wander] += 0.5
	
	if is_debug: print("流浪，守护优先级降低0.5")
	ai.AI_priorities[ai.AI_action.guard] -= 0.5
	
	if is_debug: print("---特性：流浪，监测结束---")

#特性：收集者。
func _collector():
	if is_debug: print("---特性：收集者，监测开始---")
	
	var _count = 0
	var _target := []#保存最大的三个小球的数组
	var _target_list := {}
	for i in ai.little_balls_in_MonitorArea:
		_count += i.size
		_target_list[i] = i.size
	_target = ai.list_sort_to_array(_target_list, 3)
	if is_debug: print("小球总体积：", _count)
	if _target.size() > 0:
		if is_debug: print("最大小球体积：", _target[0].size)
	
	if _count >= unit.size / 5:
		if is_debug: print("小球总体积大于自身20%，收集优先级提高1")
		ai.AI_priorities[ai.AI_action.collect] += 1
	else:
		if is_debug: print("小球总体积小于自身20%，收集优先级降低1")
		ai.AI_priorities[ai.AI_action.collect] -= 1
	if _target.size() > 0:
		if _target[0].size > unit.size / 5:
			if is_debug: print("小球体积最大者大于自身20%，收集优先级提高1")
			ai.AI_priorities[ai.AI_action.collect] += 1
	
	_target.invert()
	for i in _target.size():
		ai.update_action_target(ai.collect_priorities, _target[i], (i + 1) / 2)
	
	#for i in ai.collect_priorities:
		#如果小球在警戒范围外，该目标的【攻击】优先级-1
		#if !ai.enemies_in_MonitorArea.has(i):
			#ai.update_action_target(ai.attack_priorities, i, -1)
	if is_debug: print("---特性：收集者，监测结束---")
	#print(_count)
	pass

#特性：可恨的悲剧者
#描述：当警戒范围内存在比自身弱小许多的敌方单位，攻击优先级提高
func _hateful_tragedy():
	if is_debug: print("---特性：可恨的悲剧者，监测开始---")
	var _target_list := {}
	var _target := []
	for i in ai.enemies_in_MonitorArea:
		if i.size <= unit.size / 1.5:
			_target_list[i] = i.size
	_target = ai.list_sort_to_array(_target_list, 3)
	if _target.size() > 0:
		if is_debug: print("存在小于自身三分之二体积的敌方单位，攻击优先级提高1")
		ai.AI_priorities[ai.AI_action.attack] += 1
		if _target[_target.size() - 1].size < unit.size / 2:
			if is_debug: print("存在小于自身一半体积的敌方单位，攻击优先级提高1")
			ai.AI_priorities[ai.AI_action.attack] += 1
		for i in _target.size():
			ai.update_action_target(ai.attack_priorities, _target[i], (i + 1) / 2)
	else:
		if is_debug: print("不存在小于自身三分之二体积的敌方单位，攻击优先级降低1")
		ai.AI_priorities[ai.AI_action.attack] -= 1
	
	#for i in ai.attack_priorities:
		#如果敌人在警戒范围外，该目标的【攻击】优先级-1
		#if !ai.enemies_in_MonitorArea.has(i):
			#ai.update_action_target(ai.attack_priorities, i, -1)
	
	if is_debug: print("---特性：可恨的悲剧者，监测结束---")
	

#特性：胆小
func _timid():
	if is_debug: print("---特性：胆小，监测开始---")
	var _count = 0
	var _max = 0
	var _target = []
	for i in ai.enemies_in_MonitorArea:
		_count += i.size
		if i.size > _max:
			_max = i.size
		if i.size > unit.size:
			_target.append(i)
	#print(_target.size())
	if is_debug: print("警戒范围内敌人体积总数：" + str(_count) + "\n" + "大于自身体积的敌人个数：" + str(_target.size()))
	if _count >= unit.size:
		if is_debug: print("敌人体积总数大于自身，躲避优先级提高1，漫游优先级降低1")
		#如果警戒范围内敌人体积总数大于自身体积，【躲避】优先级+1
		ai.AI_priorities[ai.AI_action.dodge] += 1
		ai.AI_priorities[ai.AI_action.wander] -= 1
	if _target.size() > 0:
		if is_debug: print("存在大于自身的敌方单位，躲避优先级提高1，漫游优先级降低1")
		#如果警戒范围内存在大于自身体积的敌人，【躲避】优先级+1
		ai.AI_priorities[ai.AI_action.dodge] += 1
		ai.AI_priorities[ai.AI_action.wander] -= 1
		for i in _target.size():
			#以警戒范围内大于自身体积的敌人的大小排序成【躲避】对象的优先级
			ai.update_action_target(ai.dodge_priorities, _target[i], (i + 1) / 2)
	if _count < unit.size:
		if is_debug: print("敌人体积总数小于自身，躲避优先级降低0.5")
		ai.AI_priorities[ai.AI_action.dodge] -= 0.5
	if _max < unit.size:
		if is_debug: print("敌人最大体积者小于自身，躲避优先级降低0.5")
		ai.AI_priorities[ai.AI_action.dodge] -= 0.5
	
	#for i in ai.dodge_priorities:
		#如果敌人在警戒范围外，该目标的【躲避】优先级-1
		#if !ai.enemies_in_MonitorArea.has(i):
			#ai.update_action_target(ai.dodge_priorities, i, -1)
	
	if is_debug: print("---特性：胆小，监测结束---")
	pass

func _on_teammate_get_damage(damage, attacker, just_size, teammate):
	if !can_monitor_teammate_damage:
		return false
	can_monitor_teammate_damage = false
	
	if is_debug: print("---AI：Vagrant，队友受到伤害，判定开始---")
	#if damage > just_size / 5:
		#if is_debug: print("伤害大于自身体积20%，躲避优先级提高0.5")
		#ai.AI_priorities[ai.AI_action.dodge] += 0.5
	if attacker.size > unit.size:
		if is_debug: print("攻击者体积大于自身，躲避优先级提高0.5")
		ai.AI_priorities[ai.AI_action.dodge] += 0.5
		ai.update_action_target(ai.dodge_priorities, attacker, 1)
	if damage <= just_size / 5 and attacker.size <= unit.size:
		if is_debug: print("伤害小于自身体积20%且攻击者体积小于自身，守护优先级提高1，攻击优先级提高1")
		ai.AI_priorities[ai.AI_action.guard] += 1
		ai.update_action_target(ai.guard_priorities, teammate, 1)
		ai.AI_priorities[ai.AI_action.attack] += 1
		ai.update_action_target(ai.attack_priorities, attacker, 1)
	if is_debug: print("---AI：Vagrant，队友受到伤害，判定结束---")
	pass

func _on_get_damage(damage, attacker, just_size):
	if !can_monitor_damage:
		return false
	can_monitor_damage = false
	
	if is_debug: print("---AI：Vagrant，受到伤害，判定开始---")
	if damage > just_size * 0.2:
		if is_debug: print("伤害大于自身体积20%，躲避优先级提高0.5")
		ai.AI_priorities[ai.AI_action.dodge] += 0.5
		ai.update_action_target(ai.dodge_priorities, attacker, 1)
	if attacker.size > unit.size:
		if is_debug: print("攻击者体积大于自身，躲避优先级提高0.5")
		ai.AI_priorities[ai.AI_action.dodge] += 0.5
		ai.update_action_target(ai.dodge_priorities, attacker, 1)
	if damage <= just_size * 0.2 and attacker.size <= unit.size:
		if is_debug: print("伤害小于自身体积20%且攻击者体积小于自身，攻击优先级提高0.5")
		ai.AI_priorities[ai.AI_action.attack] += 0.5
		ai.update_action_target(ai.attack_priorities, attacker, 0.5)
	if is_debug: print("---AI：Vagrant，受到伤害，判定结束---")
	pass
