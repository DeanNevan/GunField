extends Node2D

var require_size = 0
var capacity = 10#弹容量
var ammo = 10
var fire_rate = 1#射速
var basic_fire_range = 300
var fire_range = 300#射程
var basic_penetrating_power = 100
var penetrating_power = 100#穿透力
var basic_damage = 10
var damage = 10#伤害
var basic_bullet_speed = 100
var bullet_speed = 100#子弹速度
var shoot_force = 1#后坐力
var basic_impact_force = 1
var impact_force = 1#冲击力
var accuracy = 0.8
var extra_bullets = 0
var reload_time = 2#装弹时间
var rotate_speed = 1#旋转速度

var rotate_speed_times = 1
var wave_flame_length = 10

var gun_offset = Vector2()#枪口偏差
var gun_offset_origin = Vector2()
var bullet = preload("res://Assets/Bullets/BulletStandard/BulletStandard.tscn")
var unit
var can_shoot = true
var is_overheating = false
var is_cooldown = false
onready var cooldown_timer = Timer.new()

var is_reloading = false
var reload_way = 0#0就是弹匣式装填， 1就是一发一发地装填
onready var reload_timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 2
	
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", self, "on_cooldown_timer_timeout")
	cooldown_timer.one_shot = true
	cooldown_timer.autostart = false
	
	add_child(reload_timer)
	reload_timer.one_shot = true
	cooldown_timer.autostart = false
	reload_timer.connect("timeout", self, "_on_reload_timer_timeout")
	
	position = Vector2()
	get_parent().update_scale()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if abs(global_rotation) >= PI / 2:
		$Sprite.flip_v = true
		gun_offset = gun_offset_origin * unit.size_para
		gun_offset.y = - gun_offset_origin.y
	else:
		$Sprite.flip_v = false
		gun_offset = gun_offset_origin * unit.size_para
		gun_offset.y = gun_offset_origin.y

func on_cooldown_timer_timeout():
	can_shoot = true
	is_cooldown = false
	

func reload():
	is_reloading = true
	#can_shoot = false
	reload_timer.paused = false
	reload_timer.start(reload_time)
	#print("reload")

func _on_reload_timer_timeout():
	#can_shoot = true
	is_reloading = false
	#print("reload ok")
	match reload_way:
		0:
			ammo = capacity
		1:
			if ammo < capacity:
				ammo += 1
			if ammo != capacity:
				reload()

func update_weapon_para():
	bullet_speed = basic_bullet_speed * sqrt(unit.size_para)
	damage = basic_damage * sqrt(unit.size_para)
	fire_range = basic_fire_range * sqrt(unit.size_para)
	impact_force = basic_impact_force * sqrt(unit.size_para)
	penetrating_power = basic_penetrating_power * sqrt(unit.size_para)

func shoot(direction):
	scale = get_parent().get_node("Sprite").scale
	
	if !can_shoot or ammo <= 0:
		return false
	
	if reload_way == 1 and is_reloading == true:
		reload_timer.paused = true
	
	ammo -= 1
	#print("ammo left", ammo)
	var _ran = 0
	for i in extra_bullets + 1:
		var new_bullet = bullet.instance()
		new_bullet.team = unit.team
		new_bullet.unit = unit
		var ran = rand_range(-(1 - accuracy), (1 - accuracy))
		new_bullet.generate(unit.global_position + gun_offset.rotated(global_rotation), damage, (bullet_speed * direction.normalized()).rotated(ran), penetrating_power, fire_range, impact_force, wave_flame_length)
		new_bullet.set_collision_layer_bit(unit.team + 2, true)
		new_bullet.start_position = unit.global_position + gun_offset.rotated(global_rotation)
		get_node("/root/Main").add_child(new_bullet)
		match unit.team:
			0:
				new_bullet.add_to_group("team_0_bullets")
			1:
				new_bullet.add_to_group("team_1_bullets")
			2:
				new_bullet.add_to_group("team_2_bullets")
		new_bullet.fly()
		_ran + ran
	global_rotation += _ran / (extra_bullets + 1)
	unit.update_emoji(1, 0.15)
	can_shoot = false
	is_cooldown = true
	cooldown_timer.start(fire_rate)
	position -= direction.normalized() * shoot_force * unit.size_para * 0.7
	#unit.position -= direction.normalized() * shoot_force
	unit.linear_velocity -= direction.normalized() * shoot_force * unit.size_para * 50
	rotate_speed_times = 0.1
	
	if ammo <= 0:
		reload()
	
	yield(get_tree().create_timer(fire_rate), "timeout")
	rotate_speed_times = 1
	position = Vector2()
	

