extends RigidBody2D

var velocity = Vector2()
var main
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	velocity = Vector2()
	if Input.is_key_pressed(KEY_W):
		velocity.y -= 1
	if Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_key_pressed(KEY_S):
		velocity.y += 1
	if Input.is_key_pressed(KEY_D):
		velocity.x += 1
	linear_velocity = velocity.normalized() * 100
	
	rotate_weapon($Sprite2, 0.5, get_global_mouse_position() - global_position, delta)

func rotate_weapon(object, speed, target_direction, delta):
	var present_direction = Vector2(1, 0).rotated(object.global_rotation)
	object.global_rotation = present_direction.linear_interpolate(target_direction, speed * delta).angle()
