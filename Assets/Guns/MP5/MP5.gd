extends "res://Assets/Scripts/GunTemplate.gd"

# Declare member variables here. Examples:
# a = 2
# b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	require_size = 0#需求的size
	capacity = 40#弹容量
	ammo = capacity#弹药数量
	fire_rate = 0.08#射速
	fire_range = 280#射程
	penetrating_power = 120#穿透力
	damage = 8#伤害(单发)
	bullet_speed = 510#子弹速度
	shoot_force = 1.6#后坐力
	impact_force = 2.0#冲击力
	accuracy = 0.84#精准度
	extra_bullets = 0#额外弹药（比如一次射8发，这个参数就是7）
	reload_time = 1.5#装弹时间
	reload_way = 0#装弹方式：弹匣式
	wave_flame_length = 8#尾迹长度
	rotate_speed = 1.5#旋转速度
	
	basic_bullet_speed = bullet_speed
	basic_damage = damage
	basic_fire_range = fire_range
	basic_impact_force = impact_force
	basic_penetrating_power = penetrating_power
	
	bullet = preload("res://Assets/Bullets/BulletStandard/BulletStandard.tscn")#弹药的场景
	gun_offset = Vector2(12, -3)#枪口偏差
	gun_offset_origin = gun_offset

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
