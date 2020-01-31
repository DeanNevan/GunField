extends "res://Assets/Scripts/BulletTemplate.gd"

var t = false

var team_color = Color.white

var c = []
var wave_flame_length = 10
onready var wave_flame = preload("res://Assets/Bullets/WaveFlame.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/Main").add_child(wave_flame)
	wave_flame.self_modulate = team_color
	wave_flame.start_position = start_position
	#print(start_position)
	wave_flame.team_color = team_color
	wave_flame.width = unit.size_para * 2
	
	wave_flame.points_array.append(global_position)
	#connect("body_entered", self, "on_body_enter")
	#connect("body_exited", self, "on_body_exit")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_flying:
		if t == true:
			self.position += speed / 50
		t = true
		$RayCast2D.cast_to = speed / 50
		judge_damage()
		
		#wave_flame.global_position = global_position
		if wave_flame.points_array.size() >= wave_flame_length:
			wave_flame.points_array.push_back(global_position)
			wave_flame.points_array.pop_front()
		else:
			wave_flame.points_array.append(global_position)
		
		if (global_position - start_position).length() > fly_range:
			wave_flame.prepare_free()
			#visible = false
			#yield(get_tree(), "idle_frame")
			monitorable = false
			monitoring = false
			$CollisionShape2D.disabled = true
			is_flying = false
			queue_free()

func generate(generate_position, damage1, speed1, penetrating_power1, fly_range1, impact_force1, wave_flame_length1):
	self.global_position = generate_position
	damage = damage1
	speed = speed1
	penetrating_power = penetrating_power1
	fly_range = fly_range1
	impact_force = impact_force1
	wave_flame_length = wave_flame_length1
	scale =  unit.get_node("Sprite").scale
	
	$RayCast2D.cast_to = speed / 50
	judge_damage()
	
	team_color = unit.get_parent().team_color
	$Sprite.modulate = team_color
	

func judge_damage():
	#$RayCast2D.force_raycast_update()
	if $RayCast2D.get_collider() != null:
		if $RayCast2D.get_collider().has_method("get_damage"):
			if $RayCast2D.get_collider().team != team:
				if !c.has($RayCast2D.get_collider()):
					$RayCast2D.get_collider().get_damage(damage, ($RayCast2D.get_collider().global_position - $RayCast2D.get_collision_point()).normalized() * impact_force)
				var ran = rand_range(penetrating_power * 0.4, penetrating_power)
				if ran > $RayCast2D.get_collider().size:
					#print("yes")
					c.append($RayCast2D.get_collider())
					penetrating_power -= $RayCast2D.get_collider().size
				else:
					monitorable = false
					monitoring = false
					is_flying = false
					#wave_flame.emitting = false
					wave_flame.prepare_free()
					visible = false
					$CollisionShape2D.disabled = true
					queue_free()


func fly():
	is_flying = true

func on_body_enter(body):
	"""if body.has_method("get_damage"):
		body.get_damage(damage, (body.global_position - unit.global_position).normalized() * impact_force)
		var ran = rand_range(penetrating_power * 0.4, penetrating_power)
		if body.size < ran:
			penetrating_power -= body.size
			#self.set_collision_layer_bit(team + 2, false)
			#print("??")
		else:
			#print("!!!")
			queue_free()"""
	pass

func on_body_exit(body):
	#self.set_collision_layer_bit(team + 2, true)
	pass
