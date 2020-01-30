extends "res://Assets/Unit/Unit.gd"

enum AI_state{
	wander#漫游
	collect#收集
	guard#警戒
	attack#攻击
	catch#追赶
	dodge#躲避
}

var enemies_in_MonitorArea1 := []
var enemies_in_MonitorArea2 := []

var teammates_in_MonitorArea1 := []
var teammates_in_MonitorArea2 := []


onready var MonitorArea1 = $MonitorArea1
onready var MonitorArea2 = $MonitorArea2

# Called when the node enters the scene tree for the first time.
func _ready():
	team = 1
	update_collision_bit()
	
	update_MonitorAreaShape()

func update_MonitorAreaShape():
	if weapon != null:
		MonitorArea1.get_node("CollisionShape2D").shape.radius = 15 * $Sprite.scale.x + weapon.fire_range
		MonitorArea2.get_node("CollisionShape2D").shape.radius = 2 * MonitorArea1.get_node("CollisionShape2D").shape.radius

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_rotation = 0



func _on_MonitorArea1_body_entered(body):
	if body.has_method("get_damage"):
		if body.team == team:
			teammates_in_MonitorArea1.append(body)
		
	pass # Replace with function body.


func _on_MonitorArea2_body_entered(body):
	pass # Replace with function body.
