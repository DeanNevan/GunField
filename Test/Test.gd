extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var test = Node.new()
onready var a = [test]
func _ready():
	add_child(test)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("--------------")
	if Input.is_action_just_pressed("key_a"):
		print("pressed a")
		test.queue_free()
	print(test)
	print(is_instance_valid(test))
	print("--------------")
