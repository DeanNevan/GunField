extends RigidBody2D

var size = 100
var size_para = sqrt(clamp(size / 100, 0.5, 100))
var max_stamina = 100
var stamina = 100

var velocity = Vector2()
var speed = 100

var should_update_scale = true

var emoji_state = 0#0 is kaixin, 1 is nanshou, 2 is pingdan

var team = 0#0 is player`s team
var weapon
var main

var little_ball = preload("res://Assets/LittleBall/LittleBall.tscn")

var is_player_unit = false
var is_main_unit = false
onready var Emoji = Sprite.new()
onready var EmojiTimer = Timer.new()

onready var tween1 = Tween.new()
onready var tween2 = Tween.new()
onready var tween3 = Tween.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	emoji_state = 0
	$Sprite.add_child(Emoji)
	add_child(EmojiTimer)
	EmojiTimer.one_shot = true
	EmojiTimer.autostart = false
	EmojiTimer.connect("timeout", self, "_on_EmojiTimer_timeout")
	Emoji.z_index = 1
	update_emoji()
	
	$Sprite.modulate = get_parent().team_color
	
	update_collision_bit()
	update_scale(true)
	update_scale(true)
	update_speed()
	
	add_child(tween1)
	add_child(tween2)
	add_child(tween3)
	pass


func _process(delta):
	max_stamina = size
	#mass = size / 100
	if size <= 0:
		die()
	
	if is_player_unit:
		_player_control(delta)

func _player_control(delta):
	velocity = Vector2()
	if Input.is_key_pressed(KEY_W):
		velocity.y -= 1
	if Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_key_pressed(KEY_D):
		velocity.x += 1
	
	if weapon != null:
		if weapon.is_reloading:
			linear_velocity = velocity.normalized() * speed / 2
		else:
			linear_velocity = velocity.normalized() * speed
	else:
		linear_velocity = velocity.normalized() * speed
	
	#print(linear_velocity)
	
	if Input.is_action_just_pressed("key_r"):
		weapon.reload()
	
	if Input.is_action_just_pressed("key_shift"):
		divide(get_node("/root/Main").get_global_mouse_position() - global_position)
	
	if weapon != null:
		if Input.is_action_pressed("left_mouse_button"):
			weapon.shoot(Vector2(cos(weapon.global_rotation), sin(weapon.global_rotation)))
		#print("hhh")
		rotate_weapon(weapon, 0.4 * pow(0.44, size_para) * weapon.rotate_speed * weapon.rotate_speed_times, get_global_mouse_position() - (global_position + weapon.gun_offset.rotated(weapon.global_rotation)), delta)


func divide(target):
	if size < 200:
		return false
	var new_unit = get_parent().unit.instance()
	new_unit.team = team
	new_unit.global_position = global_position + target.normalized() * 5 * size_para
	new_unit.size = size / 2
	get_parent().add_child(new_unit)
	size = size / 2
	if weapon != null:
		var new_unit_weapon = weapon.duplicate()
		new_unit.weapon = new_unit_weapon
		new_unit_weapon.unit = new_unit
		new_unit.add_child(new_unit_weapon)
	#new_unit.update_scale(true)
	update_scale()
	get_parent().update_main_unit()
	

func die():
	$CollisionShape2D.disabled = true
	queue_free()

func update_speed():
	speed = get_parent().init_speed * pow(0.8, size_para)

func update_emoji(state = 0, time = 1):
	if state != emoji_state:
		EmojiTimer.start(time)
	else:
		EmojiTimer.start(time + EmojiTimer.time_left)
	match state:
		0:
			Emoji.texture = load("res://Assets/Art/emoji/pingdan.png")
			emoji_state = 0
		1:
			Emoji.texture = load("res://Assets/Art/emoji/kaixin.png")
			emoji_state = 1
		2:
			Emoji.texture = load("res://Assets/Art/emoji/nanshou.png")
			emoji_state = 2
	match team:
		0:
			Emoji.self_modulate = Color.black
		1:
			Emoji.self_modulate = Color.black

func rotate_weapon(object, speed, target_direction, delta):
	var present_direction = Vector2(1, 0).rotated(object.global_rotation)
	object.global_rotation = present_direction.linear_interpolate(target_direction, speed * delta).angle()

func get_damage(damage, force = Vector2()):
	#print(damage)
	size -= damage
	update_scale()
	
	size_para = sqrt(clamp(size / 100, 1, 100))
	update_emoji(2, 0.5)
	linear_velocity += force * 2
	release_a_little_ball(damage, global_position - force.normalized() * 16 * size_para)

func release_a_little_ball(little_ball_size, pos):
	var new_little_ball = little_ball.instance()
	new_little_ball.size = little_ball_size
	new_little_ball.unit = self
	new_little_ball.global_position = pos
	main.add_child(new_little_ball)
	new_little_ball.get_node("Sprite").modulate = get_parent().team_color
	pass

func eat_a_little_ball(little_ball_size = 10):
	size += little_ball_size * get_parent().basic_conversion_rate
	update_emoji(1, 0.3)
	update_scale()

func _on_EmojiTimer_timeout():
	emoji_state = 0
	Emoji.texture = load("res://Assets/Art/emoji/pingdan.png")

func update_collision_bit():
	for i in 19:
		set_collision_layer_bit(i, false)
		set_collision_mask_bit(i, false)
	set_collision_layer_bit(team + 2, true)
	for i in 19:
		if i == team + 2:
			#continue
			pass
		set_collision_mask_bit(i, true)

func update_scale(is_init = false):
	size_para = sqrt(clamp(size / 100, 0.5, 100))
	update_speed()
	if !is_init:
		tween1.interpolate_property($Sprite, "scale", $Sprite.scale, Vector2(size_para, size_para), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	else:
		tween1.interpolate_property($Sprite, "scale", Vector2(), Vector2(size_para, size_para), 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#$Sprite.scale = Vector2(size_para, size_para)
	if weapon != null:
		weapon.scale = Vector2(size_para, size_para)
		weapon.update_weapon_para()
	tween2.interpolate_property($CollisionShape2D, "shape:radius", $CollisionShape2D.shape.radius, 15 * size_para, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	#$CollisionShape2D.shape.radius = 15 * size_para
	tween1.start()
	tween2.start()
	get_parent().update_main_unit()