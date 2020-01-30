extends "res://Assets/Scripts/GunTemplate.gd"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	require_size = 0
	capacity = 9#弹容量
	ammo = capacity#弹药数量
	fire_rate = 2#射速
	fire_range = 380#射程
	penetrating_power = 220#穿透力
	damage = 46#伤害
	bullet_speed = 900#子弹速度
	shoot_force = 9
	impact_force = 19
	accuracy = 0.97
	extra_bullets = 0
	reload_time = 4
	reload_way = 0
	wave_flame_length = 25
	rotate_speed = 0.7#旋转速度
	
	basic_bullet_speed = bullet_speed
	basic_damage = damage
	basic_fire_range = fire_range
	basic_impact_force = impact_force
	basic_penetrating_power = penetrating_power
	
	bullet = preload("res://Assets/Bullets/BulletStandard/BulletStandard.tscn")
	gun_offset = Vector2(17, -1.5)#枪口偏差
	gun_offset_origin = gun_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
