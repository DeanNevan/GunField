extends RigidBody2D

var velocity = Vector2()
var main
# Called when the node enters the scene tree for the first time.
func _ready():
	print(connect("mouse_entered", self, "_on_mouse_entered"))
	print(connect("mouse_exited", self, "_on_mouse_exited"))
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_mouse_entered():
	print("233")

func _on_mouse_exited():
	print("322")


func _on_RigidBody2D_mouse_entered():
	print("enter")


func _on_RigidBody2D_mouse_exited():
	print("exit")
