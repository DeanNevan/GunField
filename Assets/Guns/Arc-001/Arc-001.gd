extends "res://Assets/Scripts/GunTemplate.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	require_size = 0
	capacity = 7#弹容量
	ammo = capacity#弹药数量
	fire_rate = 0.9#射速
	fire_range = 130#射程
	penetrating_power = 60#穿透力
	damage = 6#伤害
	bullet_speed = 400#子弹速度
	shoot_force = 4.2
	impact_force = 6
	accuracy = 0.71
	extra_bullets = 8
	reload_time = 1.65
	reload_way = 1
	wave_flame_length = 5
	rotate_speed = 0.9#旋转速度
	
	basic_bullet_speed = bullet_speed
	basic_damage = damage
	basic_fire_range = fire_range
	basic_impact_force = impact_force
	basic_penetrating_power = penetrating_power
	
	bullet = preload("res://Assets/Bullets/BulletStandard/BulletStandard.tscn")
	gun_offset = Vector2(15, -3)#枪口偏差
	gun_offset_origin = gun_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
