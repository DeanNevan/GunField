extends Area2D

var size = 10
var size_para = sqrt(clamp(size / 10, 1, 100))

var unit
onready var tween1 = Tween.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("LB")
	add_child(tween1)
	if unit != null:
		set_collision_layer_bit(unit.team + 2, true)
	else:
		set_collision_layer_bit(0, true)
	size_para = sqrt(clamp(size / 10, 1, 100))
	$Sprite.visible = true
	tween1.interpolate_property(self, "scale", Vector2(), Vector2(size_para, size_para), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween1.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#_update_scale()
	#global_rotation += 0.5
	pass

"""func _update_scale():
	size_para = sqrt(clamp(size / 10, 1, 100))
	tween1.interpolate_property(self, "scale", scale, Vector2(size_para, size_para), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween1.start()
	pass
"""

func _on_LittleBall_body_entered(body):
	if body.has_method("eat_a_little_ball"):
		if body.size <= size:
			return false
		body.eat_a_little_ball(size)
		queue_free()
		pass